#!/usr/bin/env bash
# onnxruntime 1.24.4 바이너리를 third_party/ 에 다운로드합니다.
set -e

VERSION="1.24.4"
DIR="$(cd "$(dirname "$0")/.." && pwd)/third_party"
mkdir -p "$DIR"

OS="$(uname -s)"
ARCH="$(uname -m)"

if [ "$OS" = "Linux" ]; then
    if [ "$ARCH" = "aarch64" ]; then
        PKG="onnxruntime-linux-aarch64-${VERSION}"
    else
        PKG="onnxruntime-linux-x64-${VERSION}"
    fi
    EXT="tgz"
elif [ "$OS" = "Darwin" ]; then
    PKG="onnxruntime-osx-universal2-${VERSION}"
    EXT="tgz"
else
    echo "Windows는 fetch_onnxruntime.bat 를 사용하세요."
    exit 1
fi

URL="https://github.com/microsoft/onnxruntime/releases/download/v${VERSION}/${PKG}.${EXT}"
DEST="$DIR/${PKG}.${EXT}"

if [ -d "$DIR/$PKG" ]; then
    echo "이미 존재합니다: $DIR/$PKG"
    exit 0
fi

echo "다운로드 중: $URL"
curl -L -o "$DEST" "$URL"
tar xzf "$DEST" -C "$DIR"
rm "$DEST"
echo "완료: $DIR/$PKG"
