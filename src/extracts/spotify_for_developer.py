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
    
    def GetSongData(self, song_id: str):
        try:
            l.debug("Attempting to make API call to spotify")
            re = r.get("https://api.spotify.com/v1/tracks/" + song_id, headers={'Authorization' : "Bearer " + self.authToken})
            if re.status_code == 404: l.error("ERROR 404")
            else: return eval(re.text.replace('true',"True").replace('false',"False")) #Return response as a JSON object
        except Exception as e:
            l.error("API Call recieved an error:")
            l.error(e)