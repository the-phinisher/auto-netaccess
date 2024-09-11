# IITM Netacess Auto Update

Automatic authorization renewal for [IITM netaccess](https://netaccess.iitm.ac.in).

Requires NodeJS, see: [NodeJS download and installation](https://nodejs.org/en/download/package-manager).

> **_NOTE:_** It's recommended to offset your cron times to different values to ensure low workload during specific times like the default time.

# Setup

## Setup script

Run `chmod +x setup.sh && ./setup.sh` on your terminal and input the required data. Have a look at [cron wiki](https://en.wikipedia.org/wiki/Cron) for understanding cron scheduling conventions.

## Manual

After changing to current directory, run `npm install` or `npm i` to install packages.

Create a file `.env` and write its contents,

```
ROLLNO="<your-roll-number>"
PASSWD="<your-password>"
```

Switch from `"` to `'` if your password contains `"`.

With the script ready, run `crontab -e`, and add a new line `* * * * * node /path/to/project/index.js`. Replace the `* * * * *` with your own cron schedule.

Refer to cron scheduling convention at [cron wiki](https://en.wikipedia.org/wiki/Cron).