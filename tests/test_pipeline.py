#Loads any Pipeline that extends the Abstract_Pipeline.
#Runs tests for if can be encorporated into the pipeline
#
#
#====================================================
from src.pipelines import * #Import all of our Pipelines
from src import Auth #SpotifyForDevleopers Authorization Token

import pytest

import pandas
from pathlib import Path

#Get Data Directory
p = str(Path('.').resolve().parents[0]) + "/data/"

#Create dict of filenames
f = {
    'distrokid' : p + "DistroKid.tsv",
    'recordings' : p + "recordings-all.csv",
    'audience' : p + "timelines.csv",
    'playlists' : p + "playlists-last5years.csv",
    'symphonic' : p + "symphonic.csv",
    'ascap' : p + 'ascap.csv'
}


#Set up Pipeline list
pipelines = [
    Distrokid(f['distrokid'])
    #SpotifyForArtists((f['recordings'], "N/A"), (f['playlists'], "N/A"), (f['audience'], "N/A")),
    #SpotifyForDevelopers(Auth.GenerateSpotifyAuthToken()),
    #Symphonic(f['symphonic'])
    #Ascap(f['ascap'])
]

#===================================================================================================

#This test suite contains all tests every pipeline must go through in order to be deemed acceptable
#These are tests that make sure that the crucial columns are standardized.
@pytest.mark.parametrize("pipeline", pipelines) #Pass in every single pipeline we have into this suite
class TestPipeline:

    #This suite is for pipeline meta
    @pytest.mark.dependency(name="meta")
    class TestMeta:

        #Does the pipeline have a name value?
        @pytest.mark.dependency()
        def test_HasName(self,pipeline:Pipeline):
            assert pipeline.name

        #Does the pipeline provide a dataframe that has data?
        @pytest.mark.dependency()
        def test_HasDataframe(self, pipeline: Pipeline):
            assert pipeline.GetDataframe().empty == False

        #Does the pipeline provide acesss-dates for its data?
        @pytest.mark.dependency()
        def test_HasSourceDates(self, pipeline: Pipeline):
            assert pipeline.sourceDate

    #===================================================================================================

    #Suite for Pipeline formatting
    @pytest.mark.skip(reason="Test not written yet")
    class TestFormatting:

        #This test suite contains all tests regarding the Date Column Fromatting
        #This is specifically TIME data. not RELEASE DATE data
        class TestDate:

            #Does the Pipeline have a properly-formatted Date Column?
            def test_IsDateFormatted(self, pipeline: Pipeline):
                assert 1

            #
            def test_IsTimeFormatted(self, pipeline: Pipeline):
                assert 1

        #This test suite contains all tests regarding Song Title Column
        class TestSongTitle:
            
            #Does the Song Title Column have the right name?
            def test_IsColumnFormatted(self, pipeline: Pipeline):
                assert 1

        class TestStreamCount:

            #Does the Streams Column have the right name?
            def test_IsStreamsFormatted(self, pipeline: Pipeline):
                assert 1

        class TestISRC:

            #Does the ISRC Column have the right name?
            def test_IsISRCFormatted(self, pipeline: Pipeline):
                assert 1

        class TestReleaseDate:

            #Does the Release Date column have the right name?
            def test_IsReleaseDateFormatted(self, pipeline: Pipeline):
                assert 1

        class TestArtistName:

            #Does the Artist Name colum have the correct name?
            def test_IsArtistNameFormatted(self, pipeline: Pipeline):
                assert 1

    #===================================================================================================

    #This Suite is for tests on the overall dataframe
    @pytest.mark.dependency(name="dataframe",depends=["meta"])
    @pytest.mark.skip(reason="Test not written yet")
    class TestDataframe:

        #Contains any of the above column names. (Can we even work with the data?)
        @pytest.mark.dependency()
        def test_HasJoinableData(self, pipeline: Pipeline):
            print("This pipeline has joinable data:")
            print(pipeline)
            assert 1
