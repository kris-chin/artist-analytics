import pandas
import logging as l

#Distrokid extractor specifically for the Distrokid.TSV
class Distrokid:

    #path = file path
    #source_date = date of source
    def __init__(self, path: str, source_date:str = "N/A"):
        try:
            l.debug("Attempting to read Distrokid tsv...")
            self.dataframe = pandas.read_csv(path, sep='\t')
            l.debug("Successfully read Distrokid tsv")
        except Exception as e:
            l.error("Failed to load distrokid tsv")
            l.error(e)
            exit()

    def GetDataframe(self):
        return self.dataframe

    #TODO Function to clean dataframe for universal use, table-joining