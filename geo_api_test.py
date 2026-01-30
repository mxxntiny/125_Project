import requests
from requests.structures import CaseInsensitiveDict

url = "https://api.geoapify.com/v2/places" 
url2 = "https://api.geoapify.com/v2/place-details" 



headers = CaseInsensitiveDict()
parameters = {
    "categories": "activity",
    "filter":"rect:-118.65,33.7,-118.15,34.35",
    "apiKey": "b6b15a13f59141b18477d0ec22515d72"
    }
headers["Accept"] = "application/json"

resp = requests.get(url, headers=headers, params=parameters)
resultDict = resp.json()
print(resultDict)

#get first object to pass into places details

pass_in = resultDict['features'][0]['properties']['place_id']


headers2 = CaseInsensitiveDict()
headers2["Accept"] = "application/json"
parameters2 = {
    "id": pass_in,
    "apiKey":"b6b15a13f59141b18477d0ec22515d72"
    }

resp2= requests.get(url2, headers=headers2, params=parameters2)
resultDict2 = resp2.json()
print(resultDict2)



'''
#code to see all places passed in:

for val in resultDict['features']:
    print(val['properties']['name'])
'''