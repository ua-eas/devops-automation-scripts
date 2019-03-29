# University of Arizona Kuali DevOps - Miscellaneous Scripts

## Description

Scripts that have been used when DevOps team members worked on various tasks.

## Scripts

### createDailyTestFiles
#### Description
A bash script that will create uniquely named files based on the current day of the month. Used in situations where we need one file per day - such as a daily status file. Each file will have the day of the month in its name, and have a timestamp of midnight on that day of the month.

#### Running
You can run this script on the command line. It requires two parameters:
1. The first argument is the directory path of the files. The script will create the directory if it does not exist.
2. The second argument is the desired file prefix. For example, if `clearCacheJob` is used, a resulting file is clearCacheJob01.status.

#### Example
If you run `bash createDailyTestFiles.sh /Users/hlo/test clearCacheJob`, the result is:

```
$ pwd
/Users/hlo/test

$ ls -al
total 0
drwxr-xr-x  23 hlo  staff   736 Mar 21 12:32 .
drwxr-xr-x+ 61 hlo  staff  1952 Mar 19 11:22 ..
-rw-r--r--   1 hlo  staff     0 Mar  1 00:00 clearCacheJob01.status
-rw-r--r--   1 hlo  staff     0 Mar  2 00:00 clearCacheJob02.status
-rw-r--r--   1 hlo  staff     0 Mar  3 00:00 clearCacheJob03.status
-rw-r--r--   1 hlo  staff     0 Mar  4 00:00 clearCacheJob04.status
-rw-r--r--   1 hlo  staff     0 Mar  5 00:00 clearCacheJob05.status
-rw-r--r--   1 hlo  staff     0 Mar  6 00:00 clearCacheJob06.status
-rw-r--r--   1 hlo  staff     0 Mar  7 00:00 clearCacheJob07.status
-rw-r--r--   1 hlo  staff     0 Mar  8 00:00 clearCacheJob08.status
-rw-r--r--   1 hlo  staff     0 Mar  9 00:00 clearCacheJob09.status
-rw-r--r--   1 hlo  staff     0 Mar 10 00:00 clearCacheJob10.status
-rw-r--r--   1 hlo  staff     0 Mar 11 00:00 clearCacheJob11.status
-rw-r--r--   1 hlo  staff     0 Mar 12 00:00 clearCacheJob12.status
-rw-r--r--   1 hlo  staff     0 Mar 13 00:00 clearCacheJob13.status
-rw-r--r--   1 hlo  staff     0 Mar 14 00:00 clearCacheJob14.status
-rw-r--r--   1 hlo  staff     0 Mar 15 00:00 clearCacheJob15.status
-rw-r--r--   1 hlo  staff     0 Mar 16 00:00 clearCacheJob16.status
-rw-r--r--   1 hlo  staff     0 Mar 17 00:00 clearCacheJob17.status
-rw-r--r--   1 hlo  staff     0 Mar 18 00:00 clearCacheJob18.status
-rw-r--r--   1 hlo  staff     0 Mar 19 00:00 clearCacheJob19.status
-rw-r--r--   1 hlo  staff     0 Mar 20 00:00 clearCacheJob20.status
-rw-r--r--   1 hlo  staff     0 Mar 21 00:00 clearCacheJob21.status
```

### Bounce Prototype python script
#### Description
PURPOSE:  Jenkins script to bounce the docker containers of a prototype instance.

How to use:
   1.  Enter Stack Name:  (devfin151, devfin151-proto, etc)
   2.  Choose what you want to restart
         2a. KFS
         2b. RICE
         2c. BOTH

This 'should' bounce all instances for the app you choose(kfs/rice), or all instances in the stack if you choose 'BOTH'.  So far in testing it will bounce all instances even if you have multiple KFS or RICE like STG does.

NOTE:  This does not allow DEV/TST/STG/TRN to be restarted at this time. 

