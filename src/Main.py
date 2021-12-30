from pathlib import Path
import logging as l

#Import Authorization Functions
import Auth

#Import ETL Pipelines
from pipelines import Distrokid
from pipelines import SpotifyForArtists
from pipelines import SpotifyForDevelopers
from pipelines import Symphonic
from pipelines import Ascap

if __name__ == "__main__":

    #Set logger to debug
    l.basicConfig(level = l.DEBUG)
    
    #get main directory
    p = Path('.').resolve().parents[0]
    data_dir = str(p) + "/data/"
    #Create dict of filenames
    filenames = {
        'distrokid' : data_dir + "DistroKid.tsv",
        'recordings' : data_dir + "recordings-all.csv",
        'audience' : data_dir + "timelines.csv",
        'playlists' : data_dir + "playlists-last5years.csv",
        'symphonic' : data_dir + "symphonic.csv",
        'ascap' : data_dir + 'ascap.csv'
    }

    #Create extractors
    distrokid = Distrokid(filenames['distrokid'])
    spotify_for_artists = SpotifyForArtists((filenames['recordings'], "N/A"), (filenames['playlists'], "N/A"), (filenames['audience'], "N/A"))
    spotify_for_developers = SpotifyForDevelopers(Auth.GenerateSpotifyAuthToken())
    symphonic = Symphonic(filenames['symphonic'])
    ascap = Ascap(filenames['ascap'])