import os
import requests
from typing import List, Optional, Dict, Any, Tuple

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from dotenv import load_dotenv

load_dotenv()

GEOAPIFY_KEY = os.getenv("GEOAPIFY_API_KEY")
TOMTOM_KEY = os.getenv("TOMTOM_API_KEY")

print("Geoapify key loaded:", bool(GEOAPIFY_KEY))
print("TomTom key loaded:", bool(TOMTOM_KEY))

GEOAPIFY_PLACES_URL = "https://api.geoapify.com/v2/places"
GEOAPIFY_DETAILS_URL = "https://api.geoapify.com/v2/place-details"

app = FastAPI(title="Your Places Backend")


# -----------------------------
# Models
# -----------------------------

class RecommendRequest(BaseModel):
    lat: float
    lon: float
    radius_m: int = Field(1500, ge=100, le=20000)
    limit: int = Field(20, ge=1, le=100)
    categories: List[str] = Field(
        default_factory=lambda: ["catering.restaurant", "catering.cafe"]
    )

    # weights
    prefer_close: float = 0.6
    prefer_high_rating: float = 0.4

    # optional features
    include_traffic: bool = False
    include_details: bool = False   # recommend keeping False; use /place-details instead
    prefer_low_traffic: float = 0.0 # defaults off


class PlaceOut(BaseModel):
    place_id: Optional[str] = None

    name: Optional[str] = None
    address: Optional[str] = None
    categories: List[str] = []

    lat: float
    lon: float
    distance_m: Optional[float] = None

    # traffic signals
    route_length_m: Optional[int] = None
    travel_time_s: Optional[int] = None
    traffic_delay_s: Optional[int] = None
    traffic_length_m: Optional[int] = None

    # details (only filled if include_details=True)
    opening_hours: Optional[Dict[str, Any]] = None
    phone: Optional[str] = None
    website: Optional[str] = None

    score: float


# -----------------------------
# Helpers
# -----------------------------

def norm01(x: float, max_x: float) -> float:
    """Normalize to 0..1 with clamping. Returns 0.5 for invalid max."""
    if max_x <= 0:
        return 0.5
    return max(0.0, min(x / max_x, 1.0))


def geoapify_places(req: RecommendRequest) -> Dict[str, Any]:
    if not GEOAPIFY_KEY:
        raise HTTPException(status_code=500, detail="Missing GEOAPIFY_API_KEY env var")

    params = {
        "categories": ",".join(req.categories),
        "filter": f"circle:{req.lon},{req.lat},{req.radius_m}",
        "bias": f"proximity:{req.lon},{req.lat}",
        "limit": req.limit,
        "apiKey": GEOAPIFY_KEY,
    }

    r = requests.get(GEOAPIFY_PLACES_URL, params=params, timeout=10)
    if r.status_code != 200:
        raise HTTPException(status_code=502, detail=f"Geoapify error: {r.text}")
    return r.json()


def geoapify_place_details(place_id: str) -> Dict[str, Any]:
    if not GEOAPIFY_KEY:
        raise HTTPException(status_code=500, detail="Missing GEOAPIFY_API_KEY env var")

    params = {"id": place_id, "apiKey": GEOAPIFY_KEY}
    r = requests.get(GEOAPIFY_DETAILS_URL, params=params, timeout=10)
    if r.status_code != 200:
        raise HTTPException(status_code=502, detail=f"Geoapify place-details error: {r.text}")

    data = r.json()
    feats = data.get("features", [])
    if not feats:
        raise HTTPException(status_code=404, detail="No details found for place_id")

    return feats[0].get("properties", {})


def tomtom_traffic(user_lat: float, user_lon: float, dest_lat: float, dest_lon: float) -> Dict[str, int]:
    if not TOMTOM_KEY:
        raise HTTPException(status_code=500, detail="Missing TOMTOM_API_KEY env var")

    url = f"https://api.tomtom.com/routing/1/calculateRoute/{user_lat},{user_lon}:{dest_lat},{dest_lon}/json"
    params = {"key": TOMTOM_KEY, "traffic": "true"}
    r = requests.get(url, params=params, timeout=10)

    if r.status_code != 200:
        raise HTTPException(status_code=502, detail=f"TomTom routing error: {r.text}")

    data = r.json()
    routes = data.get("routes") or []
    if not routes:
        raise HTTPException(status_code=502, detail="TomTom routing error: no routes returned")

    summary = routes[0].get("summary") or {}
    return {
        "route_length_m": int(summary.get("lengthInMeters", 0)),
        "travel_time_s": int(summary.get("travelTimeInSeconds", 0)),
        "traffic_delay_s": int(summary.get("trafficDelayInSeconds", 0)),
        "traffic_length_m": int(summary.get("trafficLengthInMeters", 0)),
    }


def simple_score(feature: Dict[str, Any], req: RecommendRequest, traffic: Optional[Dict[str, int]] = None) -> float:
    """
    Ranking:
    - closer is better
    - higher rating is better (when available)
    - lower travel time is better (optional traffic weighting)
    """
    props = feature.get("properties", {})
    dist = props.get("distance")  # meters

    # distance -> higher is better
    if dist is None:
        close_score = 0.5
    else:
        close_score = max(0.0, 1.0 - min(dist, req.radius_m) / float(req.radius_m))

    rating = props.get("rating")
    if isinstance(rating, (int, float)):
        rating_score = max(0.0, min(float(rating) / 5.0, 1.0))
    else:
        rating_score = 0.5

    # traffic -> higher is better (shorter travel time)
    # If include_traffic is enabled but this place has no traffic data, give a slight penalty
    if req.include_traffic and (traffic is None or traffic.get("travel_time_s") is None):
        traffic_score = 0.45
    else:
        traffic_score = 0.5

    if traffic is not None and traffic.get("travel_time_s") is not None:
        # Normalize travel time relative to 20 minutes
        travel_norm = norm01(float(traffic["travel_time_s"]), 20.0 * 60.0)
        traffic_score = 1.0 - travel_norm

    return (
        req.prefer_close * close_score
        + req.prefer_high_rating * rating_score
        + req.prefer_low_traffic * traffic_score
    )


def _extract_candidates(data: Dict[str, Any]) -> List[Tuple[Dict[str, Any], Dict[str, Any], float, float]]:
    feats = data.get("features", []) or []
    candidates: List[Tuple[Dict[str, Any], Dict[str, Any], float, float]] = []
    for f in feats:
        props = f.get("properties", {}) or {}
        coords = (f.get("geometry", {}) or {}).get("coordinates", [None, None])
        lon, lat = coords[0], coords[1]
        if lon is None or lat is None:
            continue
        candidates.append((f, props, float(lat), float(lon)))
    return candidates


# -----------------------------
# Routes
# -----------------------------

@app.post("/recommendations", response_model=List[PlaceOut])
def recommendations(req: RecommendRequest):
    data = geoapify_places(req)
    candidates = _extract_candidates(data)

    # Compute traffic for closest K only (keeps latency reasonable)
    traffic_by_place: Dict[str, Dict[str, int]] = {}

    if req.include_traffic:
        candidates_sorted = sorted(
            candidates,
            key=lambda t: (t[1].get("distance") is None, t[1].get("distance", 10**18))
        )
        K = min(len(candidates_sorted), 10)

        for (f, props, lat, lon) in candidates_sorted[:K]:
            pid = props.get("place_id")
            if not pid:
                continue
            try:
                tinfo = tomtom_traffic(req.lat, req.lon, lat, lon)
                traffic_by_place[pid] = tinfo
            except HTTPException:
                # Don't fail the entire request if one route fails
                continue

    out: List[PlaceOut] = []
    for (f, props, lat, lon) in candidates:
        pid = props.get("place_id")
        tinfo = traffic_by_place.get(pid) if pid else None
        score = simple_score(f, req, traffic=tinfo)

        out.append(
            PlaceOut(
                place_id=pid,
                name=props.get("name"),
                address=props.get("formatted") or props.get("address_line2"),
                categories=props.get("categories", []) or [],
                lat=lat,
                lon=lon,
                distance_m=props.get("distance"),
                route_length_m=(tinfo or {}).get("route_length_m"),
                travel_time_s=(tinfo or {}).get("travel_time_s"),
                traffic_delay_s=(tinfo or {}).get("traffic_delay_s"),
                traffic_length_m=(tinfo or {}).get("traffic_length_m"),
                score=score,
            )
        )

    # Sort by score desc
    out.sort(key=lambda p: p.score, reverse=True)

    # Optional: enrich details for top K ONLY (recommended off; use /place-details instead)
    if req.include_details:
        top_k = min(len(out), 6)
        for i in range(top_k):
            pid = out[i].place_id
            if not pid:
                continue
            try:
                props = geoapify_place_details(pid)
                contact = props.get("contact") or {}
                out[i].opening_hours = props.get("opening_hours")
                out[i].phone = contact.get("phone")
                out[i].website = props.get("website")
            except HTTPException:
                continue

    return out[: min(len(out), 12)]


@app.get("/place-details/{place_id}")
def place_details(place_id: str) -> Dict[str, Any]:
    props = geoapify_place_details(place_id)
    contact = props.get("contact") or {}

    return {
        "place_id": place_id,
        "opening_hours": props.get("opening_hours"),
        "phone": contact.get("phone"),
        "website": props.get("website"),
    }