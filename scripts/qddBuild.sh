#! /bin/sh

## Builds QDD and optionally FFMPEG
## and packs them for a release version
## that is ready to upload to github

## should be in ~/Documents/prog/degradepy/degradepyBuild/scripts
## and run from ~/Documents/prog/degradepy/degradepyBuild

# var set
os=$(uname -s)
if [ "$os" != "Linux" ] && [ "$os" != "Darwin" ]
then
    os="Win"
fi

# top level locations
prog="$HOME/Documents/prog" 
degradepy="$prog/degradepy"
degradepyBuild="$degradepy/degradepyBuild"
scripts="$degradepyBuild/scripts"

# qdd locations
qddBuild="$degradepyBuild/qddBuild"
pyinst="$qddBuild/pyinst"
pyinst_ffmpeg="$pyinst/ffmpeg"
dist="$pyinst/dist-$os"

# ffmpeg locations
ffmpegBuild="$degradepyBuild/ffmpegBuild"

# sets to stop when something errors
set -e

# moving to place
cd $degradepyBuild

# asking user for info
echo "What is the current version?"
read vnum
echo "Want to rebuild FFMPEG? [y/n]"
read ffmpeg_yn

# building ffmpeg if asked
if [ "$ffmpeg_yn" != "${ffmpeg_yn#[Yy]}" ]
then
    # build ffmpeg
    echo " ----- BUILDING FFMPEG ----- "
    case $os in
        "Darwin") $scripts/ffmpegQddBuildMac.sh
        ;;
        "Linux") $scripts/ffmpegQddBuildLinux.sh
        ;;
        "Win") echo "requires cross compile, cannot build ffmpeg here!"
        echo "place ffmpeg.exe and ffprobe.ex in ffmpeg build"
        echo "exiting..."
        exit 12 ;;
    esac
fi


# preparing to build qdd
echo " ----- QDD PREP ----- "
cd $degradepyBuild

# check if old buildfile exists and pulls newest version
if [ -d $qddBuild ]
then
    rm -rf $pyinst # have to do this because it throws a permission denied on next (but still does it?)
    rm -rf $qddBuild
fi
gh repo clone AstaBrum/degradepy $qddBuild
cd $qddBuild
# removing files that dont need
rm -rf .git* .readme_img README.md qddegrade.py

# moving files for build
mv $qddBuild/deghelpers.py \
    $pyinst
mv $qddBuild/guihelpers.py \
    $pyinst

# pull ffmpeg from its buildfile
mkdir $pyinst_ffmpeg
cp $ffmpegBuild/ffmpeg \
    $pyinst_ffmpeg
cp $ffmpegBuild/ffprobe \
    $pyinst_ffmpeg
cp $ffmpegBuild/ffqdd_build_log.txt \
    $pyinst_ffmpeg

# building qdd
echo " ----- BUILDING QDD ----- "
cd $pyinst
case $os in
    "Darwin") 
        $scripts/pyinst-mac.sh && tput bel
    ;;
    "Linux") 
        $scripts/pyinst-linux.sh && tput bel
    ;;
    "Win")
        cp $ffmpegBuild/libwinpthread-1.dll \
        $pyinst_ffmpeg 
        $scripts/pyinst-win.sh && tput bel
    ;;
esac

# creating release package
echo " ----- PACKING QDD ----- "
case $os in
    "Darwin")
        mv $pyinst/readme.txt $dist
        hdiutil create \
            -ov \
            -srcfolder $dist \
            -volname "qdd $vnum" $degradepy/qdd_mac_x86_64_$vnum.dmg \
            && tput bel
    ;;
    "Linux")
        mv $pyinst/readme.txt $dist
        tar -cJf \
            $degradepy/qdd_lin_x86_64_$vnum.tar.xz \
            $dist
    ;;
    "Win")
        mv $pyinst/readme.txt $dist/qdd
        7z a $degradepy/qdd_win_x86_64_$vnum.zip \
        $dist/qdd \
        && tput bel
esac

timenow=$(date)
echo " ----- BUILD COMPLETE ----- " 
echo " ----- @ ${timenow} ------ "