TARGET := iphone:clang:latest:7.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTSideloadSignInFix

YTSideloadSignInFix_FILES = Tweak.x
YTSideloadSignInFix_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
