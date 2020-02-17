#!/bin/bash

dbname="blog"
dir=`dirname $0`

while getopts "y" opt
do
    case $opt in
        y ) confirmed=true
    esac
done

if [[ ! $confirmed ]]; then
    echo "You're going to destroy test database of $dbname and all its data!";
    while true; do
        read -p "enter y to confirm and n to cancel: " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

for f in `find $dir/teardownDB/ -type f`
do
    psql -v ON_ERROR_STOP=1 -d postgres -f $f
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
done


exit 0
