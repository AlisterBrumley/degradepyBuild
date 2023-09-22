#! /bin/sh
# custom scripts for building, do not match the gh ones currently

# adds ffmpeg into executable and names it qdd
pyinstaller -w --clean --distpath ./dist-Darwin -n qdd --add-data "./ffmpeg/*:./ffmpeg/" --noconfirm qddinst.py

# deletes unneeded build file
rm -rf ./build
rm -rf ./dist-Darwin/qdd/