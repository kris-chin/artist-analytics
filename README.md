# Artist-Analytics

If you get an error saying the following:
"E: Release file for ___ is not valid yet (invalid for another 5h 55min 4s). Updates for this repository will not be applied.

Try restarting the clock-sync service:
    systemctl restart systemd-timesyncd.service
This mainly due to a timezone sync issue
https://askubuntu.com/questions/1059217/getting-release-is-not-valid-yet-while-updating-ubuntu-docker-container