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

        #We have to clean the "Reporting Period" data. 
        #Input: YY-MMM (last two digits of year : first three letters of month with caps on first letter)
        #Output: YYYY-MM (all digits)
        #Set up map for month conversion
        #(Maybe this could be placed somewhere else?)
        month_map = {
            'Jan' : '01',
            'Feb' : '02',
            'Mar' : '03',
            'Apr' : '04',
            'May' : '05',
            'Jun' : '06',
            'Jul' : '07',
            'Aug' : '08',
            'Sep' : '09',
            'Oct' : '10',
            'Nov' : '11',
            'Dec' : '12'
        }

        #transformation function for 'Reporting Period
        def transform_data(date: str) -> str:
            #split date with -
            #this gives a list of ["last two digits of year" , "First three letters of month, first letter capitalized"]
            split = date.split('-')
            #Assemble a new string based on our map
            try:
                return ("20" + str(split[0]) + "-" + month_map.get(split[1]) )
            except:
                l.error("'Reporting Period' Data does not match expected formatting. Check column")
                return None

        #Apply transformation
        self.__dataframe['Reporting Period'] = self.__dataframe['Reporting Period'].apply(transform_data)

        columns={
            'Track Artists' : 'artist',
            'Track Title' : 'song_title',
            'Royalty ($US)' : 'earnings (USD)',
            'ISRC Code' : 'isrc',
            'Count' : 'quantity',
            'Digital Service Provider' : 'store',
            'UPC Code' : 'upc',
            'Territory' : 'country',
            'Reporting Period' : 'sale_month'
        }

        self.__dataframe = self.__dataframe.rename(columns=columns)

        return self.__dataframe