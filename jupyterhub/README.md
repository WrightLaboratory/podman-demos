# JupyterHub Demonstration

```bash
# Activate podman socket
# This is required so that the DockerSpawn package used by JupyterHub
# to invoke Docker API calls to create single-user JupyterHub Notebook instances
# in the pod.

systemctl --user enable --now podman.socket

```

Create a named bridged network for use by the JupyterHub pod.

```bash
podman network create jupyterhub-net
```

Unlike Docker Compose YAML, Kubernetes YAML has no `build` fields to pass to the Containerfile `ARG` instructions.

It is necessary to build the custom JupyterHub and Notebook images prior to playing the JupyterHub pod Kubernetes YAML file.

```bash
podman build --file jupyterhub/Containerfile --build-arg-file argfile.conf  --tag localhost/jupyterhub:latest

# The `--format docker` option gets past the non-OCI compliant instructions in the Jupyterlabs Dockerfile specs
podman build --file datascience-notebook/Containerfile --build-arg-file argfile.conf  --tag localhost/datascience-notebook:latest --format docker
```

Launch the pod.

```bash
podman kube play jupyterhub.yaml --network jupyterhub-net
```
