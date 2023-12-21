# JupyterHub Demonstration


Note, this documentation will change as manual steps become incorporated into an Ansible playbook.

## Ansible Install

`ansible-core` is already installed to RHEL9.

Install other Ansible modules:

```bash
sudo dnf -y install ansible-collection-community-general
sudo dnf -y install  ansible-collection-ansible-posix
sudo dnf -y install ansible-collection-containers-podman
```

## Nginx Reverse Proxy

```bash
pushd ansible
ansible-playbook -i ./inventory --limit localhost, --connection=local configure-host-playbook.yaml
popd
```

## Activate podman socket
The `dockerspawn` package used by JupyterHub to create and manage single-user JupyterHub Notebook container instances requires access to the Docker api-compatible Podman socket.

```bash
systemctl --user enable --now podman.socket
```

## Authentication

We will be using the `oauthenticator` package to handle authentication requests through Github organization identities.

Follow these [instructions](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/creating-an-oauth-app) to create a Github app.

## Initialize the build environment.

Export semi-confidential information to build environment.
Fill this in with values specific to your deployment.

(NB, we could put this through `ansible-vault` but the same information will be base64 encoded in the Kubernetes YAML files anyway.)

```bash
export CFG_GH_CLIENT_ID={{ github_app_client_id }}
export CFG_GH_CLIENT_SECRET={{ github_app_client_secret }}
export CFG_GH_CALLBACK_URL=https://{{ jupyterhub_host_fqdn }}/hub/oauth_callback
export CFG_CERTBOT_EMAIL={{ letsencrypt_email_contact }}
```

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

# The --format docker option gets past the non-OCI compliant instructions in the Jupyterlabs Dockerfile specs

podman build --file datascience-notebook/Containerfile \
  --build-arg DOCKER_DATASCIENCE_NOTEBOOK_IMAGE_VERSION="${CFG_DOCKER_DATASCIENCE_NOTEBOOK_IMAGE_VERSION}" \
  --build-arg JUPYTERHUB_VERSION="${CFG_JUPYTERHUB_VERSION}" \
  --tag localhost/datascience-notebook:latest \
  --format docker
```

## Create Kubernetes YAML files

```bash
pushd ansible
ansible-playbook -i ./inventory --limit localhost, --connection=local cr8-k8syaml-playbook.yaml
popd
```

Launch the pod.

```bash
podman kube play secrets.yaml

podman kube play \
  --network "${CFG_DOCKER_NETWORK_NAME}" \
  jupyterhub-pod.yaml
```
