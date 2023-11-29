#! /usr/bin/env bash

tls_crt_file=$1
tls_key_file=$2

if [[ ! -e "$tls_crt_file" ]]; then
    echo "Usage: ./cr8_k8s_secrets <tls_certificate_filename> <tls_key_filename>"
    exit 1
fi

if [[ ! -e "$tls_key_file" ]]; then
   echo "Usage: ./cr8_k8s_secrets <tls_certificate_filename> <tls_key_filename>"
   exit 1
fi

secret_dir="$(pwd)/secrets"
script_dir="$(pwd)/scripts"

mkdir -p "${secret_dir}"

cp "$tls_crt_file" "${secret_dir}/tls.crt"
cp "$tls_key_file" "${secret_dir}/tls.key"

printf '%s' 'jupyterhub' > "${secret_dir}/pg_username"

printf '%s' $(openssl rand -base64 12) > "${secret_dir}/pg_password"

base64 "${secret_dir}/pg_username" > "${secret_dir}/pg_username.b64"
base64 "${secret_dir}/pg_password" > "${secret_dir}/pg_password.b64"

base64 "${secret_dir}/tls.crt" > "${secret_dir}/tls.crt.b64"
base64 "${secret_dir}/tls.key" > "${secret_dir}/tls.key.b64"

awk -v val=$(cat "${secret_dir}/pg_username.b64") '{sub(/value_pg_username/, val); print}' "$(pwd)/secrets.yaml.tmpl" > "${secret_dir}/_temp_00.yaml"
awk -v val=$(cat "${secret_dir}/pg_password.b64") '{sub(/value_pg_password/, val); print}' "${secret_dir}/_temp_00.yaml" > "${secret_dir}/_temp_05.yaml"

awk -f "${script_dir}/block_subst.awk" -v block="value_tls_crt" "${secret_dir}/tls.crt.b64" "${secret_dir}/_temp_05.yaml" > "${secret_dir}/_temp_10.yaml"
awk -f "${script_dir}/block_subst.awk" -v block="value_tls_key" "${secret_dir}/tls.key.b64" "${secret_dir}/_temp_10.yaml" > "${secret_dir}/secrets.yaml"


# Clean up intermediate files
rm ${secret_dir}/pg_*
rm ${secret_dir}/*.b64
rm ${secret_dir}/_temp_*.yaml
