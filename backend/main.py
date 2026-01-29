import os
import requests

from typing import List, Optional, Dict, Any

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

from dotenv import load_dotenv
load_dotenv()

GEOAPIFY_KEY = os.getenv("GEOAPIFY_API_KEY")
print("Geoapify key loaded:", bool(GEOAPIFY_KEY))

GEOAPIFY_PLACES_URL = "https://api.geoapify.com/v2/places"


app = FastAPI(title="Your Places Backend")


class RecommendRequest(BaseModel):
    lat: float
    lon: float
    radius_m: int = Field(1500, ge=100, le=20000)
    limit: int = Field(20, ge=1, le=100)
    categories: List[str] = Field(
        default_factory=lambda: ["catering.restaurant", "catering.cafe"]
    )

    # Optional knobs you can use later for ranking
    prefer_close: float = 0.6  # weight in [0..1]
    prefer_high_rating: float = 0.4  # weight in [0..1]


class PlaceOut(BaseModel):
    name: Optional[str] = None
    address: Optional[str] = None
    categories: List[str] = []
    lat: float
    lon: float
    distance_m: Optional[float] = None
    score: float


def geoapify_places(req: RecommendRequest) -> Dict[str, Any]:
    if not GEOAPIFY_KEY:
        raise HTTPException(status_code=500, detail="Missing GEOAPIFY_API_KEY env var")

    # Geoapify expects filter=circle:lon,lat,radius and bias=proximity:lon,lat
    params = {
        "categories": ",".join(req.categories),
        "filter": f"circle:{req.lon},{req.lat},{req.radius_m}",
        "bias": f"proximity:{req.lon},{req.lat}",
        "limit": req.limit,
        "apiKey": GEOAPIFY_KEY,
    }

    print("Calling Geoapify with categories:", req.categories)
    r = requests.get(GEOAPIFY_PLACES_URL, params=params, timeout=10)
    if r.status_code != 200:
        raise HTTPException(status_code=502, detail=f"Geoapify error: {r.text}")
    return r.json()


def simple_score(feature: Dict[str, Any], req: RecommendRequest) -> float:
    """
    A starter ranking:
    - closer is better (uses Geoapify 'distance' when available)
    - you can extend this with rating, amenities, etc.
    """
    props = feature.get("properties", {})
    dist = props.get("distance")  # meters (often provided when bias is used)

    # Normalize distance to 0..1 (closer -> higher).
    if dist is None:
        close_score = 0.5
    else:
        close_score = max(0.0, 1.0 - min(dist, req.radius_m) / float(req.radius_m))

    # Geoapify Places response varies by dataset; "rating" may not always exist.
    rating = props.get("rating")
    if isinstance(rating, (int, float)):
        rating_score = max(0.0, min(float(rating) / 5.0, 1.0))
    else:
        rating_score = 0.5

    return req.prefer_close * close_score + req.prefer_high_rating * rating_score


@app.post("/recommendations", response_model=List[PlaceOut])
def recommendations(req: RecommendRequest):
    data = geoapify_places(req)
    feats = data.get("features", [])

    out: List[PlaceOut] = []
    for f in feats:
        props = f.get("properties", {})
        geom = f.get("geometry", {})
        coords = geom.get("coordinates", [None, None])  # [lon, lat]

        lon, lat = coords[0], coords[1]
        if lon is None or lat is None:
            continue

        score = simple_score(f, req)

        out.append(
            PlaceOut(
                name=props.get("name"),
                address=props.get("formatted") or props.get("address_line2"),
                categories=props.get("categories", []) or [],
                lat=float(lat),
                lon=float(lon),
                distance_m=props.get("distance"),
                score=score,
            )
        )

    # Sort by score desc
    out.sort(key=lambda p: p.score, reverse=True)
    return out[: min(len(out), 12)]
