from pathlib import Path
import logging as l
import pandas
#Import Extractors
import extracts.distrokid

if __name__ == "__main__":

    #Set logger to debug
    l.basicConfig(level = l.DEBUG)
    
    #get main directory
    p = Path('.').resolve().parents[0]

    #Create dict of filenames
    filenames = {
        'distrokid' : str(p) + "/data/DistroKid.tsv"
    }

    #Create extractors
    distrokid = extracts.distrokid.Distrokid(filenames['distrokid'])

    #Test
    print(distrokid.GetDataframe())
