#!/bin/bash

for f in `find  ./ -maxdepth 1 -name "*.php"`
do
    php $f
done

exit 0
