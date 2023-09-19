#! /bin/sh
# custom scripts for building, do not match the gh ones currently

pyinstaller -w --clean --distpath ./dist-Darwin -n qdd --add-data "./ffmpeg/*:./ffmpeg/" --noconfirm qddinst.py

rm -rf ./build
rm -rf ./dist-Darwin/qdd/