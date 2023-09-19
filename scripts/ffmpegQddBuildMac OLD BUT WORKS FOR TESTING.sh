#! /bin/sh
## Builds minimal FFMPEG for QDD

# var sets
macos_min_compat="10.10"
prog="$HOME/Documents/prog"
ff_root="$prog/ffmpeg"
build_dir="$ff_root/ffmpeg"
out_dir="$ff_root/ffmpegQDD" #remove
configure="$build_dir/configure"
build_log="ffqdd_build_log.txt"
protocols="file,pipe"
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


# moving to place and creating files as it goes
cd $prog
# this should always exist probs worth deleting?
if [ ! -d $ff_root ]
then
    mkdir $ff_root
fi
cd $ff_root
# creating output dir for binaries
if [ ! -f $out_dir ]
then
    mkdir -p $out_dir
fi
# backs up old logs if they exist
if [ -f "$out_dir/$build_log" ]
then 
    mv "$out_dir/$build_log" "$out_dir/last_$build_log"
fi


# gitting ffmpeg if required
if [ ! -d $build_dir ]
then
    echo "sourcefile does not exist!"
fi

echo "want to get new source? [curl/git/no]"
read ffgit_yn
if [ "$ffgit_yn" != "${ffgit_yn#[CcYy]}" ]
then
    echo "curl'ing stable source (v6)"
    curl -Of https://ffmpeg.org/releases/ffmpeg-6.0.tar.xz
    tar -xf ffmpeg-6.0.tar.xz
    mv ffmpeg-6.0 $build_dir
    rm -rf ffmpeg-6.0.tar.xz
elif [ "$ffgit_yn" != "${ffgit_yn#[Gg]}" ]
then
    echo "git'ing newest source"
    echo "WARNING - POTENTIAL ISSUES AHEAD!"
    git clone https://git.ffmpeg.org/ffmpeg.git $build_dir
elif [ "$ffgit_yn" != "${ffgit_yn#[Nn]}" ]
then
    echo "keeping current source"
fi

if [ ! -d $build_dir ]
then
    echo "sourcefile still does not exist"
    echo "git it ya git!"
    exit 1
fi

cd $build_dir


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
    | tee -a $out_dir/$build_log


# making
echo " ----- MAKING FFMPEG ----- "
make && tput bel
# coping to other dir for convience
cp $build_dir/ffmpeg \
    $out_dir/
cp $build_dir/ffprobe \
    $out_dir/


# writing to log
timenow=$(date)
echo " ----- MADE FFMPEG ----- " | tee -a $out_dir/$build_log
echo " ----- @ ${timenow} ------ " | tee -a $out_dir/$build_log
# testing
$out_dir/ffmpeg -version | tee -a $out_dir/$build_log