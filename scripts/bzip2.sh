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

P=bzip2
V=1.0.6
TYPE=".tar.gz"
P_V=${P}-${V}
SRC_FILE="${P_V}${TYPE}"
B=${P_V}
URL=http://www.bzip.org/${V}/${SRC_FILE}
PRIORITY=extra

src_download() {
	func_download ${P_V} ${TYPE} ${URL}
}

src_unpack() {
	func_uncompress ${P_V} ${TYPE}
}

src_patch() {
	local _patches=(
		${P}/bzip2-1.0.4-bzip2recover.patch
		${P}/bzip2-1.0.6-autoconfiscated.patch
		${P}/bzip2-use-cdecl-calling-convention.patch
		${P}/bzip2-1.0.5-slash.patch
	)
	
	func_apply_patches \
		${P_V} \
		_patches[@]
	
	local _commands=(
		"./autogen.sh"
	)
	local _allcommands="${_commands[@]}"
	func_execute ${UNPACK_DIR}/${P_V} "Autogen" "$_allcommands"
}

src_configure() {
	local _conf_flags=(
		--host=${HOST}
		--build=${BUILD}
		--target=${TARGET}
		#
		--prefix=${PREFIX}
		#
		${GCC_DEPS_LINK_TYPE}
		#
		CFLAGS="\"${COMMON_CFLAGS}\""
		CXXFLAGS="\"${COMMON_CXXFLAGS}\""
		CPPFLAGS="\"${COMMON_CPPFLAGS}\""
		LDFLAGS="\"${COMMON_LDFLAGS}\""
	)
	local _allconf="${_conf_flags[@]}"
	func_configure ${B} ${P_V} "$_allconf"
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
}
#

PATCHES=(
	bzip2/bzip2-1.0.4-bzip2recover.patch
	bzip2/bzip2-1.0.6-autoconfiscated.patch
	bzip2/bzip2-use-cdecl-calling-convention.patch
	bzip2/bzip2-1.0.5-slash.patch
)

#

EXECUTE_AFTER_PATCH=(
	"autogen.sh"
)

#

CONFIGURE_FLAGS=(
	--host=$HOST
	--build=$BUILD
	--target=$TARGET
	#
	--prefix=$LIBS_DIR
	#
	$LINK_TYPE_SHARED
	#
	CFLAGS="\"$COMMON_CFLAGS\""
	CXXFLAGS="\"$COMMON_CXXFLAGS\""
	CPPFLAGS="\"$COMMON_CPPFLAGS\""
	LDFLAGS="\"$COMMON_LDFLAGS\""
)

#

MAKE_FLAGS=(
	-j$JOBS
	all
)

#

INSTALL_FLAGS=(
	-j$JOBS
	install
)

# **************************************************************************
