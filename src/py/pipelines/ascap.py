from .abstract_pipeline import Pipeline

import pandas
import logging as l

class Ascap(Pipeline):

    #path = file path
    #source_date = date of source
    def __init__(self, path: str, source_date:str = "N/A"):
        try:
            l.debug("Attempting to read ASCAP csv...")
            self.__dataframe = pandas.read_csv(path)
            l.debug("Successfully read ASCAP csv")
        except Exception as e:
            l.error("Failed to load ASCAP csv")
            l.error(e)
            exit()

    def GetDataframe(self):
        columns = {
            'Work Title' : 'song_title',
            'Dollars' : 'earnings (USD)',
            'Music User' : 'store',
            'Territory' : 'country'
        }

        self.__dataframe = self.__dataframe.rename(columns=columns)

        return self.__dataframe