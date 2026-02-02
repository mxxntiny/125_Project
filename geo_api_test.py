import requests
from requests.structures import CaseInsensitiveDict

url = "https://api.geoapify.com/v2/places" 
url2 = "https://api.geoapify.com/v2/place-details" 
url_traffic = "https://api.tomtom.com/routing/1/calculateRoute/"

'''


headers = CaseInsensitiveDict()
parameters = { "categories": "activity", "filter":"rect:-118.65,33.7,-118.15,34.35", "apiKey": "b6b15a13f59141b18477d0ec22515d72"}
headers["Accept"] = "application/json"

resp = requests.get(url, headers=headers, params=parameters)
resultDict = resp.json()
print(resultDict)

###
#get first object to pass into places details
pass_in = resultDict['features'][0]['properties']['place_id']


headers2 = CaseInsensitiveDict()
headers2["Accept"] = "application/json"
parameters2 = {"id": pass_in,"apiKey":"b6b15a13f59141b18477d0ec22515d72"}

resp2= requests.get(url2, headers=headers2, params=parameters2)
resultDict2 = resp2.json()
print(resultDict2)
'''
temp_resp = {'type': 'FeatureCollection', 'features': [{'type': 'Feature', 'properties': {'feature_type': 'details', 'website': 'https://www.laparks.org/reccenter', 'opening_hours': 'Mo-Fr 09:00-22:00; Sa 09:00-20:00', 'operator': 'City of Los Angeles Department of Recreation and Parks', 'name': 'Westwood Recreation Center', 'ele': 99.7, 'contact': {'phone': '310-473-3610', 'email': 'WESTWOOD.RECREATIONCENTER@LACITY.ORG', 'fax': '310-575-8011'}, 'wiki_and_media': {'wikipedia': 'en:Westwood, Los Angeles#Parks and recreation'}, 'building': {'height': 11.9}, 'categories': ['activity', 'activity.community_center', 'building', 'building.public_and_civil', 'building.sport'], 'datasource': {'sourcename': 'openstreetmap', 'attribution': '© OpenStreetMap contributors', 'license': 'Open Database License', 'url': 'https://www.openstreetmap.org/copyright', 'raw': {'ele': 99.7, 'fax': '310-575-8011', 'name': 'Westwood Recreation Center', 'email': 'WESTWOOD.RECREATIONCENTER@LACITY.ORG', 'phone': '310-473-3610', 'sport': 'basketball', 'height': 11.9, 'osm_id': 425139610, 'amenity': 'community_centre', 'website': 'https://www.laparks.org/reccenter', 'building': 'yes', 'operator': 'City of Los Angeles Department of Recreation and Parks', 'osm_type': 'w', 'addr:city': 'Los Angeles', 'amenity_1': 'swimming_pool', 'wikipedia': 'en:Westwood, Los Angeles#Parks and recreation', 'addr:state': 'CA', 'addr:street': 'Sepulveda Boulevard', 'lacounty:ain': 4324017904, 'addr:district': 5, 'addr:postcode': 90025, 'opening_hours': 'Mo-Fr 09:00-22:00; Sa 09:00-20:00', 'lacounty:bld_id': 425936842033, 'addr:housenumber': 1350, 'addr:neighbourhood': 'West Los Angeles'}}, 'housenumber': '1350', 'street': 'South Sepulveda Boulevard', 'city': 'Los Angeles', 'county': 'Los Angeles County', 'state': 'California', 'postcode': '90025', 'country': 'United States', 'country_code': 'us', 'formatted': 'Westwood Recreation Center, 1350 South Sepulveda Boulevard, Los Angeles, CA 90025, United States of America', 'address_line1': 'Westwood Recreation Center', 'address_line2': '1350 South Sepulveda Boulevard, Los Angeles, CA 90025, United States of America', 'lat': 34.05323525, 'lon': -118.44807798641105, 'iso3166_2': 'US-CA', 'timezone': {'name': 'America/Los_Angeles', 'offset_STD': '-08:00', 'offset_STD_seconds': -28800, 'offset_DST': '-07:00', 'offset_DST_seconds': -25200, 'abbreviation_STD': 'PST', 'abbreviation_DST': 'PDT'}, 'place_id': '51586c4a4fad9c5dc0594805a469d0064140f00102f9019a1d57190000000092031a57657374776f6f642052656372656174696f6e2043656e746572'}, 'geometry': {'type': 'Polygon', 'coordinates': [[[-118.4485584, 34.0534379], [-118.4484604, 34.0533225], [-118.4485244, 34.0532848], [-118.4483968, 34.0531345], [-118.4483897, 34.0531386], [-118.4483994, 34.0531501], [-118.448339, 34.0531857], [-118.4483162, 34.0531589], [-118.4482996, 34.0531686], [-118.4482463, 34.0531058], [-118.448262, 34.0530965], [-118.4480237, 34.0528159], [-118.4479503, 34.0528591], [-118.4479185, 34.0528293], [-118.4479076, 34.0528234], [-118.4478785, 34.0528144], [-118.4478495, 34.0528185], [-118.4478357, 34.0528248], [-118.4478229, 34.052832], [-118.4478119, 34.0528421], [-118.4478035, 34.0528537], [-118.4477958, 34.0528682], [-118.447794, 34.0528945], [-118.4477992, 34.0529068], [-118.4478043, 34.0529231], [-118.4475988, 34.0530429], [-118.4476488, 34.0531024], [-118.4476634, 34.0530939], [-118.4476808, 34.0531147], [-118.447608, 34.0531572], [-118.4477746, 34.0533553], [-118.4478205, 34.0533286], [-118.4479134, 34.053439], [-118.4479148, 34.0534382], [-118.4480855, 34.0536412], [-118.4481094, 34.0536646], [-118.4481235, 34.0536716], [-118.44814, 34.0536761], [-118.4481498, 34.0536768], [-118.4481729, 34.0536718], [-118.4481922, 34.0536609], [-118.4482005, 34.0536501], [-118.448207, 34.0536364], [-118.4482083, 34.0536246], [-118.4482048, 34.053612], [-118.4481958, 34.053599], [-118.4481798, 34.0535799], [-118.4482409, 34.0535453], [-118.4482847, 34.0535989], [-118.4485584, 34.0534379]]]}}]}
###
traffic_header = CaseInsensitiveDict()
traffic_header["Accept"] = "application/json"

user_coords = "-118.3327632, 34.10056279960511" #TEMP VALUE
location_coords = temp_resp['features'][0]['geometry']['coordinates'][0][0] #formatted as geometry > 'coordinates'> [-118.44807798641102, 34.05323524960346] in geo_api

trafic_params = {"versionNumber": 1,"routePlanningLocations":[{"latitude": user_coords[0], "longitude": user_coords[1]},{"latitude": location_coords[0], "longitude": location_coords[1]}],"computeTravelTimeFor":"liveTrafficIncidentsTravelTimeInSeconds","apiKey":"pUACVZd4orSo7d0aaomcDlDczqFQPfa2"}

user_lon, user_lat = map(float, user_coords.split(","))

loc_lon, loc_lat = location_coords[0], location_coords[1]
url_traffic = f"https://api.tomtom.com/routing/1/calculateRoute/{user_lat},{user_lon}:{loc_lat},{loc_lon}/json"
trafic_params = {"key": "pUACVZd4orSo7d0aaomcDlDczqFQPfa2", "traffic": "true"}

traffic_response = requests.get(url_traffic, headers=traffic_header, params=trafic_params)

result_traffic_Dict = traffic_response.json()
print(result_traffic_Dict)


'''
#code to see all places passed in:

for val in resultDict['features']:
    print(val['properties']['name'])
'''

