#!/bin/sh


./urban-tycoons &
game_pid=$!

get_property_value() {
    local property_name="$1"
    local output="$2"
    echo "$output" | grep "$property_name" | awk '{print $NF}'
}

i=10
while [ $i -gt 0 ]; do
    echo "$i"
    i=$(($i - 1))
    sleep 1
done

wid="$(xdotool search --pid "$game_pid")"
info="$(xwininfo -id "$wid")"
x="$(get_property_value "Absolute upper-left X" "$info")"
y="$(get_property_value "Absolute upper-left Y" "$info")"
width="$(get_property_value "Width" "$info")"
height="$(get_property_value "Height" "$info")"

ffmpeg -f x11grab -video_size "$width"x"$height" -framerate 60 -i :0.0+"$x","$y" -an -y output.mp4 &
ffmpeg_pid=$!

while true; do
    if ! ps -p $game_pid > /dev/null; then
        kill $ffmpeg_pid
        break
    fi

    sleep 1
done

while true; do
    if ! ps -p $ffmpeg_pid > /dev/null; then
        len="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 output.mp4)"
        trim_s=1
        len="$(echo "$len $trim_s" | awk '{print $1-$2}')"
        ffmpeg -i output.mp4 -ss 0 -t "$len" -c:v libvpx-vp9 -an -b:v 1M -fs 3M -pass 1 -f null /dev/null && \
        ffmpeg -i output.mp4 -ss 0 -t "$len" -c:v libvpx-vp9 -an -b:v 1M -fs 3M -pass 2 -y output.webm
        break
    fi

    sleep 1
done
