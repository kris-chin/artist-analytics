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
        return self.__dataframe