#!/bin/bash

dbname="blog"
dir=`dirname $0`

clean () {
    echo "cleaning..."
    bash "$dir/teardown.sh" -y
    if [[ $? -ne 0 ]]; then
        exit 1
    fi 
}

echo "You're going to setup test database of $dbname, please make sure pg cluster is ready";
while true; do
    read -p "enter y to confirm and n to cancel: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes(y) or no(n).";;
    esac
done

setupDB=`find $dir/setupDB -type f | sort`

for f in $setupDB
do
    psql -v ON_ERROR_STOP=1 -d postgres -f $f
    if [[ $? -ne 0 ]]; then
        echo "cannot run $f to setup db"
        clean
        exit 2
    fi
done 

read -s -p "Password for ${dbname}dba: " password
echo ""

objects=`find $dir/objects -type f | sort`

for f in $objects
do
    psql -v ON_ERROR_STOP=1 postgres://${dbname}dba:$password@127.0.0.1/${dbname} -f $f
    if [[ $? -ne 0 ]]; then
        echo "cannot run $f to create db objects"
        clean
        exit 3
    fi
done

patch=`find $dir/patch/ -type f | sort`

for f in $patch
do
    psql -v ON_ERROR_STOP=1 postgres://${dbname}dba:$password@127.0.0.1/${dbname} -f $f
    if [[ $? -ne 0 ]]; then
        echo "cannot run $f to patch db"
        clean
        exit 4
    fi
done

populate=`find $dir/populate/ -type f -name "*.csv" | sort`

for f in $populate
do
    column=`head -n 1 $f`
    table=`basename -s .csv $f`
    cat $f | psql -v ON_ERROR_STOP=1 postgres://${dbname}dba:$password@127.0.0.1/${dbname} -c "BEGIN; COPY ${table:1:${#table}}($column) FROM STDIN CSV HEADER; COMMIT;"
    if [[ $? -ne 0 ]]; then
        echo "cannot populate $f"
        clean
        exit 5
    fi
done

exit 0
