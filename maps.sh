#!/bin/bash

baseUrl="http://gameassets.aqtiongame.com/action/maps/"

cat maplist.ini | while read map
do
    if [ -f "/aq2server/action/maps/${map}.bsp" ]; then
        echo "Map $map exists."
    else 
       wget "${baseUrl}${map}.bsp" -O "/aq2server/action/maps/${map}.bsp"
    fi
done