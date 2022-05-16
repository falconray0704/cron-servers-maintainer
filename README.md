# cron-servers-maintainer
crontab tasks for servers maintaining.

# Install

Run following command for opening the cron task editor:
```bash
$ sudo crontab -e
```

Append the following contents for example to the end:
```bash
0 2 * * * /mnt/cdd//mnt/cdd/cron-servers-maintainer/run.sh -c backup -l "bookstack" > /mnt/cdd/cron-servers-maintainer/run.log
```

