#!/bin/bash

# Usage: archive_git year remote branch 

year=$1
remote=$2
branch=$3

tag=archive-$year/$branch

git push $remote --delete $branch
git tag $tag $branch
git branch -D $branch
git push $remote $tag

