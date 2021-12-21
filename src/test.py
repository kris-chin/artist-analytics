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

#Cleaning
jack_frame = jack_frame.dropna(0, how='all') #Drop Rows with ALL NaNs (completely empty rows)
jack_frame = jack_frame.dropna(1, thresh=2) #Only keep columns that have at least 2 non NaN values (columns that aren't blank)

jack_columns = jack_frame.iloc[0] #this gets us the columns that actualy have data underneath them
print(jack_frame) 