include device/pine64/rockpro64/BoardConfig.mk

# RockPro64 has no on-board sensors
BOARD_SENSOR_ST := false
BOARD_SENSOR_MPU_PAD := false
BOARD_COMPASS_SENSOR_SUPPORT := false
BOARD_GYROSCOPE_SENSOR_SUPPORT := false
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
