from re import M
from .abstract_pipeline import Pipeline

import pandas
import logging as l

class Symphonic(Pipeline):

    #path = file path
    #source_date = date of source
    def __init__(self, path: str, source_date:str = "N/A"):
        try:
            l.debug("Attempting to read Symphonic csv...")
            self.__dataframe = pandas.read_csv(path)
            l.debug("Successfully read Symphonic csv")
        except Exception as e:
            l.error("Failed to load Symphonic csv")
            l.error(e)
            exit()

    def GetDataframe(self):

        columns={
            'Track Artists' : 'artist',
            'Track Title' : 'song_title',
            'Royalty ($US)' : 'earnings (USD)',
            'ISRC Code' : 'isrc',
            'Count' : 'quantity',
            'Digital Service Provider' : 'store',
            'UPC Code' : 'upc',
            'Territory' : 'country'
        }

        #TODO: reformat "reporting period" to match "sale month" formatting

        self.__dataframe = self.__dataframe.rename(columns=columns)

        return self.__dataframe