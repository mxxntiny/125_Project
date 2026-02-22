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

def get_user_pref():
    ''' Simulates user profile via dictionary. Keys represent time and values represent secondary dectionaries, where the key is an event and the value is the number of times the
    user had frequesnted that location at the given time.'''
    user_sim = {1:{"Study":2,"Nightlife":4, "Entertainment":3}, 2:{"Study":1, "Nightlife":2}, 3:{"Study":1, "Nightlife":1}, 4:{"Study":1}, 5:{"Study":2, "Fitness":2}, 6:{"Study":2, "Fitness": 3}, 7:{"Coffee":3, "Food":2,"Study":1, "Fitness":5}, 8:{"Coffee":5,"Food":3, "Study":1,}, 9:{"Coffee":2,"Study":3,}, 10:{"Study":3,}, 11:{"Study":4,}, 12:{"Coffee":3,"Food":6, "Study":1,"Outdoors":3}, 13:{"Food":4, "Study":2,"Dessert":2, "Parks":4}, 14:{"Study":2,}, 15:{"Study":4,}, 16:{"Study":5,}, 17:{"Study":3,"Shopping":4, "Dessert":4}, 18:{"Food":3, "Outdoors":3, "Shopping":5}, 19:{"Food":5, "Outdoors":4}, 20:{"Food":3, "Fitness" :4, "Outdoors":2}, 21:{"Fitness":5, "Entertainment":7, "Parks":5}, 22:{"Fitness":3, "Nightlife":5, "Entertainment" :4}, 23:{"Study":2, "Nightlife":4, "Entertainment" :3}, 24:{"Study":2, "Nightlife":3, "Dessert":1}}
    time_obj = time.localtime()
    vals_list = user_sim[time_obj.tm_hour + (time_obj.tm_min > 30)]
    return(sorted(vals_list.items(), key=lambda item:item[1])[-1][0])



