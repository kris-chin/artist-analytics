import pandas
import logging as l

class Ascap:

    #path = file path
    #source_date = date of source
    def __init__(self, path: str, source_date:str = "N/A"):
        try:
            l.debug("Attempting to read ASCAP csv...")
            self.dataframe = pandas.read_csv(path)
            l.debug("Successfully read ASCAP csv")
        except Exception as e:
            l.error("Failed to load ASCAP csv")
            l.error(e)
            exit()

    def GetDataframe(self):
        return self.dataframe