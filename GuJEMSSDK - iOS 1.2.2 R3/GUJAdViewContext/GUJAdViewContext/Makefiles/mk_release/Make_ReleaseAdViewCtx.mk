# BSD LICENSE
# Copyright (c) 2012, Mobile Unit of G+J Electronic Media Sales GmbH, Hamburg All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, 
# this list of conditions and the following disclaimer .
# Redistributions in binary form must reproduce the above copyright notice, 
# this list of conditions and the following disclaimer in the documentation 
# and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. 
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# The source code is just allowed for private use, not for commercial use.
#
# GUJ Makefile Set (Build Bundle) 
# 2012/11 Sven Ewert (sven.ewert@somo.de)
#
#

include $(MAKEFILE_DIR)Make_ReleaseGlobalVars.mk
include $(MAKEFILE_DIR)Make_ReleaseFunctions.mk

_TARGET_NAME                = GUJXAdViewContext
_TARGET_DIR                 = $(_BUNDLE_DIR)$(_TARGET_NAME)/

ifdef EXT_LIB_DIR
EXTLIBDIR                   = $(EXT_LIB_DIR)
else
EXTLIBDIR                   = $(_TARGET_DIR)
endif

ifdef RELEASE
_BUILD_DIR                  = $(_TARGET_DIR)Build/Release/
else
_BUILD_DIR                  = $(_TARGET_DIR)Build/Debug/
endif
_LIB_SDK_NAME               = libGUJAdViewContext
_LIB_SDK_NAME_SIM           = libGUJAdViewContextSimulator
_SOURCE_LIB_SDK             = $(_LIB_SDK_NAME).a
_SOURCE_LIB_SDK_SIM 		= $(_LIB_SDK_NAME_SIM).a

_ARMV6_AR_DIR               = $(_BUILD_DIR_IPHONEOS_ARMV6)$(_AR_DIR)
_ARMV6_LIB_SDK              = $(_LIB_SDK_NAME)_armv6.a
_ARMV6_LIB_SDK_DIR          = $(_BUILD_DIR_IPHONEOS_ARMV6)$(_ARMV6_LIB_SDK)
_ARMV6_LIB_MERGED           = $(_TARGET_NAME)_armv6_merged.a
_ARMV6_LIB_MERGED_DIR		= $(_BUILD_DIR_IPHONEOS_ARMV6)$(_ARMV6_LIB_MERGED)

_ARMV7_AR_DIR               = $(_BUILD_DIR_IPHONEOS_ARMV7)$(_AR_DIR)
_ARMV7_LIB_SDK              = $(_LIB_SDK_NAME)_armv7.a
_ARMV7_LIB_SDK_DIR          = $(_BUILD_DIR_IPHONEOS_ARMV7)$(_ARMV7_LIB_SDK)
_ARMV7_LIB_MERGED           = $(_TARGET_NAME)_armv7_merged.a
_ARMV7_LIB_MERGED_DIR		= $(_BUILD_DIR_IPHONEOS_ARMV7)$(_ARMV7_LIB_MERGED)

_i386_AR_DIR                = $(_BUILD_IPHONESIMULATOR_i386)$(_AR_DIR)
_i386_LIB_SDK               = $(_LIB_SDK_NAME)_i386.a
_i386_LIB_SDK_DIR           = $(_BUILD_IPHONESIMULATOR_i386)$(_i386_LIB_SDK)

_i386_LIB_MERGED            = $(_TARGET_NAME)_i386_merged.a
_i386_LIB_MERGED_DIR		= $(_BUILD_IPHONESIMULATOR_i386)$(_i386_LIB_MERGED)


ifdef RELEASE
_SRC_LIB_LOC_IPHONEOS		= $(BINARY_DIR)$(_DIR_RELEASE_IPHONEOS)
_SRC_LIB_LOC_IPHONSIMULATOR	= $(BINARY_DIR)$(_DIR_RELEASE_IPHONESIMULATOR)

_LIB_IPHONEOS               = $(_TARGET_DIR_RELEASE)$(_DIR_RELEASE_IPHONEOS)lib$(_TARGET_NAME).a
_LIB_IPHONESIMULATOR		= $(_TARGET_DIR_RELEASE)$(_DIR_RELEASE_IPHONESIMULATOR)lib$(_TARGET_NAME)Simulator.a
_LIB_UNIVERSAL              = $(_TARGET_DIR_RELEASE)$(_DIR_RELEASE_UNIVERSAL)lib$(_TARGET_NAME)Universal.a

_copyHeader                 = `cp -a $(_SRC_LIB_LOC_IPHONEOS)GUJAdViewContext.h $(_TARGET_DIR_RELEASE)`
_copyResources              = `cp -aR $(BINARY_DIR)$(__BASE_DIR__)$(_DIR_RESOURCES)ORMMAResourceBundle.bundle $(_TARGET_DIR_RELEASE) && cp -aR $(BINARY_DIR)$(__BASE_DIR__)$(_DIR_RESOURCES)VideoAdLib.bundle $(_TARGET_DIR_RELEASE)`


ifdef SKIP_EXTERNAL_LIB
MakeExtractUnderlyingSDK	= `make -f $(MAKEFILE_DIR)Make_ReleaseXaxsisSDK.mk extract_xaxsis_sdk _BUILD_DIR=$(_BUILD_DIR) EXT_LIB_DIR=$(_TARGET_DIR) >> $(__LOGFILE__)  && make -f $(MAKEFILE_DIR)Make_ReleaseXaxsisSDK.mk clean_xaxsis_sdk >> $(__LOGFILE__)`
else
MakeExtractUnderlyingSDK	= `make -f $(MAKEFILE_DIR)Make_ReleaseXaxsisSDK.mk extract_xaxsis_sdk _BUILD_DIR=$(_BUILD_DIR) >> $(__LOGFILE__)  && make -f $(MAKEFILE_DIR)Make_ReleaseXaxsisSDK.mk clean_xaxsis_sdk >> $(__LOGFILE__)`
endif


else
_SRC_LIB_LOC_IPHONEOS		= $(BINARY_DIR)$(_DIR_DEBUG_IPHONEOS)
_SRC_LIB_LOC_IPHONSIMULATOR	= $(BINARY_DIR)$(_DIR_DEBUG_IPHONESIMULATOR)

_LIB_IPHONEOS               = $(_TARGET_DIR_DEBUG)$(_DIR_DEBUG_IPHONEOS)lib$(_TARGET_NAME).a
_LIB_IPHONESIMULATOR		= $(_TARGET_DIR_DEBUG)$(_DIR_DEBUG_IPHONESIMULATOR)lib$(_TARGET_NAME)Simulator.a
_LIB_UNIVERSAL              = $(_TARGET_DIR_DEBUG)$(_DIR_DEBUG_UNIVERSAL)lib$(_TARGET_NAME)Universal.a

_copyHeader                 = `cp -a $(_SRC_LIB_LOC_IPHONEOS)GUJAdViewContext.h $(_TARGET_DIR_DEBUG)`
_copyResources              = `cp -aR $(BINARY_DIR)$(__BASE_DIR__)$(_DIR_RESOURCES)ORMMAResourceBundle.bundle $(_TARGET_DIR_DEBUG) && cp -aR $(BINARY_DIR)$(__BASE_DIR__)$(_DIR_RESOURCES)VideoAdLib.bundle $(_TARGET_DIR_DEBUG)`


ifdef SKIP_EXTERNAL_LIB
MakeExtractUnderlyingSDK	= `make -f $(MAKEFILE_DIR)Make_ReleaseXaxsisSDK.mk extract_xaxsis_sdk _BUILD_DIR=$(_BUILD_DIR) EXT_LIB_DIR=$(_TARGET_DIR) >> $(__LOGFILE__)  && make -f $(MAKEFILE_DIR)Make_ReleaseXaxsisSDK.mk clean_xaxsis_sdk >> $(__LOGFILE__) `
else
MakeExtractUnderlyingSDK	= `make -f $(MAKEFILE_DIR)Make_ReleaseXaxsisSDK.mk extract_xaxsis_sdk _BUILD_DIR=$(_BUILD_DIR) >> $(__LOGFILE__) && make -f $(MAKEFILE_DIR)Make_ReleaseXaxsisSDK.mk clean_xaxsis_sdk >> $(__LOGFILE__)`
endif


endif

build_adview_sdk: extract_adviewctx_sdk merge_libraries

merge_libraries:
	$(_createMergedLibArmV6)
	$(_createMergedLibArmV7)
	$(_createMergedLibi386)
	$(_createFatiPhoneOSLibrary)
	$(_copyMergedLibi386Library)
	$(_createFatUniversalLibrary)
	$(_copyHeader)
	$(_copyResources)

extract_adviewctx_sdk:
	$(_createTargetDirectories)
	$(_createBuildDirectories)
	$(MakeExtractUnderlyingSDK)
	$(_extractArmV6)
	$(_extractArmV7)
	$(_extracti386)
