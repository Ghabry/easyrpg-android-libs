#ifdef __ANDROID__
#include <jni.h>
#include "SDL_system.h"
#include "string.h"

#include "android.h"

char* get_timidity_path_jni() {
	JNIEnv* env = (JNIEnv*)SDL_AndroidGetJNIEnv();
	jobject sdl_activity = (jobject)SDL_AndroidGetActivity();
	jclass cls = (*env)->GetObjectClass(env, sdl_activity);
	jmethodID jni_getTimidityPath = (*env)->GetMethodID(env, cls , "getTimidityPath", "()Ljava/lang/String;");
	jstring return_string = (jstring)(*env)->CallObjectMethod(env, sdl_activity, jni_getTimidityPath);
			
	const char *js = (*env)->GetStringUTFChars(env, return_string, NULL);
	
	char* ret_str = (char*)malloc(strlen(js) + 1);
	strncpy(ret_str, js, strlen(js) + 1);

	(*env)->ReleaseStringUTFChars(env, return_string, js);
	(*env)->DeleteLocalRef(env, sdl_activity);
	(*env)->DeleteLocalRef(env, cls);

	return ret_str;
}

#endif
