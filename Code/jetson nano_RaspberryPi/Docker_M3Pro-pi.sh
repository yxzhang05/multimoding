#!/bin/bash
xhost +
docker run -it \
--privileged \
--net=host \
--env="DISPLAY" \
--env="QT_X11_NO_MITSHM=1" \
-e PULSE_SERVER=unix:/run/user/1000/pulse/native \
-e ALSA_CARD=0 \
-v /run/user/1000/pulse:/run/user/1000/pulse:ro \
-v ~/.config/pulse:/root/.config/pulse:ro \
-v /tmp/.X11-unix:/tmp/.X11-unix \
--security-opt apparmor:unconfined \
--device=/dev/input \
--device=/dev/snd \
-v /dev/mic:/dev/mic \
--device=/dev/myserial \
--device=/dev/bus/usb \
192.168.2.51:5000/rosmaster-m3pro:1.0.4 /bin/bash


       









