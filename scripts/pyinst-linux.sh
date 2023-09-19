#! /bin/sh

# custom scripts for building, do not match the gh ones currently

pyinstaller -F --clean --distpath ./dist-Linux --noconfirm  qddegrade.py
#rm -rf ./build