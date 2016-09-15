#!/bin/bash
# Default repository URL
cookbooksRepo='git@bitbucket.org:ua-ecs/ecs-opsworks-cookbooks.git'
# Default branch to do daily build of
branch='CLOUD-32'

rm -Rf /tmp/repo
git clone $cookbooksRepo /tmp/repo/ecs-opsworks-cookbooks
cd /tmp/repo/ecs-opsworks-cookbooks/kfs

packageName=kfs-cookbooks-$branch.tar.gz
berks package $packageName && aws s3 cp --sse AES256 ./$packageName s3://edu-arizona-pilots-eas/financials/$packageName
