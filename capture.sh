#!/bin/sh

stop_ffmpeg() {
    if [ -n "$pid" ]; then
        echo "Stopping process..."
        kill -TERM "$pid"
    fi
}

trap stop_ffmpeg INT TERM

get_property_value() {
    local property_name="$1"
    local output="$2"
    echo "$output" | grep "$property_name" | awk '{print $NF}'
}

info="$(xwininfo)"
x="$(get_property_value "Absolute upper-left X" "$info")"
y="$(get_property_value "Absolute upper-left Y" "$info")"
width="$(get_property_value "Width" "$info")"
height="$(get_property_value "Height" "$info")"

ffmpeg -f x11grab -video_size "$width"x"$height" -framerate 30 -i :0.0+"$x","$y" -c:v libvpx-vp9 -y output.webm &
pid=$!

wait "$pid"
