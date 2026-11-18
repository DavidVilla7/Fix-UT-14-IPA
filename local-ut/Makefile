THEOS ?= $(CURDIR)/.theos
TARGET := iphone:clang:9.3:7.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := FIFA14LocalUT
FIFA14LocalUT_FILES := Tweak.xm
FIFA14LocalUT_FRAMEWORKS := Foundation
FIFA14LocalUT_CFLAGS := -fno-objc-arc -Wall

include $(THEOS_MAKE_PATH)/tweak.mk
