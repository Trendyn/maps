#!/bin/sh
find ./src/WORLD/IND -name "*.json" -type f -exec ls {} \; -delete
find ./src/WORLD/US1 -name "*.json" -type f -exec ls {} \; -delete
find ./src/WORLD/GB1 -name "*.json" -type f -exec ls {} \; -delete
find ./src/WORLD/CAN -name "*.json" -type f -exec ls {} \; -delete
find ./src/WORLD/CH1 -name "*.json" -type f -exec ls {} \; -delete
rm -rf out/
