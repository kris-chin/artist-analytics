#Use the official Python image, which is built upon Debian Buster (compatible with pandas)
FROM python:3.10.4-buster

#Update databases so we have access to R
RUN apt-get update

#Install R
RUN apt-get install -y r-base

#Set working directory
WORKDIR /app

#Get Our R Package Installer so we can use Docker Build Cache effectively
COPY scripts/install_package.r ./
    
    #Install big packages seperately since they have longer compile times
    #These are typically ENTIRE libraries
    RUN Rscript --no-save install_package.r shiny
    RUN Rscript --no-save install_package.r ggplot2
    RUN Rscript --no-save install_package.r plotly
    RUN Rscript --no-save install_package.r maps
    RUN Rscript --no-save install_package.r dplyr

    #Install light packages at the same time
    RUN Rscript --no-save install_package.r lubridate DT countrycode shinyjs

#Get Python Requirements
COPY REQUIREMENTS.txt ./

    #Install Python Requirements
    RUN pip3 install -r REQUIREMENTS.txt

#Clone Source Code
COPY . .

#Start R shiny application
CMD ["Rscript", "/app/src/r/App.r"]