#Android makefile to build kernel as a part of Android Build
BACKPORT_DIR := $(call my-dir)

include $(CLEAR_VARS)

PERL            = perl

PREFIX := $(shell echo $(TARGET_OUT_INTERMEDIATES) | head -c 3)

$(warning $(PREFIX))

ifeq ($(PREFIX),out)
BACKPORTS_KERNEL_OUT := ../../$(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
else
BACKPORTS_KERNEL_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
endif

BACKPORTS_KERNEL_DEFCONFIG := defconfig-bluetooth

BACKPORTS_KERNEL_CONFIG := $(BACKPORT_DIR)/.config

BACKPORTS_KERNEL_HEADERS_INSTALL := $(KERNEL_OUT)/usr
BACKPORTS_KERNEL_MODULES_INSTALL := system
BACKPORTS_KERNEL_MODULES_OUT := $(TARGET_OUT)/lib/modules


ifeq ($(TARGET_ARCH),arm64)
BACKPORTS_CROSS_COMPILE :=aarch64-linux-androidkernel-
else
BACKPORTS_CROSS_COMPILE :=arm-linux-androideabi-
endif

define mv-backports-modules
ko=`find $(BACKPORT_DIR) -type f -name *.ko`;\
for i in $$ko; do mv $$i $(BACKPORTS_KERNEL_MODULES_OUT)/; done;
endef

define clean-backports-module-folder
mdpath=`find $(BACKPORTS_KERNEL_MODULES_OUT) -type f -name modules.dep`;\
if [ "$$mdpath" != "" ];then\
mpath=`dirname $$mdpath`; rm -rf $$mpath;\
fi
endef

$(BACKPORTS_KERNEL_CONFIG):
	$(MAKE) -C $(BACKPORT_DIR) O=$(BACKPORTS_KERNEL_OUT) KLIB_BUILD=$(BACKPORTS_KERNEL_OUT) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(BACKPORTS_CROSS_COMPILE) $(BACKPORTS_KERNEL_DEFCONFIG)

backports: $(BACKPORTS_KERNEL_CONFIG)
	$(MAKE) -C $(BACKPORT_DIR) EXTRA_CFLAGS="-fno-pic" O=$(BACKPORTS_KERNEL_OUT) KLIB_BUILD=$(BACKPORTS_KERNEL_OUT) ARCH=$(TARGET_ARCH) CROSS_COMPILE=$(BACKPORTS_CROSS_COMPILE)
	$(mv-backports-modules)
	$(clean-backports-module-folder)

include $(CLEAR_VARS)
