script_dir="$(dirname "${BASH_SOURCE[0]}")"

pushd "${script_dir}" > /dev/null 2>&1

container_uid=1000 # jovyan user in jupyter container
container_gid=100  # jovyan user group in jupyter container
subuidSize=$(( $(podman info --format "{{ range .Host.IDMappings.UIDMap }}+{{.Size }}{{end }}" ) - 1 ))
subgidSize=$(( $(podman info --format "{{ range .Host.IDMappings.GIDMap }}+{{.Size }}{{end }}" ) - 1 ))

podman run --rm \
    -v $(pwd):/home/jovyan:rw \
    --user $container_uid:$container_gid \
    --uidmap $container_uid:0:1 \
    --uidmap 0:1:$container_uid \
    --uidmap $(($container_uid+1)):$(($container_uid+1)):$(($subuidSize-$container_uid)) \
    --gidmap $container_gid:0:1 \
    --gidmap 0:1:$container_gid \
    --gidmap $(($container_gid+1)):$(($container_gid+1)):$(($subgidSize-$container_gid)) \
    localhost/datascience-notebook:latest \
    python jupyterhub.yaml.j2.py

cp -f jupyterhub.yaml ../.

trap 'popd > /dev/null 2>&1' EXIT
