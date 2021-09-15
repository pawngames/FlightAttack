#!/bin/bash

for f in *.mp3; 
do 
    ffmpeg -i "$f" "${f%.mp4}".ogg;
done
