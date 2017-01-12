
Namespace jni

#If __TARGET__="android"

#Import "<mojo>"

#Import "native/jni_glue.cpp"
#Import "native/jni_glue.h"

Extern

Class jobject Extends Void
End

Class jclass Extends jobject
End

Class jfieldID Extends Void
End

Class jmethodID Extends Void
End

Function FindClass:jclass( name:CString )="bbJNI::FindClass"

Function GetMethodID( clazz:jclass,name:CString,sig:CString )="bbJNI::GetMethodID"

#End
