#!/usr/bin/env bash
set -euo pipefail

#  Konfigurasi dasar
IMAGE_NAME="item-app"
IMAGE_TAG="v1"
LOCAL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

# Membangun image dari Dockerfile di direktori saat ini (.) dan memberi tag "item-app:v1".
echo "1) Build image ${LOCAL_IMAGE}"
docker build -t "${LOCAL_IMAGE}" .

# Menampilkan daftar image yang ada di mesin lokal untuk verifikasi.
echo "2) Lihat daftar image lokal"
docker image ls

echo "3) Tag image agar sesuai format registry tujuan"
GHCR_USERNAME="${GHCR_USERNAME:-}"
GHCR_TOKEN="${GHCR_TOKEN:-}"
if [[ -z "${GHCR_USERNAME}" ]]; then read -rp "GHCR username: " GHCR_USERNAME; fi # Ambil username GHCR dari env var jika ada…
if [[ -z "${GHCR_TOKEN}" ]]; then read -rsp "GHCR Personal Access Token: " GHCR_TOKEN; echo; fi # …dan token PAT dari env var jika ada.

# Bentuk nama image untuk GHCR: ghcr.io/<OWNER>/<IMAGE_NAME>:<TAG>
# Contoh: ghcr.io/mufidfarhan/item-app:v1
REMOTE_IMAGE="ghcr.io/${GHCR_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"

# Re-tag image lokal agar cocok dengan nama di registry tujuan.
docker tag "${LOCAL_IMAGE}" "${REMOTE_IMAGE}"

# Login ke GHCR menggunakan PAT lewat stdin (lebih aman: tidak tersimpan di history shell).
echo "4) Login ke GHCR"
echo "${GHCR_TOKEN}" | docker login ghcr.io -u "${GHCR_USERNAME}" --password-stdin

# Mengunggah (push) image yang sudah di-tag ke GHCR.
echo "5) Push image ke registry (${REGISTRY})"
docker push "${REMOTE_IMAGE}"

echo "Selesai. Image terunggah sebagai: ${REMOTE_IMAGE}"