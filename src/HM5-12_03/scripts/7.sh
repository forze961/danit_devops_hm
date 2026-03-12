#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Try again!\nHow to use: $0 <filename>"
    exit 1
fi

wc -l < "$1"
