## Official Server Stat Logging and Automatic Demo Uploading

### Requirements
* The latest version of the server image
* Contact darksaint for the following:
  * AWS account created with keys
  * AWS account given permission to access S3 bucket and SQS


### Demo uploading
As part of the q2admin system that is incorporated with this official docker image, there is a script that is triggered to run at the end of a match.  This script leverages `s3cmd` that is also incorporated in the image to use the **AWS_ACCESS_KEY**, **AWS_SECRET_KEY** and **SERVERTARGETDIR** values for authentication and location of where the demos would be uploaded in S3.  This is an automatic process and debugging occurs within the server itself, as it logs successful uploads and failures.  If you are experiencing failures, contact a member of the @Server Admin team in Discord.

The **SERVERTARGETDIR** is the directory in S3 where your demos would be located, which is accessible at https://demos.aq2world.com/ -- you can set this to whatever you want, however, we have an established naming scheme, for example, if your servers were the only German AQ2World servers, and your server was a Teamplay server running on port `27910`, we suggest this value to be **aq2world_de/tp1_27910** -- this is not a hard and fast rule, but we ask you to not use an existing directory that someone else is already using.  Check out the link to find out which directory names are already in use.

### Stat logging
With the environment variable **STAT_LOGS=1**, stats are recorded in JSON format automatically during play except when during warmup or post-round teamkilling is going on.  It is disabled if bots are enabled, for example, **LTK_LOADBOTS=1**.  These are logged to the file set in your **LOGFILE_NAME** cvar.

It is imperative that the LOGFILE settings in the example `docker-compose.yaml` are set, especially **LOGFILE_FLUSH=2** -- if it is set to `0`, it will break compatibility with the publisher.

The `stats-pub` container is a simple scanner/publisher.  It is looking for stat lines that occur in log files.  It will scan for new files and remove deleted files in the `logs` directory every 5 seconds and if it finds a stat line, automatically sends it to AWS SQS using your AWS credentials supplied to you, and its is own logs, specify which log it found a stat line in.  You can increase the verbosity of this logging by setting **LOGLEVEL=DEBUG**, but it is _very_ verbose.
