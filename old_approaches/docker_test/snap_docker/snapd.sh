sudo docker run \
    --name=snapd \
    -it \
    -d \
    --tmpfs /run \
    --tmpfs /run/lock \
    --tmpfs /tmp \
    --cap-add SYS_ADMIN \
    --device=/dev/fuse \
    --privileged \
    --security-opt apparmor:unconfined \
    --security-opt seccomp:unconfined \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -v /lib/modules:/lib/modules:ro \
    -v /run/snapd.socket:/run/snapd.socket \
    -v /run/snapd-snap.socket:/run/snapd-snap.socket \
    -v /run/dbus/system_bus_socker:/run/dbus/system_bus_socket:ro \
    snapd
