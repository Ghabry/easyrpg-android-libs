LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := main

SDL_PATH := ../SDL2-2.0.3
SDL_MIXER_PATH := ../SDL2_mixer-2.0.0

LOCAL_CPP_EXTENSION := .cxx .cpp

LOCAL_C_INCLUDES := $(LOCAL_PATH)/$(SDL_PATH)/include \
	$(LOCAL_PATH)/$(SDL_MIXER_PATH)

# Add your application source files here...
LOCAL_SRC_FILES :=

LOCAL_SHARED_LIBRARIES := SDL2 SDL2_mixer expat pixman png iconv freetype2-static mad

LOCAL_STATIC_LIBRARIES := cpufeatures

LOCAL_LDLIBS := -lGLESv1_CM -llog -lz

LOCAL_CFLAGS := -O2 -Wall -Wextra -fno-rtti -DUSE_SDL -DHAVE_SDL_MIXER -DNDEBUG -DUNIX
LOCAL_CPPFLAGS	=	$(LOCAL_C_FLAGS) -fno-exceptions -std=c++0x

include $(BUILD_SHARED_LIBRARY)

$(call import-module,android/cpufeatures)
