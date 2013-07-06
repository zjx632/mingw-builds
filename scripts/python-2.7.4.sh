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

P=Python
V=2.7.4
TYPE=".tar.bz2"
P_V=${P}-${V}
SRC_FILE="${P_V}${TYPE}"
B=${P_V}
URL=http://www.python.org/ftp/python/${V}/${SRC_FILE}
PRIORITY=extra

src_download() {
	func_download ${P_V} ${TYPE} ${URL}
}

src_unpack() {
	func_uncompress ${P_V} ${TYPE}
}

src_patch() {
	local _patches=(
		${P}/${V}/0005-MINGW.patch
		${P}/${V}/0006-mingw-removal-of-libffi-patch.patch
		${P}/${V}/0007-mingw-system-libffi.patch
		${P}/${V}/0010-mingw-osdefs-DELIM.patch	
		${P}/${V}/0015-mingw-use-posix-getpath.patch
		${P}/${V}/0020-mingw-w64-test-for-REPARSE_DATA_BUFFER.patch
		${P}/${V}/0025-mingw-regen-with-stddef-instead.patch
		${P}/${V}/0030-mingw-add-libraries-for-_msi.patch
		${P}/${V}/0035-MSYS-add-MSYSVPATH-AC_ARG.patch
		${P}/${V}/0040-mingw-cygwinccompiler-use-CC-envvars-and-ld-from-print-prog-name.patch
		${P}/${V}/0045-cross-darwin.patch
		${P}/${V}/0050-mingw-sysconfig-like-posix.patch
		${P}/${V}/0055-mingw-pdcurses_ISPAD.patch
		${P}/${V}/0060-mingw-static-tcltk.patch
		${P}/${V}/0065-mingw-x86_64-size_t-format-specifier-pid_t.patch
		${P}/${V}/0070-python-disable-dbm.patch
		${P}/${V}/0075-add-python-config-sh.patch
		${P}/${V}/0080-mingw-nt-threads-vs-pthreads.patch
		${P}/${V}/0085-cross-dont-add-multiarch-paths-if.patch
		${P}/${V}/0090-mingw-reorder-bininstall-ln-symlink-creation.patch
		${P}/${V}/0095-mingw-use-backslashes-in-compileall-py.patch
		${P}/${V}/0100-mingw-distutils-MSYS-convert_path-fix-and-root-hack.patch
		${P}/${V}/0105-mingw-MSYS-no-usr-lib-or-usr-include.patch
		${P}/${V}/0110-mingw-_PyNode_SizeOf-decl-fix.patch
		${P}/${V}/0115-mingw-cross-includes-lower-case.patch
		${P}/${V}/0500-mingw-install-LDLIBRARY-to-LIBPL-dir.patch
		${P}/${V}/0505-add-build-sysroot-config-option.patch
		${P}/${V}/0510-cross-PYTHON_FOR_BUILD-gteq-274-and-fullpath-it.patch
		${P}/${V}/0515-mingw-add-GetModuleFileName-path-to-PATH.patch
		${P}/${V}/9999-re-configure-d.patch
	)
	
	func_apply_patches \
		${P_V} \
		_patches[@]

	local _commands=(
		"rm -rf Modules/expat"
		"rm -rf Modules/_ctypes/libffi*"
		"rm -rf Modules/zlib"
		"autoconf"
		"autoheader"
		"rm -rf autom4te.cache"
		"touch Include/graminit.h"
		"touch Python/graminit.c"
		"touch Parser/Python.asdl"
		"touch Parser/asdl.py"
		"touch Parser/asdl_c.py"
		"touch Include/Python-ast.h"
		"touch Python/Python-ast.c"
		"echo \"\" > Parser/pgen.stamp"
	)
	local _allcommands="${_commands[@]}"
	func_execute ${UNPACK_DIR}/${P_V} "Python-preconfigure" "$_allcommands"
}

src_configure() {
	[[ -d $LIBS_DIR ]] && {
		pushd $LIBS_DIR > /dev/null
		local LIBSW_DIR=`pwd -W`
		popd > /dev/null
	}

	[[ -d $PREFIX ]] && {
		pushd $PREFIX > /dev/null
		local PREFIXW=`pwd -W`
		popd > /dev/null
	}

	[[ -d $PREREQ_DIR ]] && {
		pushd $PREREQ_DIR > /dev/null
		local PREREQW_DIR=`pwd -W`
		popd > /dev/null
	}

	local LIBFFI_VERSION=$( grep -m 1 'V=' $PORTS_DIR/libffi.sh | sed 's|V=||' )
	local MY_CPPFLAGS="-I$LIBSW_DIR/include -I$LIBSW_DIR/include/ncurses -I$PREREQW_DIR/$ARCHITECTURE-zlib/include -I$PREFIXW/opt/include"

	# Workaround for conftest error on 64-bit builds
	export ac_cv_working_tzset=no
	#

	local _conf_flags=(
		--host=$HOST
		--build=$BUILD
		#
		--prefix=$([[ $PYTHON_ONLY_MODE == no ]] && echo $PREFIX/opt || echo $PREFIX)
		#
		--enable-shared
		--disable-ipv6
		--without-pydebug
		--with-system-expat
		--with-system-ffi
		#
		CXX="$HOST-g++"
		LIBFFI_INCLUDEDIR="$LIBSW_DIR/lib/libffi-$LIBFFI_VERSION/include"
		OPT=""
		CFLAGS="\"$COMMON_CFLAGS -fwrapv -DNDEBUG -D__USE_MINGW_ANSI_STDIO=1\""
		CXXFLAGS="\"$COMMON_CXXFLAGS -fwrapv -DNDEBUG -D__USE_MINGW_ANSI_STDIO=1 $MY_CPPFLAGS\""
		CPPFLAGS="\"$COMMON_CPPFLAGS $MY_CPPFLAGS\""
		LDFLAGS="\"$COMMON_LDFLAGS -L$PREREQW_DIR/$ARCHITECTURE-zlib/lib -L$PREFIXW/opt/lib -L$LIBSW_DIR/lib\""
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

# **************************************************************************
