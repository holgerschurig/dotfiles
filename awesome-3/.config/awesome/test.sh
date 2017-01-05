#!/bin/sh
clear
awesome -k || exit 1
Xephyr -ac -br -noreset -screen 1024x768 :1 &
XEPHYR_PID=$!
sleep 0.2
export DISPLAY=:1.0
awesome
kill $XEPHYR_PID 2>/dev/null
