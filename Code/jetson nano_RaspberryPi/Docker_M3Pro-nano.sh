#!/bin/bash

# Wait for the Docker service to start
while true; do
    if systemctl is-active --quiet docker; then
        echo "Docker service has been started"
        break
    else
        echo "The Docker service has not started, waiting..."
        sleep 1
    fi
done

# Docker start
#!/bin/bash
#!/bin/bash
xhost +
docker run -it \
--net=host \
--privileged \
--env="DISPLAY" \
--env="QT_X11_NO_MITSHM=1" \
-e PULSE_SERVER=unix:/run/user/1000/pulse/native \
-e ALSA_CARD=0 \
-e XDG_RUNTIME_DIR=/tmp/runtime-$USER \
-v /run/user/1000/pulse:/run/user/1000/pulse:ro \
-v ~/.config/pulse:/root/.config/pulse:ro \
-v /tmp/.X11-unix:/tmp/.X11-unix \
--device=/dev/bus/usb \
--security-opt apparmor:unconfined \
--device=/dev/input \
--device=/dev/snd \
--device=/dev/myserial \
-v /dev/mic:/dev/mic \
192.168.2.51.5000/rosmaster-m3pro-nano:1.0.0 /bin/bash 
