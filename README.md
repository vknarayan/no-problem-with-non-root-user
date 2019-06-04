# Running a Micro service as a Non-root user in a container

A data volume is a directory within one or more containers that bypasses the Union File System. The main use-case for volumes is for persisting data between container runs. This is useful for data directories when running databases within containers. Other than persisting databases, it is useful for sharing folders from your host system to the container when running in your development environment and also in production (eg., sharing container logs on the node to filebeat running in a container for centralized logging)

However, there are 2 issues we have here:
- If you write to the volume in container, you won't be able to access the files that container has written because the process in the container usually runs as root; You shouldn't run the process inside your containers as root but even if you run as some hard-coded user, it still won't match the user on your computer
- If you bind mount a folder from the host, a user other than root in the container cannot access the data since the UIDs do not match

We can create a user using a "useradd" command with a specific or a random UID. However, this user will not have the permission to read the log files from mounted volume. For a pre-existing folder or a file, ownership and permissions can be changed using chown and chmod, in the docker file. But, this approach cannot be used for a "bind mount" volume because mounting happens in runtime ( when you are a starting a container) and any change of ownership also has to happen in runtime.

In development environments, usually at some point you want to remove files that the process running in the container has created but you can't because on your computer you're running as UID 1000 ( or similar) and the files are owned either by UID 0 or by some other UID that was perhaps hardcoded in the Dockerfile. Also, the other issue of accessing the files from bind mounted volume ( accessible to only root user on the host ) while running as a non-root user in the container.

We need a solution where in we are able to create a user with UID of the host user in the container and then start the process owned by it. Refer to dockerfile (k9-filebeat-dockerfile) and entrypoint script (entrypoint.sh) to understand how this is addressed.

In the dockerfile, we download gosu, copy entrypoint.sh etc., to the image. We set entrypoint.sh script as the ENTRYPOINT in the Dockerfile. In the entrypoint.sh, we create a user in the container whose UID is same as on the host. This UID is passed as a env value while running the container. Change the ownership of the bind mount folder to the new user and run the microservice as this user.

*docker build -f k9-filebeat-dockerfile -t custom-filebeat .*

*docker container run -d -e host_UID=$UID --name custom-filebeat-container -v /var/lib/docker/containers:/usr/share/filebeat/containers /home/orange/temp:/usr/share/temp custom-filebeat*

**Note: The first volume is for accessing container logs for filebeat; second log is only for testing. You can get into the running container with exec command, switch to orange user, create some temporary files in this folder, /usr/share/temp. Return to the node and check that you can cleanup the files in the folder /home/orange/temp**

*docker container exec -it custom-filebeat-container bash*
