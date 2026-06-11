#!/bin/sh
# Builds RtMidi for iOS as an .xcframework containing a device slice (arm64)
# and a simulator slice (arm64 + x86_64), then installs it into the package.
#
# An .xcframework is required because, on Apple Silicon, the device and the
# simulator are both arm64 but carry different Mach-O platform tags; they
# cannot be merged into a single static library with lipo.
set -eux

PKG=../Packages/jp.keijiro.rtmidi/Runtime/Plugins/iOS
DIST=dist-iOS
rm -rf "$DIST" && mkdir -p "$DIST/sim"

# Device (iphoneos): arm64
make ARCH=arm64 -f Makefile.ios

# Simulator (iphonesimulator): arm64 + x86_64
make ARCH=arm64  -f Makefile.ios-simulator
make ARCH=x86_64 -f Makefile.ios-simulator
lipo -create -output "$DIST/sim/libRtMidi.a" \
  build-iOS-simulator-arm64/libRtMidi.a \
  build-iOS-simulator-x86_64/libRtMidi.a

cp build-iOS-arm64/libRtMidi.a "$DIST/libRtMidi.a"

rm -rf "$DIST/RtMidi.xcframework"
xcodebuild -create-xcframework \
  -library "$DIST/libRtMidi.a"     -headers ./rtmidi_c.h \
  -library "$DIST/sim/libRtMidi.a" -headers ./rtmidi_c.h \
  -output "$DIST/RtMidi.xcframework"

rm -rf "$PKG/RtMidi.xcframework"
cp -R "$DIST/RtMidi.xcframework" "$PKG/RtMidi.xcframework"
