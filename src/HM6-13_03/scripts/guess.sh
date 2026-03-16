#!/bin/bash

random_number=$((RANDOM % 100 + 1))
max_attempts=5

echo "Guess int num from 1 to 100. You have $max_attempts attempts."

if [[ "$1" == "debug" ]] || [[ "$1" == "--debug" ]]; then
    echo "[DEBUG] Random num is: $random_number"
fi

for ((attempts=1; attempts<=max_attempts; attempts++)); do
    read -p "Attempt $attempts/$max_attempts. Your guess: " guess

    if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
        echo "Error 422: Provide only numeric values (integer)!"
        ((attempts--))
        continue
    fi

    if ((guess == random_number)); then
        echo "Excellent! Your num is correct!"
        exit 0
    elif ((guess > random_number)); then
        echo "So high."
    else
        echo "So low."
    fi
done

echo "Sorry, your attempts exceed. Correct answear was $random_number."
