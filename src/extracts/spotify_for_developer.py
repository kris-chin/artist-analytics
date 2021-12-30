#Data Handling Imports
import pandas
import logging as l 
import requests as r

class SpotifyForDevelopers:

    def __init__(self, authToken):
        if authToken == None:
            l.error("Failed to Initalize SpotifyForDevelopers Pipeline")
        else:
            self.authToken = authToken
    
    #Private Methods for making API calls. We don't want to be using these directly, instead, we'll call these in bulk for a "Complete" Extaction
    def __MakeAPICall(self, endpoint, query=None):
        try:
            l.debug("Attempting to make API call to spotify")
            
            #Set up Header
            headers={'Authorization' : "Bearer " + self.authToken}

            #Make the appropriate GET request
            if query == None: re = r.get(endpoint, headers=headers)
            else: re = r.get(endpoint, params=query, headers=headers)

            if re.status_code == 404: l.error("ERROR 404")
            elif re.status_code == 400: l.error("ERROR 400:" + re.text)
            else: return eval(re.text.replace('true',"True").replace('false',"False")) #Return response as a JSON object
        except Exception as e:
            l.error("API Call recieved an error:")
            l.error(e)