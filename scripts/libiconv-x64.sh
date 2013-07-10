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

P=libiconv
V=1.14
TYPE=".tar.gz"
P_V=${P}-${V}
SRC_FILE="${P_V}${TYPE}"
B=${P_V}-x64-$LINK_TYPE_SUFFIX
URL=(
	"http://ftp.gnu.org/pub/gnu/${P}/${SRC_FILE}"
)
PRIORITY=prereq

change_paths() {
	[[ $ARCHITECTURE == x32 ]] && {
		BEFORE_LIBICONV64_PRE_PATH=$PATH
		export PATH=$x64_HOST_MINGW_PATH/bin:$ORIGINAL_PATH
	
		[[ $USE_MULTILIB == yes ]] && {
			OLD_HOST=$HOST
			OLD_BUILD=$BUILD
			OLD_TARGET=$TARGET
			HOST=$TVIN_HOST
			BUILD=$TVIN_BUILD
			TARGET=$TVIN_TARGET
		}
	}
}

restore_paths() {
	[[ $ARCHITECTURE == x32 ]] && {
		export PATH=$BEFORE_LIBICONV64_PRE_PATH
	
		[[ $USE_MULTILIB == yes ]] && {
			HOST=$OLD_HOST
			BUILD=$OLD_BUILD
			TARGET=$OLD_TARGET
		}
		unset BEFORE_LIBICONV64_PRE_PATH
		unset OLD_HOST
		unset OLD_BUILD
		unset OLD_TARGET
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
	)
	
	func_apply_patches \
		${P_V} \
		_patches[@]
}

src_configure() {
	change_paths

	local _conf_flags=(
		--host=$HOST
		--build=$BUILD
		--target=$TARGET
		#
		--prefix=$PREREQ_DIR/${P}-x64-$LINK_TYPE_SUFFIX
		#
		$GCC_DEPS_LINK_TYPE
		#
		CFLAGS="\"$COMMON_CFLAGS\""
		CXXFLAGS="\"$COMMON_CXXFLAGS\""
		CPPFLAGS="\"$COMMON_CPPFLAGS\""
		LDFLAGS="\"$COMMON_LDFLAGS\""
	)
	local _allconf="${_conf_flags[@]}"
	func_configure ${B} ${P_V} "$_allconf"

	restore_paths
}

pkg_build() {
	change_paths

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

	restore_paths
}

pkg_install() {
	change_paths

	local _install_flags=(
		-j${JOBS}
		$( [[ $STRIP_ON_INSTALL == yes ]] && echo install-strip || echo install )
	)
	local _allinstall="${_install_flags[@]}"
	func_make \
		${B} \
		"/bin/make" \
		"$_allinstall" \
		"installing..." \
		"installed"

	restore_paths
}

# **************************************************************************
