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

P=make
V=
TYPE="cvs"
P_V=${P}
SRC_FILE=
B=${P_V}
URL=":pserver:anonymous:@cvs.sv.gnu.org:/sources/make"
PRIORITY=extra
REV=09/21/2012

src_download() {
	func_download ${P_V} ${TYPE} ${URL} ${REV}
}

src_unpack() {
	echo "--> Don't need to unpack"
}

src_patch() {
	local _patches=(
		${P}/make-remove-double-quote.patch
		${P}/make-linebuf-mingw.patch
		${P}/make-getopt.patch
		${P}/make-Windows-Add-move-to-sh_cmds_dos.patch
	)
	
	func_apply_patches \
		${P_V} \
		_patches[@]

	local _commands=(
		"autoreconf -fi"
	)
	local _allcommands="${_commands[@]}"
	func_execute ${UNPACK_DIR}/${P_V} "Autoreconf" "$_allcommands"
}

src_configure() {
	local _conf_flags=(
		--host=$HOST
		--build=$TARGET
		--prefix=$PREFIX
		--enable-case-insensitive-file-system
		--program-prefix=mingw32-
		--enable-job-server
		--without-guile
		CFLAGS="\"$COMMON_CFLAGS\""
		LDFLAGS="\"$COMMON_LDFLAGS -L$LIBS_DIR/lib\""
	)
	local _allconf="${_conf_flags[@]}"
	func_configure ${B} ${P_V} "$_allconf"
}

pkg_build() {

	local _make_flags=(
		do-po-update
	)
	local _allmake="${_make_flags[@]}"
	func_make \
		${B} \
		"/bin/make" \
		"$_allmake" \
		"update po files..." \
		"po-updated"
		
	_make_flags=(
		scm-update
	)
	_allmake="${_make_flags[@]}"
	func_make \
		${B} \
		"/bin/make" \
		"$_allmake" \
		"update doc files..." \
		"scm-updated"
		
	_make_flags=(
		-j${JOBS}
		all
	)
	_allmake="${_make_flags[@]}"
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
