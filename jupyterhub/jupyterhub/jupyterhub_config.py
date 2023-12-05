import dockerspawner
from os import path
from os import environ as env

c = get_config()

## Set the log level by value or name.
#  Choices: any of [0, 10, 20, 30, 40, 50, 'DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL']
#  Default: 30
c.Application.log_level = 0

#c.JupyterHub.authenticator_class = 'jupyterhub.auth.PAMAuthenticator'

c.JupyterHub.authenticator_class = 'dummy'


# Set the hub IP address for use in the singleuser server.
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(("8.8.8.8", 80))
c.JupyterHub.hub_connect_ip = s.getsockname()[0]
s.close()

c.JupyterHub.hub_ip = '0.0.0.0'


# Use the Postgres database for authentication.
c.JupyterHub.db_url = 'postgresql://{user}:{password}@{host}/{db}'.format(
        user=env["POSTGRES_USER"],
        password=env["POSTGRES_PASSWORD"],
        host=env["POSTGRES_HOST"],
        db=env["POSTGRES_DB"])

# Use the DockerSpawner to start user containers.
c.JupyterHub.spawner_class = 'docker'

if (img := env.get('DOCKER_NOTEBOOK_IMAGE')) is not None:
    c.DockerSpawner.container_image = img

c.DockerSpawner.args = ['--NotebookApp.allow_origin=*']

network_name = env["DOCKER_NETWORK_NAME"]
c.DockerSpawner.use_internal_ip = True
c.DockerSpawner.network_name = network_name
# Pass the network name as argument to spawned containers
c.DockerSpawner.extra_host_config = { 
    'network_mode': network_name,
    "volume_driver": "local", 
}

c.DockerSpawner.remove = True
c.DockerSpawner.debug = True

# We need to set the Notebook Directory
notebook_dir = '/home/jovyan/work'
c.DockerSpawner.notebook_dir = notebook_dir

# Need to tell where to mount the volumes.
c.DockerSpawner.volumes = { 'jupyterhub-user-{username}': notebook_dir }

c.JupyterHub.cookie_secret_file = path.join('/data',
    'jupyterhub_cookie_secret')
