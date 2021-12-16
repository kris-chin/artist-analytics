from pathlib import Path
import pandas

#Get the main directory
p = Path('.').resolve().parents[0]

#we're gonna work on opening the distro csv first
distrokid_tsv = str(p) + "/data/DistroKid.tsv"
distrokid_frame = pandas.read_csv(distrokid_tsv, sep='\t')
print(distrokid_frame)

#jack's data contains multiple different categories in the form of variable names
# PRO Song MetaData 
# Sound Exchange Song MetaData 
# Symphonic Release Details
# Spotify chart details
# Instagram and Facebook Details
jack_xlsx = str(p) + "/data/Data_Updated.xlsx"
jack_frame = pandas.read_excel(jack_xlsx, engine="openpyxl")
print(jack_frame)