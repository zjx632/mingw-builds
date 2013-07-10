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

P=mingw-libgnurx
V=2.5.1
TYPE=".tar.gz"
P_V=${P}-${V}
SRC_FILE="${P_V}-src${TYPE}"
B=${P}-${V}
URL=https://sourceforge.net/projects/mingw/files/Other/UserContributed/regex/mingw-regex-${V}/${SRC_FILE}
PRIORITY=extra

src_download() {
	func_download ${P_V} ${TYPE} ${URL}
}

src_unpack() {
	func_uncompress ${P_V}-src ${TYPE}
}

src_patch() {
	local _patches=(
		libgnurx/mingw32-libgnurx-honor-destdir.patch
	)
	
	func_apply_patches \
		${P_V} \
		_patches[@]

	local _commands=(
		"cp -rf $PATCHES_DIR/libgnurx/mingw32-libgnurx-configure.ac $SRCS_DIR/${P}-${V}/configure.ac"
		"cp -rf $PATCHES_DIR/libgnurx/mingw32-libgnurx-Makefile.am $SRCS_DIR/${P}-${V}/Makefile.am"
		"touch AUTHORS"
		"touch NEWS"
		"libtoolize --copy"
		"aclocal"
		"autoconf"
		"automake --add-missing"
	)
	local _allcommands="${_commands[@]}"
	func_execute ${SRCS_DIR}/${P}-${V} "Autoreconf" "$_allcommands"
}

src_configure() {
	local _conf_flags=(
		--host=$HOST
		--build=$BUILD
		--target=$TARGET
		#
		--prefix=$LIBS_DIR
		#
		$LINK_TYPE_STATIC
		#
		CFLAGS="\"$COMMON_CFLAGS\""
		CXXFLAGS="\"$COMMON_CXXFLAGS\""
		CPPFLAGS="\"$COMMON_CPPFLAGS\""
		LDFLAGS="\"$COMMON_LDFLAGS\""
	)
	local _allconf="${_conf_flags[@]}"
	func_configure ${B} ${P}-${V} "$_allconf"
}

pkg_build() {
	local _make_flags=(
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
}

pkg_install() {
	local _install_flags=(
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

	if [ ! -f $CURR_BUILD_DIR/${P}-${V}/libregex.marker ]
	then
		cp -f $LIBS_DIR/lib/libgnurx.a $LIBS_DIR/lib/libregex.a || die "Cannot copy $LIBS_DIR/lib/libgnurx.a to $LIBS_DIR/lib/libregex.a"
		touch $CURR_BUILD_DIR/${P}-${V}/libregex.marker
	fi
}

# **************************************************************************
