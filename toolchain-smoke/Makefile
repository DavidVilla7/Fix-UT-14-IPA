THEOS ?= $(CURDIR)/.theos
TARGET := iphone:clang:9.3:8.0
ARCHS := armv7

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME := LinkerSmoke
LinkerSmoke_FILES := Probe.m
LinkerSmoke_FRAMEWORKS := Foundation
LinkerSmoke_CFLAGS := -fobjc-arc

include $(THEOS_MAKE_PATH)/library.mk
