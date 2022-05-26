# Artist-Analytics

Are you not satisfied with the analytical options that Spotify or Distrokid provide you?
Do you wish that you could have all of your relevent artist data at the tip of your fingertips?
Artist-Analytics is both a **web application** and an **ETL pipeline** designed to aggregate, visualize, and analyze artist data from all sorts of sources.

The Web Application is powered by [R Shiny](https://shiny.rstudio.com/), while the ETL Pipeline was written in [Python Pandas](https://pandas.pydata.org/).

Some of the supported data sources include:

- [Distrokid](https://distrokid.com/) (CSV)
- [Symphonic](https://symphonic.com/) (CSV)
- [Spotify for Artists](https://artists.spotify.com/) (CSV)
- [ASCAP](https://www.ascap.com/) (CSV)
- [Spotify for Developers WEB API](https://developer.spotify.com/documentation/web-api/) (JSON) (WIP)

**WARNING: This project is still REALLY WIP. I plan on improving both the UX and the DX**

Data Sources that I plan on adding:

- Youtube Video + Channel Metrics
- Instagram Metrics

## Installation for Users

REQUIREMENTS: [docker](https://docs.docker.com/get-docker/), [git](https://git-scm.com/downloads).

After installing both docker and git, simply clone this github repository into a directory and run the respective setup script.

See **Development** below. 
 
## Usage

Put all relevant CSVs into a new folder named `data/`. Rename the files based on the following schema:
    
| Source | Exact Filename |
| -------| -------------- |
| Distrokid | "DistroKid.csv" |
| Symphonic | "symphonic.csv" |
| ASCAP | "ascap.csv" |

## Development

### Setup

All of the required packages are specified in the Dockerfile, so all you have to do is build the Dockerfile. I have written convenience scripts that also specify stuff such as bind mount directories, image names, etc.

#### Linux (Dockerfile)

    scripts/docker_build.sh <- Builds the Docker file
    scripts/docker_run.sh <- Starts the Docker container with the appropriate settings
    scripts/start.sh <- runs docker_build.sh and docker_run.sh

#### Windows (Dockerfile)

    scripts/docker_build.bat <- Builds the Docker file
    scripts/docker_run.bat <- Starts the Docker container with the appropriate settings
    scripts/start.bat <- runs docker_build.bat and docker_run.bat
    scripts/stop.bat <- stops the docker container since windows can't listen to CTRL+C for some reason

### Adding new Pipelines

If you want to add a new Pipeline, simply create a new class that extends the Pipeline class found in `src/py/pipelines/abstract_pipeline.py`

See `tests/test_pipeline.py` for integration tests to ensure that the Pipeline works. (WIP)

If you want to implement a Pipeline into the main ETL Pipeline, see `src/py/Main.py` (WIP)

## Troubleshooting

If you have any issues, feel free to contact me and I'll google search for you.

### "Release file for __ is not valid yet"

If you get an error similar to the following:

    Release file for ___ is not valid yet (invalid for another 5h 55min 4s). Updates for this repository will not be applied.

Try restarting the clock-sync service. [This mainly due to a timezone sync issue](https://askubuntu.com/questions/1059217/getting-release-is-not-valid-yet-while-updating-ubuntu-docker-container):

## License

No License right now. All rights are reserved.
