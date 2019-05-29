#!/bin/bash

# Add local user; Either use the host_UID if passed in at runtime or fallback
USER_ID=${host_UID:-9001}

# Add a new user with UID passed in the run command
useradd --shell /bin/bash -u $USER_ID -o -c "" -m orange
HOME=/home/orange

#change ownership of filebeat.yml
chown -R orange:orange /usr/share/filebeat

exec /usr/local/bin/gosu orange "$@"


