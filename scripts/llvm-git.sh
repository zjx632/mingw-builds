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
V=git
TYPE="git"
P_V=${P}-${V}
SRC_FILE=
B=${P_V}
URL=(
	"http://llvm.org/git/llvm.git|repo:$TYPE|module:${P_V}"
	"http://llvm.org/git/clang.git|repo:$TYPE|dir:${P_V}/tools|module:clang"
	"http://llvm.org/git/compiler-rt.git|repo:$TYPE|dir:${P_V}/projects|module:compiler-rt"
	"http://llvm.org/git/test-suite.git|repo:$TYPE|dir:${P_V}/projects|module:test-suite"
)
PRIORITY=main

src_download() {
	func_download URL[@]
}

src_unpack() {
	echo "--> Doesn't need to unpack."
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
		--prefix=$PREFIX
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
