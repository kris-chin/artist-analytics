#Get packages based on arguments
packages <- commandArgs(trailingOnly = TRUE)

#Set a mirror
mirror <- "https://cloud.r-project.org"

#Go through each package in args
for (i in packages) {
    install.packages(i, dependencies = TRUE, repos = mirror)
    #Attempt to load the library, if it doesn't work, quit
    if (!library(i, character.only = TRUE, logical.return = TRUE)) {
        quit(status = 1, save = "no")
    }
}