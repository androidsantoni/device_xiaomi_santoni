#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0

if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

# Required!
DEVICE=santoni
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="$ANDROID_ROOT/tools/extract-utils/extract_utils.sh"
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
        case "${1}" in
	system/lib/libwfdnative.so | system/lib64/libwfdnative.so )
        "${PATCHELF}" --remove-needed "android.hidl.base@1.0.so" "${2}"
        ;;
	system/lib/libwfdmmsink.so )
        "${PATCHELF}" --add-needed "libwfdaudioclient.so" "${2}"
        "${PATCHELF}" --add-needed "libwfdmediautils.so" "${2}"
        ;;
	system/lib/libwfdaudioclient.so )
        "${PATCHELF}" --set-soname "libwfdaudioclient.so" "${2}"
        ;;
	system/lib/libwfdmediautils.so )
        "${PATCHELF}" --set-soname "libwfdmediautils.so" "${2}"
        ;;
	vendor/lib/libmmcamera2_sensor_modules.so )
        sed -i "s|/system/etc/camera/|/vendor/etc/camera/|g" "${2}"
        ;;
	vendor/lib/libmmcamera_dbg.so )
        sed -i "s|persist.camera.debug.logfile|persist.vendor.camera.dbglog|g" "${2}"
        ;;
	vendor/etc/init/android.hardware.gnss@2.1-service-qti.rc )
        sed -i -e "$a\\    capabilities NET_BIND_SERVICE" "${2}"
        ;;
	vendor/lib/libmmcamera2_stats_modules.so | vendor/lib/libmmcamera_ppeiscore.so | vendor/lib64/libmmsw_detail_enhancement.so | vendor/lib64/libmmsw_platform.so )
        "${PATCHELF}" --replace-needed "libgui.so" "libwui.so" "${2}"
        ;;
	vendor/bin/wcnss_service )
        "${PATCHELF}" --add-needed "libqmiservices_shim.so" "${2}"
        sed -i "s|dms_get_service_object_internal_v01|dms_get_service_object_shimshim_v01|g" "${2}"
        ;;
        esac
}

# Goodix
patchelf --add-needed fakelogprint.so gx_fpd
patchelf --add-needed fakelogprint.so fingerprint.goodix.so
patchelf --add-needed fakelogprint.so gxfingerprint.default.so

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}"/proprietary-files.txt "${SRC}" \
	"${KANG}" --section "${SECTION}"
extract "${MY_DIR}"/proprietary-files-qc.txt "$SRC" \
	"${KANG}" --section "${SECTION}"
extract "${MY_DIR}"/proprietary-files-qc-caf.txt "$SRC" \
	"${KANG}" --section "${SECTION}"

"${MY_DIR}"/setup-makefiles.sh
