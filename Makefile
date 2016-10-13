SHELL = /bin/bash

# target arch
arch = native
CPU  = native

# components
enable-openssl = y
enable-libmp3lame = y
enable-libopencore-amrnb = y
enable-libopencore-amrwb = y
enable-libx264 = y



destdir=$(CURDIR)/arch/$(arch)/$(packdir)


components = \
    $(foreach var, $(filter enable-%,$(.VARIABLES)),\
        $(if $(filter y,$($(var))),\
            $(subst enable-,,$(var)),))

component_opts = \
	$(addprefix --enable-,$(components)) 

include arch/$(arch)/config.mk


CPPFLAGS 	+= -I$(destdir)$(prefix)/include
LDFLAGS 	+= -L$(destdir)$(prefix)/lib -L$(destdir)$(prefix)/lib64
LDXXFLAGS 	+= -L$(destdir)$(prefix)/lib -L$(destdir)$(prefix)/lib64


PATH := $(destdir)$(prefix)/bin:$(PATH)
export PATH

LD_LIBRARY_PATH := $(destdir)$(prefix)/lib:$(destdir)$(prefix)/lib64:$(LD_LIBRARY_PATH)
export LD_LIBRARY_PATH


ifneq ($(arch),native)

enable_cross_compile = --enable-cross-compile --arch=$(host) --cc="$(CC)" --cxx="$(CXX)"
	
#export AS
export CC
export CPP
export CXX
export LD
export LDXX
export AR
export NM
export STRIP
export OBJCOPY
export OBJDUMP
export HOST_CC
export HOST_CXX
export HOST_LD
export HOST_LDXX

endif


ffmpeg: configure-ffmpeg
	cd modules/ffmpeg && \
		$(MAKE) V=1 all install DESTDIR=$(destdir)

configure-ffmpeg: modules/ffmpeg/configure 
	cd modules/ffmpeg && \
		unset arch && \
		./configure \
			--prefix=$(prefix) \
			--target-os=linux \
			--cpu=$(CPU) \
			--disable-doc \
			--enable-gpl \
			--enable-nonfree \
			--enable-version3 \
			--enable-avresample \
			--extra-cflags="$(CPPFLAGS)" \
			--extra-cxxflags="$(CPPFLAGS)" \
			--extra-ldflags="$(LDFLAGS) -ldl" \
			--extra-ldexeflags="$(LDFLAGS) -ldl" \
			--ld="$(CC)" \
			--strip="$(STRIP)" \
			$(component_opts) \
			$(enable_cross_compile)


get-ffmpeg: modules modules/ffmpeg/configure
modules/ffmpeg/configure: 
	mkdir -p modules && cd modules && \
		git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg

clean-ffmpeg:
	cd modules/ffmpeg && \
		$(MAKE) V=1 clean

distclean-ffmpeg:
	cd modules/ffmpeg && \
		$(MAKE) V=1 distclean

test:
	@echo "components: $(components)"
	@echo "component_opts: $(component_opts)"
	@echo "PATH=$(PATH)"



components: $(components)

.PHONY: clean
clean: $(addprefix clean-,$(components))

.PHONY: distclean
distclean: $(addprefix distclean-,$(components))

.PHONY: 
uninstall: $(addprefix uninstall-,$(components))





###################################################################################################################

libmp3lame: $(destdir)$(prefix)/lib/libmp3lame.a
$(destdir)$(prefix)/lib/libmp3lame.a: modules/lame/config.h
	cd modules/lame && \
		$(MAKE) all install DESTDIR=$(destdir)
	

configure-libmp3lame: modules/lame/config.h
modules/lame/config.h: modules/lame/README
	cd modules/lame && \
		autoreconf -fi && \
			./configure \
				--prefix=$(prefix) \
				--enable-shared=yes \
				--enable-static=yes \
				--with-pic=yes \
				--host=$(host)


get-libmp3lame: modules/lame/README
modules/lame/README: 
	mkdir -p modules && cd modules && \
		cvs -z3 -d:pserver:anonymous@lame.cvs.sourceforge.net:/cvsroot/lame co -P lame

	
uninstall-libmp3lame:
	$(MAKE) -i -C modules/lame uninstall DESTDIR=$(destdir)

clean-libmp3lame:
	$(MAKE) -i -C modules/lame clean

distclean-libmp3lame:
	$(MAKE) -i -C modules/lame distclean



###################################################################################################################

libopencore-amrnb libopencore-amrwb : opencore-amr		


opencore-amr: $(destdir)$(prefix)/lib/libopencore-amrnb.a $(destdir)$(prefix)/lib/libopencore-amrwb.a
$(destdir)$(prefix)/lib/libopencore-amrnb.a $(destdir)$(prefix)/lib/libopencore-amrwb.a: modules/opencore-amr/Makefile
	cd modules/opencore-amr && \
		$(MAKE) V=1 all install DESTDIR=$(destdir)
	
	
configure-opencore-amr: modules/opencore-amr/Makefile
modules/opencore-amr/Makefile: modules/opencore-amr/.git/index
	cd modules/opencore-amr && \
		autoreconf -fi && \
			ac_cv_func_malloc_0_nonnull=yes ./configure \
				--prefix=$(prefix) \
				--enable-static=yes \
				--enable-shared=yes \
				--with-pic=yes \
				--host=$(host)


get-opencore-amr: modules/opencore-amr/.git/index
modules/opencore-amr/.git/index:  
	mkdir -p modules && cd modules && \
		git clone git://git.code.sf.net/p/opencore-amr/code opencore-amr


uninstall-libopencore-amrnb uninstall-libopencore-amrwb:
	$(MAKE) -i -C modules/opencore-amr uninstall DESTDIR=$(destdir)

clean-libopencore-amrnb clean-libopencore-amrwb:
	$(MAKE) -i -C modules/opencore-amr clean

distclean-libopencore-amrnb distclean-libopencore-amrwb:
	$(MAKE) -i -C modules/opencore-amr distclean || exit 0




###################################################################################################################

libx264: $(destdir)$(prefix)/lib/libx264.a
$(destdir)$(prefix)/lib/libx264.a: configure-libx264
	cd modules/x264 && \
		make V=1 all install DESTDIR=$(destdir)

configure-libx264: modules/x264/config.h
modules/x264/config.h: modules/x264/.git/index
	cd modules/x264 && \
		./configure \
			--prefix=$(prefix) \
	       	--enable-pic \
       		--chroma-format=all \
       		--enable-static \
       		--enable-shared \
       		--enable-pic \
       		--disable-opencl \
       		--disable-cli \
       		--host=$(host)

get-libx264:  modules/x264/.git/index
modules/x264/.git/index:
	mkdir -p modules && cd modules && \
		git clone http://git.videolan.org/git/x264

uninstall-libx264:
	$(MAKE) -i -C modules/x264 uninstall DESTDIR=$(destdir)
	
clean-libx264:
	$(MAKE) -i -C modules/x264 clean

distclean-libx264:
	$(MAKE) -i -C modules/x264 distclean || exit 0




###################################################################################################################

openssl_target = FIXME
ifeq ($(filter arm-linux-androideabi%,$(arch)),)  # arm-linux-androideabi
	openssl_target = android-armv7
endif
ifneq ($(filter aarch64-%,$(arch)),) # aarch64-rpi3-linux-gnueabi
	openssl_target = linux-aarch64
endif


openssl: $(destdir)$(prefix)/include/openssl/conf.h
$(destdir)$(prefix)/include/openssl/conf.h: modules/openssl/test/asn1test.c
	$(MAKE) -C modules/openssl all install_sw DIRS="crypto ssl engines apps tools"
	mkdir -p $(destdir)$(prefix)/include/openssl/engines/ccgost && cp modules/openssl/engines/ccgost/*.h $(destdir)$(prefix)/include/openssl/engines/ccgost




configure-openssl: modules/openssl/test/asn1test.c
modules/openssl/test/asn1test.c: modules/openssl/.git/index
	if [[ "$(arch)" == "native" ]] ; then \
		cd modules/openssl && \
			./config --prefix="$(prefix)" --install_prefix="$(destdir)" || exit 1 ; \
	else \
		cd modules/openssl && \
			./Configure --prefix="$(prefix)" --install_prefix=$(destdir) $(openssl_target) || exit 1 ; \
	fi

		# ./Configure --prefix="$(prefix)" --cross-compile-prefix=$(cross_prefix) --install_prefix=$(destdir) FIXME || exit 1 ; 



get-openssl:  modules/openssl/.git/index 
modules/openssl/.git/index:
	mkdir -p modules && cd modules && \
		git clone -b OpenSSL_1_0_2-stable --single-branch https://github.com/openssl/openssl


uninstall-openssl:
	rm -f $(destdir)$(prefix)/bin/{c_rehash,openssl}
	rm -rf $(destdir)$(prefix)/include/openssl $(destdir)$(prefix)/ssl
	rm -f $(destdir)$(prefix)/lib/libcrypto* $(destdir)$(prefix)/lib/libssl* $(destdir)$(prefix)/lib/pkgconfig/{libcrypto.pc,libssl.pc,openssl.pc}
	rm -f $(destdir)$(prefix)/lib64/libcrypto* $(destdir)$(prefix)/lib64/libssl* $(destdir)$(prefix)/lib64/pkgconfig/{libcrypto.pc,libssl.pc,openssl.pc}
	rm -rf $(destdir)$(prefix)/lib/engines
	rm -rf $(destdir)$(prefix)/lib64/engines


clean-openssl:
	$(MAKE) -i -C modules/openssl clean

distclean-openssl: clean-openssl
	$(MAKE) -i -C modules/openssl dclean




###################################################################################################################
	