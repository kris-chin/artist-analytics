#Contains Functions for Generating Authorization Tokens for API-Related pipelines

import logging as l
import requests as r
from base64 import b64encode
from dotenv import load_dotenv
from os import environ

def GenerateSpotifyAuthToken() -> str :
    
    #Load Sensitive Data
    load_dotenv()
    client_id = environ.get('CLIENT_ID')
    client_secret = environ.get('CLIENT_SECRET')

    #Set up our Authorization Token
    auth_options = {
        'url' : 'https://accounts.spotify.com/api/token',
        'headers' : {
            'Authorization': 'Basic ' + b64encode( (client_id + ':' + client_secret).encode() ).decode("ascii")
        },
        'form': {
            'grant_type' : 'client_credentials'
        },
        'json' : True
    }

    try: #Try/Catch code for network errors specifically
        response = r.post(auth_options['url'], auth_options['form'], auth_options['json'], headers=auth_options['headers'])
    except Exception as e:
        l.error("error")
        l.error(e)
    
    #Convert to Json
    re = eval(response.text)
    try:
        l.debug("Successfully generated token")
        return re['access_token']
    except KeyError as e:
        l.error("Invalid Token Generated")
        return None
