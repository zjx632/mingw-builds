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

P=zlib
V=1.2.8
TYPE=".tar.gz"
ZLIB_ARCH=x64
P_V=${P}-${V}
SRC_FILE="${P_V}${TYPE}"
B=${ZLIB_ARCH}-${P_V}
URL=(
	"http://sourceforge.net/projects/libpng/files/${P}/${V}/${SRC_FILE}"
)
PRIORITY=prereq

change_paths() {
	[[ $ARCHITECTURE == x32 ]] && {
		BEFORE_ZLIB64_PRE_PATH=$PATH
		export PATH=$x64_HOST_MINGW_PATH/bin:$ORIGINAL_PATH
	}
}

restore_paths() {
	[[ $ARCHITECTURE == x32 ]] && {
		export PATH=$BEFORE_ZLIB64_PRE_PATH
		unset BEFORE_ZLIB64_PRE_PATH
	}
}

src_download() {
	func_download URL[@]
}

src_unpack() {
	func_uncompress URL[@]
}

src_patch() {
	local _patches=(
		${P}/zlib-1.2.5-nostrip.patch
		${P}/zlib-1.2.5-tml.patch
	)
	
	func_apply_patches \
		${P_V} \
		_patches[@]

	if ! [ -f $PREREQ_BUILD_DIR/${B}/copy.marker ]
	then
		cp -rf $UNPACK_DIR/${P_V}/* $PREREQ_BUILD_DIR/${B}/ || die "Cannot copy $UNPACK_DIR/${P_V}/* to $PREREQ_BUILD_DIR/${B}/"
		touch $PREREQ_BUILD_DIR/${B}/copy.marker
	fi
}

src_configure() {
	echo "--> Don't need to configure"
}

pkg_build() {
	change_paths
	local _make_flags=(
		-f win32/Makefile.gcc
		CC=x86_64-w64-mingw32-gcc
		AR=ar
		RC=windres
		DLLWRAP=dllwrap
		-j${JOBS}
		all
	)
	local _allmake="${_make_flags[@]}"
	func_make \
		${B} \
		"/bin/make" \
		"$_allmake" \
		"building..." \
		"built"
	restore_paths
}

pkg_install() {
	local _install_flags=(
		-f win32/Makefile.gcc
		INCLUDE_PATH=$PREREQ_DIR/$ZLIB_ARCH-${P}/include
		LIBRARY_PATH=$PREREQ_DIR/$ZLIB_ARCH-${P}/lib
		BINARY_PATH=$PREREQ_DIR/$ZLIB_ARCH-${P}/bin
		-j${JOBS}
		install
	)
	local _allinstall="${_install_flags[@]}"
	func_make \
		${B} \
		"/bin/make" \
		"$_allinstall" \
		"installing..." \
		"installed"

	[[ ! -f $BUILDS_DIR/${ZLIB_ARCH}-${P_V}-post.marker ]] && {
		mkdir -p $PREFIX/bin $PREFIX/mingw
		[[ ($USE_MULTILIB == yes) && ($ARCHITECTURE == x32) ]] && {
			mkdir -p $PREFIX/$TARGET/lib64

			cp -f $PREREQ_DIR/$ZLIB_ARCH-${P}/lib/*.a $PREFIX/$TARGET/lib64/ || exit 1
		} || {
			mkdir -p $PREFIX/$TARGET/{lib,include}

			cp -f $PREREQ_DIR/$ZLIB_ARCH-${P}/lib/*.a $PREFIX/$TARGET/lib/ || exit 1
			cp -f $PREREQ_DIR/$ZLIB_ARCH-${P}/include/*.h $PREFIX/$TARGET/include/ || exit 1
		}
		cp -rf $PREFIX/$TARGET/* $PREFIX/mingw/ || exit 1
		touch $BUILDS_DIR/$ZLIB_ARCH-${P_V}-post.marker
	}
}

# **************************************************************************
