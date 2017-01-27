
Namespace httprequest

#If __TARGET__="android"

#Import "httprequest_android"

#Else If __TARGET__="macos" Or  __TARGET__="ios"

#Import "httprequest_ios"

#Endif
