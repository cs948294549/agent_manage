#!/bin/bash
set -e

APP="ops-updater"
IMAGE="ops-updater-build"
OUTDIR="./build"

PLATFORMS="linux/amd64 linux/arm64"

mkdir -p "$OUTDIR"

for platform in $PLATFORMS; do
    GOOS="${platform%/*}"
    GOARCH="${platform#*/}"
    suffix="${GOOS}-${GOARCH}"
    tag="${IMAGE}:${suffix}"

    echo "==> Building ${APP} for ${suffix} ..."

    docker build \
        --build-arg TARGETARCH="${GOARCH}" \
        -t "${tag}" .

    cid=$(docker create "${tag}")
    docker cp "${cid}:/${APP}" "${OUTDIR}/${APP}-${suffix}"
    docker rm "${cid}" >/dev/null

    echo "    -> ${OUTDIR}/${APP}-${suffix}"
done

echo "==> Done. Binaries in ${OUTDIR}/"
ls -lh "${OUTDIR}/"

