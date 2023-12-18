# JupyterHub Demonstration

```bash
# Activate podman socket
# This is required so that the DockerSpawn package used by JupyterHub
# to invoke Docker API calls to create single-user JupyterHub Notebook instances
# in the pod.

systemctl --user enable --now podman.socket

```

Initialize the build environment.

```bash
# Set environment variables
source scripts/build_env
```

Create local directories to be mounted by pod containers:

```bash
sudo mkdir -p "${CFG_HOST_JUPYTERHUB_POD_DB_PATH}"
sudo chown $(id -u):($id -u) -R "${CFG_HOST_JUPYTERHUB_POD_DB_PATH}"

sudo mkdir -p "${CFG_HOST_JUPYTERHUB_POD_DATA_PATH}"
sudo chown $(id -u):($id -u) -R ${CFG_HOST_JUPYTERHUB_POD_DATA_PATH}"
```

Create a named bridged network for use by the JupyterHub pod.

```bash
podman network create "${CFG_DOCKER_NETWORK_NAME}"
```

Unlike Docker Compose YAML, Kubernetes YAML has no `build` fields to pass to the Containerfile `ARG` instructions.

It is necessary to build the custom JupyterHub and Notebook images prior to playing the JupyterHub pod Kubernetes YAML file.

```bash
podman build --file jupyterhub/Containerfile \
  --build-arg JUPYTERHUB_VERSION="${CFG_JUPYTERHUB_VERSION}" \
  --tag localhost/jupyterhub:latest

# The `--format docker` option gets past the non-OCI compliant instructions in the Jupyterlabs Dockerfile specs

podman build --file datascience-notebook/Containerfile \
  --build-arg DOCKER_DATASCIENCE_NOTEBOOK_IMAGE_VERSION="${CFG_DOCKER_DATASCIENCE_NOTEBOOK_IMAGE_VERSION}" \
  --build-arg JUPYTERHUB_VERSION="${CFG_JUPYTERHUB_VERSION}" \
  --tag localhost/datascience-notebook:latest \
  --format docker
```

Create the `jupyterhub.yaml` Kubernetes specfication file from the `jupyterhub.yaml.j2` template

```bash
# Create toml configuration files with values for jinja2 template
bash scripts/create_toml.sh

# Create yaml files
bash scripts/generate_pod_yaml.sh
```

Launch the pod.

```bash
podman kube play \
  --network "${CFG_DOCKER_NETWORK_NAME}" \
  jupyterhub-pod.yaml
```
