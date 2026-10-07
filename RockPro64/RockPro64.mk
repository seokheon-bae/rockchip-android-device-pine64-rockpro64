#
# Copyright 2014 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# First lunching is S, api_level is 31
PRODUCT_SHIPPING_API_LEVEL := 31
PRODUCT_DTBO_TEMPLATE := $(LOCAL_PATH)/dt-overlay.in
PRODUCT_BOOT_DEVICE := fe330000.sdhci,fe320000.dwmmc
include device/rockchip/common/build/rockchip/DynamicPartitions.mk
include device/pine64/rockpro64/RockPro64/BoardConfig.mk
include device/rockchip/common/BoardConfig.mk
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
# Inherit from those products. Most specific first.
$(call inherit-product, device/pine64/rockpro64/device.mk)
$(call inherit-product, device/rockchip/common/device.mk)
# device/asus/common/device.mk is not inherited: it only adds ASUS apps
# (ASUSToolkit, DMClient, TinkerConfig, KioskMode) and AsusDebugger, whose
# Android.mk falls back to Tinker Board 1 (RK3288) binaries for other products.

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_NAME := RockPro64
PRODUCT_DEVICE := RockPro64
PRODUCT_BRAND := pine64
PRODUCT_MODEL := RockPro64
PRODUCT_MANUFACTURER := pine64
PRODUCT_AAPT_PREF_CONFIG := hdpi

PRODUCT_PACKAGES += \
    SoundRecorder

PRODUCT_PACKAGE_OVERLAYS += device/pine64/rockpro64/RockPro64/overlay
# Get the long list of APNs
PRODUCT_COPY_FILES += vendor/rockchip/common/phone/etc/apns-full-conf.xml:system/etc/apns-conf.xml
PRODUCT_COPY_FILES += vendor/rockchip/common/phone/etc/spn-conf.xml:system/etc/spn-conf.xml
PRODUCT_PROPERTY_OVERRIDES += \
    ro.product.version = 1.0.0 \
    ro.product.ota.host = 192.168.1.1:8888 \
    ro.sf.lcd_density=240

# Append the manifest files for RockPro64 here since this will be defined
# in device/rockchip/common/BoardConfig.mk to use the default one.
DEVICE_MANIFEST_FILE += device/pine64/rockpro64/manifest.xml


