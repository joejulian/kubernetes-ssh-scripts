#!/bin/sh

goarch() {
    # Pass the value of uname -m and optionally a second parameter specifying that the arch is little-endian ("le").
    case "$1" in
        x86_64)
            echo -n "amd64"
            ;;
        *86)
            echo -n "386"
            ;;
        arm*)
            echo -n "arm"
            ;;
        aarch64)
            echo -n "arm64"
            ;;
        ppc64le|ppc64|mips64|mips|s390x)
            if [[ "$2" == "le" ]]; then
                echo -n "${1}le"
            else
                echo -n "${1}"
            fi
            ;;
        * )
            echo "Unsupported architecture: $1" >&2
            exit 1
            ;;
    esac
}
