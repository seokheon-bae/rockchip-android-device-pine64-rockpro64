include device/pine64/rockpro64/BoardConfig.mk

# RockPro64 has no on-board sensors, but device/rockchip/common still installs
# android.hardware.sensors@1.0-service and declares ISensors in the VINTF
# manifest. Without a sensors.<board> module that HAL exits ("Couldn't load
# sensors module"), SystemSensorManager.nativeCreate() in system_server waits
# for it forever and the Watchdog kills system_server (endless boot animation).
# Keep the Tinker Board 2 sensor settings: the ST HAL builds and simply
# reports no sensors when none are present.
BOARD_SENSOR_ST := true
BOARD_SENSOR_COMPASS_AK8963-64 := true
BOARD_SENSOR_MPU_PAD := false
BOARD_COMPASS_SENSOR_SUPPORT := true
BOARD_GYROSCOPE_SENSOR_SUPPORT := true
CAMERA_SUPPORT_AUTOFOCUS:= false

# No MIPI camera by default (rkisp HAL off); USB (UVC) cameras via the external HAL
BOARD_CAMERA_SUPPORT := false
BOARD_CAMERA_SUPPORT_EXT := true
PRODUCT_KERNEL_DTS := rk3399-rockpro64-android

# AB image definition
BOARD_USES_AB_IMAGE := false
BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE := false
BOARD_HAS_RK_4G_MODEM := false

ifeq ($(strip $(BOARD_USES_AB_IMAGE)), true)
    include device/rockchip/common/BoardConfig_AB.mk
    TARGET_RECOVERY_FSTAB := device/pine64/rockpro64/RockPro64/recovery.fstab_AB
endif

BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/pine64/rockpro64/bluetooth

PRODUCT_FSTAB_TEMPLATE := device/pine64/rockpro64/RockPro64/fstab.in

TARGET_ROCKCHIP_PCBATEST := false
