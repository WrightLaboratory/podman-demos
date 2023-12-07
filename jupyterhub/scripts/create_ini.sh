script_dir="$(dirname "${BASH_SOURCE[0]}")"
pushd "${script_dir}" > /dev/null 2>&1

# Generate replacement values for jinja2 templates
tee "jupyterhub.yaml.j2.ini"<<_EOF > /dev/null 2>&1
[default]
docker_network_name=${CFG_DOCKER_NETWORK_NAME}
docker_datascience_notebook_image_version=${CFG_DOCKER_DATASCIENCE_NOTEBOOK_IMAGE_VERSION}
jupyterhub_version=${CFG_JUPYTERHUB_VERSION}
host_jupyterhub_pod_db_path=${CFG_HOST_JUPYTERHUB_POD_DB_PATH}
host_jupyterhub_pod_data_path=${CFG_HOST_JUPYTERHUB_POD_DATA_PATH}
host_podman_socket_path=${CFG_HOST_PODMAN_SOCKET_PATH}
_EOF

# Generate nginx replacement values
tee "nginx_reverse_proxy_config.yaml.j2.ini"<<_EOF > /dev/null 2>&1
[default]
servername=localhost
_EOF

trap 'popd > /dev/null 2>&1' EXIT
