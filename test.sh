#!/bin/bash

dir=`dirname $0`

pg_prove -d blog "$dir/test/test.sql"