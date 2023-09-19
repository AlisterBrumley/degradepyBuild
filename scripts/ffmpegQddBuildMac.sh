#! /bin/sh

## Builds minimal FFMPEG for QDD for macOS

## TODO: MAKE CROSS PLATFORM? AT LEAST FOR LINUX?

## should be in ~/Documents/prog/degradepy/degradepyBuild/scripts
## and run from ~/Documents/prog/degradepy/degradepyBuild

# var sets
macos_min_compat="10.10"

# location var set
prog="$HOME/Documents/prog"
degradepy="$prog/degradepy"
degradepyBuild="$degradepy/degradepyBuild"
ffmpegBuild="$degradepyBuild/ffmpegBuild"
build_log="$ffmpegBuild/ffqdd_build_log.txt"


# configure settings
enable_components="
--enable-encoder=*pcm*
--enable-decoder=*aiff*,*pcm*,*mp3*
--enable-muxer=*pcm*,*aiff*,*mp3*,*wav*
--enable-demuxer=*pcm*,*aiff*,*mp3*,*wav*
--enable-protocol=file,pipe
--enable-filter=aresample"
compat_flags="
--extra-cflags="-mmacosx-version-min=${macos_min_compat}"
--extra-ldflags="-mmacosx-version-min=${macos_min_compat}""


# sets to stop when something errors
set -e

# should be here, but making sure by setting
#cd $degradepyBuild

# gitting ffmpeg if required
if [ ! -d $ffmpegBuild ]
then
    echo "sourcefile does not exist!"
fi

echo "want to get new source? [Curl/Git/No]"
read new_source
if [ "$new_source" != "${new_source#[CcYy]}" ]
then
    rm -rf $ffmpegBuild
    echo "curl'ing stable source (v6)"
    curl -Of https://ffmpeg.org/releases/ffmpeg-6.0.tar.xz
    tar -xf ffmpeg-6.0.tar.xz
    mv ffmpeg-6.0 $ffmpegBuild
    rm -rf ffmpeg-6.0.tar.xz
elif [ "$new_source" != "${new_source#[Gg]}" ]
then
    echo "git'ing newest source"
    rm -rf $ffmpegBuild
    echo "WARNING - POTENTIAL ISSUES AHEAD!"
    git clone https://git.ffmpeg.org/ffmpeg.git $ffmpegBuild
    rm -rf .git
elif [ "$new_source" != "${new_source#[Nn]}" ]
then
    echo "keeping current source"
fi

if [ ! -d $ffmpegBuild ]
then
    echo "sourcefile still does not exist"
    echo "git it ya git!"
    exit 1
fi

cd $ffmpegBuild


# configuring
echo " ----- CONFIGURING FFMPEG ----- "
timenow=$(date)
./configure \
    --extra-version="qddMinimal" \
    --enable-small \
    --enable-static \
    --disable-shared \
    --disable-doc \
    --disable-everything \
    $enable_components \
    --disable-xlib \
    --disable-sdl2 \
    --disable-ffplay \
    --pkg-config-flags=--static \
    $compat_flags \
    | tee -a $build_log


# making
echo " ----- MAKING FFMPEG ----- "
make && tput bel

# writing to log
timenow=$(date)
echo " ----- MADE FFMPEG ----- " | tee -a $build_log
echo " ----- @ ${timenow} ------ " | tee -a $build_log
# testing
./ffmpeg -version | tee -a $build_log