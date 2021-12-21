import pandas
import logging as l

#Distrokid extractor specifically for the Distrokid.TSV
class Distrokid:

    #Takes in path arg
    def __init__(self, path: str, date:str = "N/A"):
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