# LineageOS (crDroid)
PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/lineage_santoni.mk

COMMON_LUNCH_CHOICES := \
    lineage_santoni-userdebug \
    lineage_santoni-user \
    lineage_santoni-eng

# HavocOS
PRODUCT_MAKEFILES += \
    $(LOCAL_DIR)/havoc_santoni.mk

COMMON_LUNCH_CHOICES += \
    havoc_santoni-userdebug \
    havoc_santoni-user \
    havoc_santoni-eng

# AOSiP
PRODUCT_MAKEFILES += \
    $(LOCAL_DIR)/aosip_santoni.mk

COMMON_LUNCH_CHOICES += \
    aosip_santoni-userdebug \
    aosip_santoni-user \
    aosip_santoni-eng
