:: Convenience script for building and running the docker image
set BASEDIR="%~dp0..%"
call %BASEDIR%/scripts/docker_build.bat
call %BASEDIR%/scripts/docker_run.bat