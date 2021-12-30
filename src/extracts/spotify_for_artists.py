import pandas
import logging as l
from typing import Tuple

#Spotify for Artists extractor (specifically, CSVs)
class SpotifyForArtists:

    #recordings_all = tuple of ALL song-data pathname and source date
    #playlists_all = tuple of ALL playlist-data pathname and source date
    #audience_timeline = tuple of ALL audience timeline and source date
    def __init__(self, recordings_all: Tuple[str, str], playlists_all: Tuple[str, str], audience_timeline: Tuple[str, str]):
        
        #Read SpotifyForArtists CSVS
        #The code's kinda crappy looking but it works

        #Recordings CSV
        try:
            l.debug("Attempting to read recordings csv")
            self.recordings_dataframe = pandas.read_csv(recordings_all[0])
            l.debug("Successfully read recordings csv")
        except Exception as e:
            l.error("error")
            l.error(e)
        
        #Playlists CSV
        try:
            l.debug("Attempting to read playlists csv")
            self.playlists_dataframe = pandas.read_csv(playlists_all[0])
            l.debug("Successfully read playlists csv")
        except Exception as e:
            l.error("error")
            l.error(e)

        #Audience CSV
        try:
            l.debug("Attempting to read audience csv")
            self.audience_dataframe = pandas.read_csv(audience_timeline[0])
            l.debug("Successfully read audience csv")
        except Exception as e:
            l.error("error")
            l.error(e)

    def GetRecordingsDataframe(self): return self.recordings_dataframe
    def GetPlaylistsDataframe(self): return self.playlists_dataframe
    def GetAudienceDataframe(self): return self.audience_dataframe