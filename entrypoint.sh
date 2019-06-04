#!/bin/bash

# Add local user; Either use the host_UID if passed in at runtime or fallback
USER_ID=${host_UID:-9001}

# Add a new user with UID passed in the run command
useradd --shell /bin/bash -u $USER_ID -o orange

#change ownership of the mounted volume in the container
chown -R orange /usr/share/filebeat

exec /usr/local/bin/gosu orange filebeat


