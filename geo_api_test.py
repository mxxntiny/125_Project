import requests
from requests.structures import CaseInsensitiveDict

url = "https://api.geoapify.com/v2/places" 
url2 = "https://api.geoapify.com/v2/place-details" 
url_traffic = "https://api.tomtom.com/routing/1/calculateRoute/"

temp_coords = "rect:-118.65,33.7,-118.15,34.35"
temp_category = "activity"
temp_id = '51ea4280a78c925dc059b1316ca57c014140f00102f901070448180000000092031e41686d616e736f6e2053656e696f7220436974697a656e2043656e746572'
user_coords = "-118.3327632, 34.10056279960511"
temp_place_coords = [-118.18443118951402, 34.11456164960562]

def get_places(coords, category): 
    '''
    uses geoapify to receive list of places of a specific type within a given radius.
    coords: coordinate boundary for search
    category: category of buildings to search for
    
    returns: list in the format - [name, place id, address, coordinates]
    '''

    headers = CaseInsensitiveDict()
    parameters = { "categories": category, "filter":coords, "apiKey": "b6b15a13f59141b18477d0ec22515d72"}
    headers["Accept"] = "application/json"

    resp = requests.get(url, headers=headers, params=parameters)
    resultDict = resp.json()
    places = []
    for value in resultDict["features"]:
        places.append([value['properties']['name'], value['properties']['place_id'], value['properties']["address_line2"],value['geometry']["coordinates"]])

    print(places) #temp, to see output
    return places

def get_place_details(id):
    '''
    takes in place id and gets detailed information about the locations using geoapify
    id: geoapify id of place to get information on.
    '''

    headers = CaseInsensitiveDict()
    headers["Accept"] = "application/json"
    parameters = {"id": id,"apiKey":"b6b15a13f59141b18477d0ec22515d72"}

    resp= requests.get(url2, headers=headers, params=parameters)
    resultDict = resp.json()

    shorter = resultDict['features'][0]['properties']                                 #api will always pass back only one set of information > index at 0 ok
    info = [shorter['opening_hours'], shorter['contact']['phone'], shorter["website"]]
    print(info)         
    return info


def traffic_info(usr, place):
    '''
    usr: string format coords
    place: list format coords
    takes in user and place coords to calculate traffic info
    returns list with four values as follows: route length in meters, travel time in seconds, traffic delay in seconds, traffic length in meters
    '''
    traffic_header = CaseInsensitiveDict()
    traffic_header["Accept"] = "application/json"
    
    
    user_lon, user_lat = map(float, usr.split(","))
    loc_lon, loc_lat = place[0], place[1]
    
    url = (f"https://api.tomtom.com/routing/1/calculateRoute/{user_lat},{user_lon}:{loc_lat},{loc_lon}/json")
    trafic_params = {"key": "pUACVZd4orSo7d0aaomcDlDczqFQPfa2", "traffic": "true"}

    traffic_response = requests.get(url, headers=traffic_header, params=trafic_params)

    result_traffic_Dict = traffic_response.json()

    base = result_traffic_Dict['routes'][0]['summary']
    return [base['lengthInMeters'], base['travelTimeInSeconds'], base['trafficDelayInSeconds'], base['trafficLengthInMeters']]

#get_places(temp_coords, temp_category)
#get_place_details(temp_id)
#traffic_info(user_coords, temp_place_coords)
