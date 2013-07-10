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

P=llvm
V=3.3
TYPE=".tar.gz"
P_V=${P}-${V}.src
SRC_FILE="${P_V}${TYPE}"
B=${P_V}
URL=(
	"http://llvm.org/releases/${VERSION}/llvm-3.3.src.tar.gz"
	"http://llvm.org/releases/${VERSION}/cfe-3.3.src.tar.gz|dir:$NAME/tools"
	"http://llvm.org/releases/${VERSION}/compiler-rt-3.3.src.tar.gz|dir:$NAME/projects"
	"http://llvm.org/releases/${VERSION}/test-suite-3.3.src.tar.gz|dir:$NAME/projects"
)
PRIORITY=main

src_download() {
	func_download URL[@]
}

src_unpack() {
	func_uncompress URL[@]
	
	if ! [ -f ${MARKERS_DIR}/${P_V}-post.marker ]
	then
		mv ${UNPACK_DIR}/${P_V}/tools/cfe-${V}.src ${UNPACK_DIR}/${P_V}/tools/clang
		mv ${UNPACK_DIR}/${P_V}/projects/compiler-rt-${V}.src ${UNPACK_DIR}/${P_V}/projects/compiler-rt
		mv ${UNPACK_DIR}/${P_V}/projects/test-suite-${V}.src ${UNPACK_DIR}/${P_V}/projects/test-suite
		touch ${MARKERS_DIR}/${P_V}-post.marker
	fi
}

src_patch() {
	local _patches=(
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
		--prefix=${PREFIX}
		--with-sysroot=$PREFIX
		--enable-targets=x86,x86_64
		#
		--enable-optimized
		--disable-assertions
		--disable-pthreads
		#--enable-shared
		#--enable-embed-stdcxx
		#--enable-libcpp
		#--enable-cxx11
		#
		--enable-docs
		#
		#--enable-libffi
		#--enable-ltdl-install
		#
		#--with-c-include-dir
		#--with-gcc-toolchain
		#--with-default-sysroot
		#--with-binutils-include
		#--with-bug-report-url
		#
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
		-j1
		DESTDIR=$BASE_BUILD_DIR
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

# **************************************************************************
