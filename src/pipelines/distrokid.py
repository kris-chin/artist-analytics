from .abstract_pipeline import Pipeline

import pandas
import logging as l

#imports for modification time
import os
from datetime import datetime

#Distrokid extractor specifically for the Distrokid.TSV
class Distrokid(Pipeline):

    #path = file path
    #source_date = date of source
    def __init__(self, path: str, source_date:str = "N/A"):
        try:
            l.debug("Attempting to read Distrokid tsv...")

            self.__name = 'Distrokid'
            self.__dataframe : pandas.DataFrame = pandas.read_csv(path, sep='\t')
            self.__sourceDate = datetime.fromtimestamp(os.path.getmtime(path)).strftime("%Y-%m-%d")

            l.debug("Successfully read Distrokid tsv")
        except Exception as e:
            l.error("Failed to load distrokid tsv")
            l.error(e)
            exit()

    def GetDataframe(self): 
        #Data Cleaning Operations

        #Rename Columns
        columns={
            'Reporting Date' : 'reporting_date',
            'Title' : 'song_title',
            'Artist' : 'artist',
            'Sale Month' : 'sale_month',
            'ISRC' : 'isrc',
            'Quantity' : 'quantity',
            'Store' : 'store',
            'UPC' : 'upc',
            'Country of Sale' : 'country',
            'Earnings (USD)' : 'earnings (USD)' 
        }

        self.__dataframe = self.__dataframe.rename(columns=columns)
        
        return self.__dataframe

    @property
    def name(self): return self.__name

    @property
    def sourceDate(self): return self.__sourceDate