script_dir="$(dirname "${BASH_SOURCE[0]}")"

pushd "${script_dir}" > /dev/null 2>&1

templates=( $(ls *.j2) )

container_uid=1000 # jovyan user in jupyter container
container_gid=100  # jovyan user group in jupyter container

for t in ${templates[@]}; do
  podman run --rm \
      -v $(pwd):/home/jovyan:rw,Z \
      -u $container_uid:$container_gid \
      --userns keep-id:uid=$container_uid,gid=$container_gid \
      localhost/datascience-notebook:latest \
      python render_from_template.py "$t"
  mv -f "$(basename -s '.j2' $t)" ../.
done

trap 'popd > /dev/null 2>&1' EXIT
