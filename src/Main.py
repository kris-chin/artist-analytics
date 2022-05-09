from pathlib import Path
import logging as l

#Import Pandas for Merging Data
import pandas as pd

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
    extractors = []

    distrokid = Distrokid(filenames['distrokid'])
    extractors.append(distrokid)

    spotify_for_artists = SpotifyForArtists((filenames['recordings'], "N/A"), (filenames['playlists'], "N/A"), (filenames['audience'], "N/A"))
    extractors.append(spotify_for_artists)

    #Attempt to authenticate SpotifyForDevelopers
    try:
        spotify_for_developers = SpotifyForDevelopers(Auth.GenerateSpotifyAuthToken())
    except ValueError:
        spotify_for_developers = None
    extractors.append(spotify_for_developers)

    symphonic = Symphonic(filenames['symphonic'])
    extractors.append(symphonic)

    ascap = Ascap(filenames['ascap'])
    extractors.append(ascap)

    #Get dataframes from all pipelines and perform an full outer join on them
    l.debug("Collecting Dataframes...")

    #Start with a standard dataframe with all standardized columns
    merged_dataframe = pd.DataFrame({
        'artist': [],
        'reporting_date' : [],
        'song_title' : []

    })

    for extractor in extractors:
        if (extractor == None): continue
        try:
            dataframe = extractor.GetDataframe()
            #merge this dataframe with our existing dataframe
            merged_dataframe = pd.merge(merged_dataframe, dataframe, how="outer")
            l.debug("[" + str(type(extractor).__name__) + "]: Successfully merged data")
        except AttributeError as e:
            l.error(e)
        except pd.errors.MergeError as e:
            l.error("[" + str(type(extractor).__name__) +"]: " + str(e))

    #We have a pre-existing path variable still in this script
    dataframe_path = str(p) + "/output/"
    filename = dataframe_path + "merged_dataframe.csv"

    #actually write csv
    try:
        merged_dataframe.to_csv(filename)

        l.debug("Successfully wrote to '" + filename + "'")
    except:
        l.error("Failed to write dataframe to csv")