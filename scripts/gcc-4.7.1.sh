#!/bin/bash

#
# The BSD 3-Clause License. http://www.opensource.org/licenses/BSD-3-Clause
#
# This file is part of 'mingw-builds' project.
# Copyright (c) 2011,2012,2013 by niXman (i dotty nixman doggy gmail dotty com)
# All rights reserved.
#
# Project: mingw-builds ( http://sourceforge.net/projects/mingwbuilds/ )
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# - Redistributions of source code must retain the above copyright 
#     notice, this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright 
#     notice, this list of conditions and the following disclaimer in 
#     the documentation and/or other materials provided with the distribution.
# - Neither the name of the 'mingw-builds' nor the names of its contributors may 
#     be used to endorse or promote products derived from this software 
#     without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
# A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY 
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS 
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
# USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# **************************************************************************

P=gcc
V=4.7.1
TYPE=".tar.bz2"
P_V=${P}-${V}
SRC_FILE="${P_V}${TYPE}"
B=${P_V}
URL=ftp://ftp.gnu.org/gnu/${P}/${P_V}/${SRC_FILE}
PRIORITY=main

src_download() {
	func_download ${P_V} ${TYPE} ${URL}
}

src_unpack() {
	func_uncompress ${P_V} ${TYPE}
}

src_patch() {
	local _patches=(
		${P}/gcc-4.7-stdthreads.patch
		${P}/gcc-4.7-iconv.patch
		${P}/gcc-4.7-vswprintf.patch
	)
	
	func_apply_patches \
		${P_V} \
		_patches[@]
}

src_configure() {
	local _conf_flags=(
		--host=$HOST
		--build=$BUILD
		--target=$TARGET
		#
		--prefix=$MINGWPREFIX
		--with-sysroot=$PREFIX
		#
		$LINK_TYPE_BOTH
		#
		$( [[ $USE_MULTILIB == yes ]] \
			&& echo "--enable-targets=all --enable-multilib" \
			|| echo "--disable-multilib" \
		)
		--enable-languages=$ENABLE_LANGUAGES,lto
		--enable-libstdcxx-time=yes
		--enable-threads=$THREADS_MODEL
		--enable-libgomp
		--enable-lto
		--enable-graphite
		--enable-cloog-backend=isl
		--enable-checking=release
		--enable-fully-dynamic-string
		--enable-version-specific-runtime-libs
		$( [[ $EXCEPTIONS_MODEL == dwarf ]] \
			&& echo "--disable-sjlj-exceptions --with-dwarf2" \
		)
		$( [[ $EXCEPTIONS_MODEL == sjlj ]] \
			&& echo "--enable-sjlj-exceptions" \
		)
		#
		--disable-ppl-version-check
		--disable-cloog-version-check
		--disable-libstdcxx-pch
		--disable-libstdcxx-debug
		$( [[ $BOOTSTRAPING == yes ]] \
			&& echo "--enable-bootstrap" \
			|| echo "--disable-bootstrap" \
		)
		--disable-rpath
		--disable-win32-registry
		--disable-nls
		--disable-werror
		--disable-symvers
		#
		--with-gnu-as
		--with-gnu-ld
		#
		$PROCESSOR_OPTIMIZATION
		$PROCESSOR_TUNE
		#
		$( [[ $GCC_DEPS_LINK_TYPE == *--disable-shared* ]] \
			&& echo "--with-host-libstdcxx='-static -lstdc++'" \
		)
		--with-libiconv
		--with-system-zlib
		--with-{gmp,mpfr,mpc,ppl,cloog}=$PREREQ_DIR/$HOST-$LINK_TYPE_SUFFIX
		--with-pkgversion="\"$PKG_VERSION\""
		--with-bugurl=$BUG_URL
		#
		CFLAGS="\"$COMMON_CFLAGS\""
		CXXFLAGS="\"$COMMON_CXXFLAGS\""
		CPPFLAGS="\"$COMMON_CPPFLAGS\""
		LDFLAGS="\"$COMMON_LDFLAGS\""
	)
	local _allconf="${_conf_flags[@]}"
	func_configure ${B} ${P_V} "$_allconf"
}

pkg_build() {
	local _make_flags=(
		-j1
		all
	)
	local _allmake="${_make_flags[@]}"
	func_make \
		${B} \
		"/bin/make" \
		"$_allmake" \
		"building..." \
		"built"
}

pkg_install() {
	local _install_flags=(
		-j${JOBS}
		DESTDIR=$BASE_BUILD_DIR
		$( [[ $STRIP_ON_INSTALL == yes ]] && echo install-strip || echo install )
	)
	local _allinstall="${_install_flags[@]}"
	func_make \
		${B} \
		"/bin/make" \
		"$_allinstall" \
		"installing..." \
		"installed"
}

# **************************************************************************
