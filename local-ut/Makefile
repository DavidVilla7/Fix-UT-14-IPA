THEOS ?= $(CURDIR)/.theos
TARGET := iphone:clang:6.1:6.0
ARCHS := armv7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := FIFA14LocalUT
FIFA14LocalUT_FILES := Tweak.xm
FIFA14LocalUT_FRAMEWORKS := Foundation
FIFA14LocalUT_CFLAGS := -fno-objc-arc -Wall

include $(THEOS_MAKE_PATH)/tweak.mk
