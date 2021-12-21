from pathlib import Path
import logging as l

#Import Extractors
import extracts.distrokid
import extracts.spotify_for_artists

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
        'playlists' : data_dir + "playlists-last5years.csv"
    }

    #Create extractors
    distrokid = extracts.distrokid.Distrokid(filenames['distrokid'])
    spotify_for_artists = extracts.spotify_for_artists.SpotifyForArtists((filenames['recordings'], "N/A"), (filenames['playlists'], "N/A"), (filenames['audience'], "N/A"))

    #Test
    print(distrokid.GetDataframe())
    print(spotify_for_artists.GetRecordingsDataframe())
    print(spotify_for_artists.GetPlaylistsDataframe())
    print(spotify_for_artists.GetAudienceDataframe())
