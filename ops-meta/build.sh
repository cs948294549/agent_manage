#!/bin/bash
set -e

WORKSPACE=$(cd $(dirname $0)/; pwd)
cd "$WORKSPACE"

APP="ops-meta-https"
IMAGE="ops-meta-build"
OUTDIR="./build"
MODULE="meta-https"
VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "dev")

PLATFORMS="linux/amd64 linux/arm64"

mkdir -p "$OUTDIR"

for platform in $PLATFORMS; do
    GOOS="${platform%/*}"
    GOARCH="${platform#*/}"
    suffix="${GOOS}-${GOARCH}"
    tag="${IMAGE}:${suffix}"

    echo "==> Building ${APP} for ${suffix} ..."

    docker build -t "${tag}" \
        --build-arg TARGETOS="${GOOS}" \
        --build-arg TARGETARCH="${GOARCH}" \
        .

    cid=$(docker create "${tag}")
    docker cp "${cid}:/${APP}" "${OUTDIR}/${APP}-${suffix}"
    docker rm "${cid}" >/dev/null

    echo "    -> ${OUTDIR}/${APP}-${suffix}"
done

echo "==> Done. Binaries in ${OUTDIR}/"
ls -lh "${OUTDIR}/"

