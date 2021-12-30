#Data Handling Imports
import pandas
import logging as l 
import requests as r

class SpotifyForDevelopers:

    def __init__(self, authToken: str):
        if authToken == None:
            l.error("Failed to Initalize SpotifyForDevelopers Pipeline")
        else:
            self.authToken = authToken
    
    #Private Methods for making API calls. We don't want to be using these directly, instead, we'll call these in bulk for a "Complete" Extaction
    def __MakeAPICall(self, endpoint : str, query=None):
        try:
            l.debug("Attempting to make API call to spotify")
            
            #Set up Header
            headers={'Authorization' : "Bearer " + self.authToken}

            #Make the appropriate GET request
            if query == None: re = r.get(endpoint, headers=headers)
            else: re = r.get(endpoint, params=query, headers=headers)

            if re.status_code == 404: l.error("ERROR 404")
            elif re.status_code == 400: l.error("ERROR 400:" + re.text)
            else: return eval(re.text.replace('true',"True").replace('false',"False").replace('null',"None")) #Return response as a JSON object
        except Exception as e:
            l.error("API Call recieved an error:")
            l.error(e)

    #Gets Tracks and their Audio Features
    def GetTracks(self, id_list: list): #MAX: 50

        #Spotify API URL
        v1 = "https://api.spotify.com/v1/"

        if len(id_list) > 50:
            l.error("Spotify API limits to 50 tracks")
            return None
        
        #Create a single string of the list items seperated by commas for use with the API
        ids = "".join( [',' + item for item in id_list]  )[1:]
        
        #Make API Calls
        track_info = self.__MakeAPICall(v1 + "tracks", query={'ids': ids})
        track_features = self.__MakeAPICall(v1 + "audio-features", query={'ids' : ids})

        #Return our call results in an object
        return {
            'track_info' : track_info,
            'track_features' : track_features
        }

    #Gets a Single Artist and Their Related Artists
    def GetArtist(self, id):

        #Spotify API URL
        v1 = "https://api.spotify.com/v1/"

        #Make API Calls
        artist_info = self.__MakeAPICall(v1 + "artists/" + id)
        related_artists = self.__MakeAPICall(v1 + "artists/" + id + "/related-artists")

        #Return our call results in an object
        return {
            'artist_info' : artist_info,
            'related_artists' : related_artists
        }