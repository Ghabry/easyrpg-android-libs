LOCAL_PATH := $(call my-dir)
 
include $(CLEAR_VARS)
 
LOCAL_MODULE    := mad
LOCAL_SRC_FILES := \
	bit.c \
	decoder.c \
	fixed.c \
	frame.c \
	huffman.c \
	layer12.c \
	layer3.c \
	stream.c \
	synth.c \
	timer.c \
	version.c
LOCAL_CFLAGS := -DFPM_DEFAULT -ffast-math -O3
 
include $(BUILD_STATIC_LIBRARY)
