#!/bin/bash

cat "$1" 2>/dev/null || echo "Error: File '$1' does not exist."
