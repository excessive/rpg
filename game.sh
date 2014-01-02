#!/usr/bin/env bash
if [[ -f main.lua ]]; then
	love .
else
	echo "main.lua not found. are you in the wrong folder?"
fi