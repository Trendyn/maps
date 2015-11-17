#!/bin/sh
find . -type f -name 'map.json' |
tar -cf - -T - |
tar -xf - -C $1