#!/bin/bash

INPUT_STRING=${1}

if [ -z "$INPUT_STRING" ]; then
    echo "Error! Please provide a string in quotes."
    exit 1
fi

read -ra WORDS <<< "$INPUT_STRING"

REVERSED_STRING=""

for (( i=${#WORDS[@]}-1; i>=0; i-- )); do
    REVERSED_STRING+="${WORDS[i]} "
done

echo "${REVERSED_STRING% }"
