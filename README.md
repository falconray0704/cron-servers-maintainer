# cron-servers-maintainer
crontab tasks for servers maintaining.

# Install

## Repo clone
```bash
git clone https://github.com/falconray0704/cron-servers-maintainer.git
```

## Configure server's path as following in run.sh in the root of the repo cloned
```bash
export SERVERS_ROOT_PATH="/mnt/cdd/servers"
```

## Install cron task
Run following command for opening the cron task editor:
```bash
$ sudo crontab -e
```

Append the following contents for example to the end:
```bash
0 2 * * * /mnt/cdd/cron-servers-maintainer/run.sh -c backup -l "bookstack" > /mnt/cdd/cron-servers-maintainer/run.log
```

