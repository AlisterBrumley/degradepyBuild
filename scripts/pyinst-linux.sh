#! /bin/sh

# custom scripts for building, do not match the gh ones currently

pyinstaller -F --clean --distpath ./dist-Linux  -n qdd --add-data "./ffmpeg/*:./ffmpeg/" --noconfirm  qddinst.py
#rm -rf ./build