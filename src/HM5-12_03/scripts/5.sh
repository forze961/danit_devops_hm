#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Try again!\nHow to use: $0 <source> <dest>"
    exit 1
fi

cp "$1" "$2"
echo "File copied from $1 to $2."
