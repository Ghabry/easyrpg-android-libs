LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES = \
         pixman/pixman.c \
         pixman/pixman-access.c \
         pixman/pixman-access-accessors.c \
         pixman/pixman-arm.c \
         pixman/pixman-arm-simd.c \
         pixman/pixman-arm-simd-asm.S \
         pixman/pixman-arm-neon.c \
         pixman/pixman-arm-neon-asm.S \
         pixman/pixman-arm-neon-asm-bilinear.S \
		 pixman/pixman-arm-simd-asm-scaled.S \
         pixman/pixman-bits-image.c \
         pixman/pixman-combine32.c \
         pixman/pixman-combine-float.c \
         pixman/pixman-conical-gradient.c \
         pixman/pixman-edge.c \
         pixman/pixman-edge-accessors.c \
         pixman/pixman-fast-path.c \
		 pixman/pixman-filter.c \
         pixman/pixman-general.c \
         pixman/pixman-glyph.c \
         pixman/pixman-gradient-walker.c \
         pixman/pixman-image.c \
         pixman/pixman-implementation.c \
         pixman/pixman-linear-gradient.c \
         pixman/pixman-matrix.c \
         pixman/pixman-mips.c \
         pixman/pixman-noop.c \
         pixman/pixman-ppc.c \
         pixman/pixman-radial-gradient.c \
         pixman/pixman-region16.c \
         pixman/pixman-region32.c \
         pixman/pixman-solid-fill.c \
         pixman/pixman-timer.c \
         pixman/pixman-trap.c \
         pixman/pixman-utils.c \
         pixman/pixman-x86.c \


LIBPIXMAN_CFLAGS:=-DPIXMAN_NO_TLS -DPACKAGE="android-cairo" -DUSE_ARM_NEON -DUSE_ARM_SIMD -include "limits.h"

LOCAL_MODULE := libpixman
LOCAL_C_INCLUDES := $(LOCAL_PATH)
LOCAL_C_INCLUDES += $(LOCAL_PATH)/pixman
LOCAL_CFLAGS := -O2 $(LIBPIXMAN_CFLAGS) -I$(LOCAL_PATH)/pixman -I$(LOCAL_PATH)/pixman-extra
LOCAL_LDFLAGS :=
#LOCAL_SRC_FILES := $(LIBPIXMAN_SRC)
LOCAL_STATIC_LIBRARIES := cpufeatures

include $(BUILD_STATIC_LIBRARY)