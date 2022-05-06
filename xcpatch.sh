#!/usr/bin/env bash

set -euo pipefail

TMP_DIR="$(mktemp -d)"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
MINOS=12.0  # min supported ios version
SDK=15.0    # build sdk version

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

usage() {
  cat <<EOF
Patches an xcframework without M1 support to work on M1 Macs.

USAGE: xcpatch.sh --xcframework <PATH>

  PATH  path to the xcframework to patch.

RESOURCES:

https://bogo.wtf/arm64-to-sim.html
https://bogo.wtf/arm64-to-sim-dylibs.html
EOF
}

# Prints path to an arm64 ios library to patch.
# Args:
#   $1 - path to the xcframework.
bin_path() {
  local xcframework="${1}" binname
  binname="$(basename "${xcframework}" .xcframework)"
  echo "${xcframework}/ios-arm64/${binname}.framework/${binname}"
}

# Prints path to an existing x86_64 sim library which to make a fat binary.
# Args:
#   $1 - path to the xcframework.
outbin_path() {
  local xcframework="${1}" binname
  binname="$(basename "${xcframework}" .xcframework)"
  echo "${xcframework}/ios-x86_64-simulator/${binname}.framework/${binname}"
}
# Makes a static sim fat library out of arm64 ios and x86_64 sim libraries.
# Args:
#   $1 - path to the arm64 ios library.
#   $2 - path to the x86_64 sim library.
#   $3 - path to a directory to store temp files.
make_ar() {
    echo make_ar
  local ar_path="${1}" outar_path="${2}" wrkdir="${3}"

  # extract arm64 archive first
  if file "${ar_path}" | grep "universal binary" >/dev/null; then
    lipo -thin arm64 -o "${wrkdir}/arm64" "${ar_path}"
  else
    cp "${ar_path}" "${wrkdir}/arm64"
  fi

  pushd "${wrkdir}" >/dev/null
  # extract object files to patch
  ar x arm64 && rm arm64
  for obj in *.o; do
    if xcrun vtool -show "${obj}" | grep LC_BUILD_VERSION >/dev/null; then
      # some object files may already have LC_BUILD_VERSION but for iOS platform
      # we need to change it to simulators
      xcrun vtool -remove-build-version 2 -output "${obj}" "${obj}"
      xcrun vtool -set-build-version 7 "${MINOS}" "${SDK}" -output "${obj}" "${obj}"
    else
      # if not, patch object files
     "${SCRIPT_DIR}/bin/arm64-to-sim" "${obj}" "$MINOS" "$SDK"
    fi
  done
  # make arm64 archive out of patches object files
  ar crv arm64 *.o
  popd >/dev/null

  # make fat library
  cp "${outar_path}" "${wrkdir}/x86_64"
  lipo -create -output "${outar_path}" "${wrkdir}/arm64" "${wrkdir}/x86_64"
}

# Makes a dynamic sim fat library out of arm64 ios and x86_64 sim libraries.
# Args:
#   $1 - path to the arm64 ios library.
#   $2 - path to the x86_64 sim library.
#   $3 - path to a directory to store temp files.
make_dylib() {
  local dylib_path="${1}" outdylib_path="${2}" wrkdir="${3}"
  cp "${outdylib_path}" "${wrkdir}/x86_64"
  # patch arm64 dylib to run on simulators
  xcrun vtool \
    -arch arm64 \
    -set-build-version 7 "${MINOS}" "${SDK}" \
    -replace \
    -output "${wrkdir}/arm64" \
    "${dylib_path}"
  # make fat library
  lipo -create -output "${outdylib_path}" "${wrkdir}/arm64" "${wrkdir}/x86_64"
  # signing it is mandatory for M1
  xcrun codesign --force --sign - "${outdylib_path}"
}

# Updates xcframework's layout to indicate arm64 support for simulators.
# Args:
#   $1 - path to the xcframework.
update_layout() {
  local xcframework="${1}" plist="${xcframework}/Info.plist"
  mv "${xcframework}/ios-x86_64-simulator" "${xcframework}/ios-arm64_x86_64-simulator"

  # patch info.plist to indicate arm64 support
  #sed -i "" \
    's|<string>ios-x86_64-simulator</string>|<string>ios-arm64_x86_64-simulator</string>|' \
    "${plist}"
  #sed -i "" \
    's|<string>x86_64</string>|<string>x86_64</string>\n\t\t\t\t<string>arm64</string>|' \
    "${plist}"
}

main() {
  local xcframework
  while [[ "$#" -gt 0 ]]; do
    case "${1}" in
      -h|--help)
        usage
        exit
        ;;
      --xcframework)
        xcframework="${2}"
        ;;
      --*)
        usage
        exit 1
        ;;
    esac
    shift
  done

  local bin outbin
  bin="$(set -e; bin_path "${xcframework}")"
  outbin="$(set -e; outbin_path "${xcframework}")"
  
  # check if it's a static or dynamic framework
  if file "${bin}" | grep "current ar archive" >/dev/null; then
    make_ar "${bin}" "${outbin}" "${TMP_DIR}"
  else
    make_dylib "${bin}" "${outbin}" "${TMP_DIR}"
  fi

  update_layout "${xcframework}"
}

main "$@"
