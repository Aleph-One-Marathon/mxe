# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := ffmpeg
$(PKG)_WEBSITE  := https://ffmpeg.org/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.2.3
$(PKG)_CHECKSUM := 217eb211c33303b37c5521a5abe1f0140854d6810c6a6ee399456cc96356795e
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://ffmpeg.org/releases/$($(PKG)_FILE)
$(PKG)_DEPS     := cc bzip2 \
                   libvpx sdl speex \
                   vorbis yasm zlib

# DO NOT ADD fdk-aac OR openssl SUPPORT.
# Although they are free softwares, their licenses are not compatible with
# the GPL, and we'd like to enable GPL in our default ffmpeg build.
# See docs/index.html#potential-legal-issues

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://ffmpeg.org/releases/' | \
    $(SED) -n 's,.*ffmpeg-\([0-9][^>]*\)\.tar.*,\1,p' | \
    grep -v 'alpha\|beta\|rc\|git' | \
    $(SORT) -Vr | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        --cross-prefix='$(TARGET)'- \
        --enable-cross-compile \
        --arch=$(firstword $(subst -, ,$(TARGET))) \
        --target-os=mingw32 \
        --prefix='$(PREFIX)/$(TARGET)' \
        $(if $(BUILD_STATIC), \
            --enable-static --disable-shared , \
            --disable-static --enable-shared ) \
        --yasmexe='$(TARGET)-yasm' \
        --disable-debug \
        --disable-pthreads \
        --enable-w32threads \
        --disable-doc \
        --enable-avresample \
        --enable-gpl \
        --enable-version3 \
        --extra-libs='-mconsole' \
        --enable-libspeex \
        --enable-libvorbis \
        --enable-libvpx \
        --disable-decoders \
        --disable-encoders \
        --disable-demuxers \
        --disable-muxers \
        --disable-protocols \
        --enable-muxer=webm \
        --enable-encoder=libvorbis \
        --enable-encoder=libvpx_vp8 \
        --enable-demuxer=aiff \
        --enable-demuxer=mp3 \
        --enable-demuxer=mpegps \
        --enable-demuxer=mpegts \
        --enable-demuxer=mpegtsraw \
        --enable-demuxer=mpegvideo \
        --enable-demuxer=ogg \
        --enable-demuxer=wav \
        --enable-parser=mpegaudio \
        --enable-parser=mpegvideo \
        --enable-decoder=adpcm_ima_wav \
        --enable-decoder=adpcm_ms \
        --enable-decoder=gsm \
        --enable-decoder=gsm_ms \
        --enable-decoder=mp1 \
        --enable-decoder=mp1float \
        --enable-decoder=mp2 \
        --enable-decoder=mp2float \
        --enable-decoder=mp3 \
        --enable-decoder=mp3float \
        --enable-decoder=mpeg1video \
        --enable-decoder=pcm_alaw \
        --enable-decoder=pcm_f32be \
        --enable-decoder=pcm_f32le \
        --enable-decoder=pcm_f64be \
        --enable-decoder=pcm_f64le \
        --enable-decoder=pcm_mulaw \
        --enable-decoder=pcm_s8 \
        --enable-decoder=pcm_s8_planar \
        --enable-decoder=pcm_s16be \
        --enable-decoder=pcm_s16le \
        --enable-decoder=pcm_s16le_planar \
        --enable-decoder=pcm_s24be \
        --enable-decoder=pcm_s24le \
        --enable-decoder=pcm_s32be \
        --enable-decoder=pcm_s32le \
        --enable-decoder=pcm_u8 \
        --enable-decoder=theora \
        --enable-decoder=vorbis \
        --enable-decoder=vp8 \
        --enable-protocol=file \
        $($(PKG)_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install
endef
