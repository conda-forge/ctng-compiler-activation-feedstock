# shellcheck shell=sh

# This function takes no arguments
# It tries to determine the name of this file in a programatic way.
_get_sourced_filename() {
    # shellcheck disable=SC3054,SC2296 # non-POSIX array access and bad '(' are guarded
    if [ -n "${BASH_SOURCE+x}" ] && [ -n "${BASH_SOURCE[0]}" ]; then
        # shellcheck disable=SC3054 # non-POSIX array access is guarded
        basename "${BASH_SOURCE[0]}"
    elif [ -n "${ZSH_NAME+x}" ] && [ -n "${(%):-%x}" ]; then
        # in zsh use prompt-style expansion to introspect the same information
        # see http://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
        # shellcheck disable=SC2296  # bad '(' is guarded
        basename "${(%):-%x}"
    else
        echo "UNKNOWN FILE"
    fi
}

# The format for args are name,value. name is the name of
#  the environment variable. The original value is stored
#  in environment variable CONDA_BACKUP_NAME
_tc_activation() {
  local thing
  local newval
  local from
  local to

  from=""
  to="CONDA_BACKUP_"

  for thing in "$@"; do
    case "${thing}" in
      *,*)
        newval="${thing#*,}"
        thing="${thing%%,*}"
        ;;
      *)
        echo "ERROR: unrecognized argument to activation function"
        return 1
        ;;
    esac
    eval oldval="\$$thing"
    if [ -n "${oldval}" ]; then
      eval export "${to}'${thing}'=\"${oldval}\""
    else
      eval unset '${to}${thing}'
    fi
    eval export "'${from}${thing}=${newval}'"
  done
  return 0
}

if [ "@IS_WIN@" = "1" ]; then
  CONDA_PREFIX=$(echo "${CONDA_PREFIX:-}" | sed 's,\\,\/,g')
fi

# The compiler adds ${PREFIX}/lib to rpath, so it's better to add -L and -isystem  as well.
if [ "${CONDA_BUILD:-0}" = "1" ]; then
  CFLAGS_USED="@CFLAGS@ -isystem ${PREFIX}@LIBRARY_PREFIX@/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
  DEBUG_CFLAGS_USED="@DEBUG_CFLAGS@ -isystem ${PREFIX}@LIBRARY_PREFIX@/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
  # shellcheck disable=SC2050 # templating will fix this error
  if [ "@CMAKE_SYSTEM_NAME@" = "Linux" ]; then
    LDFLAGS_USED="@LDFLAGS@ -Wl,-rpath,${PREFIX}@LIBRARY_PREFIX@/lib -Wl,-rpath-link,${PREFIX}@LIBRARY_PREFIX@/lib -L${PREFIX}@LIBRARY_PREFIX@/lib"
    LDFLAGS_LD_USED="@LDFLAGS_LD@ -rpath ${PREFIX}@LIBRARY_PREFIX@/lib -rpath-link ${PREFIX}@LIBRARY_PREFIX@/lib -L${PREFIX}@LIBRARY_PREFIX@/lib"
  elif [ "@CMAKE_SYSTEM_NAME@" = "Darwin" ]; then
    LDFLAGS_USED="@LDFLAGS@ -Wl,-rpath,${PREFIX}@LIBRARY_PREFIX@/lib -L${PREFIX}@LIBRARY_PREFIX@/lib"
    LDFLAGS_LD_USED="@LDFLAGS_LD@ -rpath ${PREFIX}@LIBRARY_PREFIX@/lib -L${PREFIX}@LIBRARY_PREFIX@/lib"
  else
    LDFLAGS_USED="@LDFLAGS@ -L${PREFIX}@LIBRARY_PREFIX@/lib"
    LDFLAGS_LD_USED="@LDFLAGS_LD@ -L${PREFIX}@LIBRARY_PREFIX@/lib"
  fi
  CPPFLAGS_USED="@CPPFLAGS@ -isystem ${PREFIX}@LIBRARY_PREFIX@/include"
  DEBUG_CPPFLAGS_USED="@DEBUG_CPPFLAGS@ -isystem ${PREFIX}@LIBRARY_PREFIX@/include"
  # shellcheck disable=SC2050 # templating will fix this error
  if [ "@CMAKE_SYSTEM_NAME@" = "Darwin" ]; then
    CMAKE_PREFIX_PATH_USED="${PREFIX}"
  else
    CMAKE_PREFIX_PATH_USED="${PREFIX}:${CONDA_PREFIX}@LIBRARY_PREFIX@/@CHOST@/sysroot/usr"
  fi
else
  CFLAGS_USED="@CFLAGS@ -isystem ${CONDA_PREFIX}@LIBRARY_PREFIX@/include"
  DEBUG_CFLAGS_USED="@DEBUG_CFLAGS@ -isystem ${CONDA_PREFIX}@LIBRARY_PREFIX@/include"
  CPPFLAGS_USED="@CPPFLAGS@ -isystem ${CONDA_PREFIX}@LIBRARY_PREFIX@/include"
  DEBUG_CPPFLAGS_USED="@DEBUG_CPPFLAGS@ -isystem ${CONDA_PREFIX}@LIBRARY_PREFIX@/include"
  if [ "@CMAKE_SYSTEM_NAME@" = "Linux" ]; then
    LDFLAGS_USED="@LDFLAGS@ -Wl,-rpath,${CONDA_PREFIX}@LIBRARY_PREFIX@/lib -Wl,-rpath-link,${CONDA_PREFIX}@LIBRARY_PREFIX@/lib -L${CONDA_PREFIX}@LIBRARY_PREFIX@/lib"
    LDFLAGS_LD_USED="@LDFLAGS_LD@ -rpath ${CONDA_PREFIX}@LIBRARY_PREFIX@/lib -rpath-link ${CONDA_PREFIX}@LIBRARY_PREFIX@/lib -L${CONDA_PREFIX}@LIBRARY_PREFIX@/lib"
  elif [ "@CMAKE_SYSTEM_NAME@" = "Darwin" ]; then
    LDFLAGS_USED="@LDFLAGS@ -Wl,-rpath,${CONDA_PREFIX}@LIBRARY_PREFIX@/lib -L${CONDA_PREFIX}@LIBRARY_PREFIX@/lib"
    LDFLAGS_LD_USED="@LDFLAGS_LD@ -rpath ${CONDA_PREFIX}@LIBRARY_PREFIX@/lib -L${CONDA_PREFIX}@LIBRARY_PREFIX@/lib"
  else
    LDFLAGS_USED="@LDFLAGS@ -L${CONDA_PREFIX}@LIBRARY_PREFIX@/lib"
    LDFLAGS_LD_USED="@LDFLAGS_LD@ -L${CONDA_PREFIX}@LIBRARY_PREFIX@/lib"
  fi
  # shellcheck disable=SC2050 # templating will fix this error
  if [ "@CMAKE_SYSTEM_NAME@" = "Darwin" ]; then
    CMAKE_PREFIX_PATH_USED="${CONDA_PREFIX}"
  else
    CMAKE_PREFIX_PATH_USED="${CONDA_PREFIX}:${CONDA_PREFIX}@LIBRARY_PREFIX@/@CHOST@/sysroot/usr"
  fi
fi

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  if [ -f /tmp/old-env-$$.txt ]; then
    rm -f /tmp/old-env-$$.txt || true
  fi
  env > /tmp/old-env-$$.txt
fi

_CMAKE_ARGS="-DCMAKE_AR=${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/@CHOST@-ar -DCMAKE_CXX_COMPILER_AR=${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/@AR@ -DCMAKE_C_COMPILER_AR=${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/@AR@"
_CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_RANLIB=${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/@CHOST@-ranlib -DCMAKE_CXX_COMPILER_RANLIB=${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/@RANLIB@ -DCMAKE_C_COMPILER_RANLIB=${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/@RANLIB@"
_CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_LINKER=${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/@CHOST@-ld -DCMAKE_STRIP=${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/@CHOST@-strip"
# shellcheck disable=SC2050 # templating will fix this error
if [ "@CMAKE_SYSTEM_NAME@" = "Darwin" ]; then
  _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_INSTALL_NAME_TOOL=${CONDA_PREFIX}/bin/@CHOST@-install_name_tool"
  _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_LIBTOOL=${CONDA_PREFIX}/bin/@CHOST@-libtool"
  if [ "${MACOSX_DEPLOYMENT_TARGET:-0}" != "0" ]; then
    _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
  fi
  if [ "${SDKROOT:-0}" != "0" ]; then
    _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_OSX_SYSROOT=${SDKROOT}"
  fi
fi

_CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release"
_MESON_ARGS="-Dbuildtype=release"

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  # shellcheck disable=SC2050 # templating will fix this error
  if [ "@CMAKE_SYSTEM_NAME@" = "Darwin" ]; then
    _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_FIND_FRAMEWORK=LAST -DCMAKE_FIND_APPBUNDLE=LAST"
  else
    _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY"
    _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_FIND_ROOT_PATH=${PREFIX};${BUILD_PREFIX}@LIBRARY_PREFIX@/@CHOST@/sysroot"
  fi
  _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib"
  _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_PROGRAM_PATH=${BUILD_PREFIX}@LIBRARY_PREFIX@/bin;${PREFIX}/bin"
  _MESON_ARGS="${_MESON_ARGS} --prefix=${PREFIX} -Dlibdir=lib"
fi

# shellcheck disable=SC2050 # templating will fix this error
if [ "@CONDA_BUILD_CROSS_COMPILATION@" = "1" ]; then
  _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_SYSTEM_NAME=@CMAKE_SYSTEM_NAME@ -DCMAKE_SYSTEM_PROCESSOR=@MACHINE@"
  # shellcheck disable=SC2050 # templating will fix this error
  if [ "@CMAKE_SYSTEM_NAME@" = "Darwin" ]; then
    _CMAKE_ARGS="${_CMAKE_ARGS} -DCMAKE_SYSTEM_VERSION=@UNAME_KERNEL_RELEASE@"
  fi
  _MESON_ARGS="${_MESON_ARGS} --cross-file ${CONDA_PREFIX}@LIBRARY_PREFIX@/meson_cross_file.txt"
  echo "[host_machine]" > "${CONDA_PREFIX}@LIBRARY_PREFIX@/meson_cross_file.txt"
  echo "system = '@MESON_SYSTEM@'" >> "${CONDA_PREFIX}@LIBRARY_PREFIX@/meson_cross_file.txt"
  echo "cpu = '@MACHINE@'" >> "${CONDA_PREFIX}@LIBRARY_PREFIX@/meson_cross_file.txt"
  echo "cpu_family = '@MESON_FAMILY@'" >> "${CONDA_PREFIX}@LIBRARY_PREFIX@/meson_cross_file.txt"
  echo "endian = 'little'" >> "${CONDA_PREFIX}@LIBRARY_PREFIX@/meson_cross_file.txt"
  if [ "@MESON_SYSTEM@" = "darwin" ]; then
    # meson guesses whether it can run binaries in cross-compilation based on some heuristics,
    # and those can be wrong; see https://mesonbuild.com/Cross-compilation.html#properties
    echo "[properties]" >> "${CONDA_PREFIX}@LIBRARY_PREFIX@/meson_cross_file.txt"
    echo "needs_exe_wrapper = true" >> "${CONDA_PREFIX}@LIBRARY_PREFIX@/meson_cross_file.txt"
  fi
  # specify path to correct binaries from build (not host) environment,
  # which meson will not auto-discover (out of caution) if not told explicitly.
  # keep binaries as the last section as some recipes edit this file and is expected.
  echo "[binaries]" >> "${CONDA_PREFIX}@LIBRARY_PREFIX@/meson_cross_file.txt"
  echo "cmake = '${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/cmake'" >> "${CONDA_PREFIX}@LIBRARY_PREFIX@/meson_cross_file.txt"
  echo "pkg-config = '${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/pkg-config'" >> "${CONDA_PREFIX}@LIBRARY_PREFIX@/meson_cross_file.txt"
fi

_tc_activation \
  "HOST,@CHOST@" \
  "BUILD,@CBUILD@" \
  "CONDA_TOOLCHAIN_HOST,@CHOST@" \
  "CONDA_TOOLCHAIN_BUILD,@CBUILD@" \
  @C_EXTRA@ \
  "CPPFLAGS,${CPPFLAGS_USED}${CPPFLAGS:+ }${CPPFLAGS:-}" \
  "CFLAGS,${CFLAGS_USED}${CFLAGS:+ }${CFLAGS:-}" \
  "LDFLAGS,${LDFLAGS_USED}${LDFLAGS:+ }${LDFLAGS:-}" \
  "LDFLAGS_LD,${LDFLAGS_LD_USED}${LDFLAGS_LD:+ }${LDFLAGS_LD:-}" \
  "DEBUG_CPPFLAGS,${DEBUG_CPPFLAGS_USED}${DEBUG_CPPFLAGS:+ }${DEBUG_CPPFLAGS:-}" \
  "DEBUG_CFLAGS,${DEBUG_CFLAGS_USED}${DEBUG_CFLAGS:+ }${DEBUG_CFLAGS:-}" \
  "CMAKE_PREFIX_PATH,${CMAKE_PREFIX_PATH_USED}${CMAKE_PREFIX_PATH:+:}${CMAKE_PREFIX_PATH:-}" \
  "CONDA_BUILD_CROSS_COMPILATION,@CONDA_BUILD_CROSS_COMPILATION@" \
  "build_alias,@CBUILD@" \
  "host_alias,@CHOST@" \
  "MESON_ARGS,${_MESON_ARGS}" \
  "CMAKE_ARGS,${_CMAKE_ARGS}"

unset _CMAKE_ARGS
unset _MESON_ARGS

# shellcheck disable=SC2050 # templating will fix this error
if [ "@CONDA_BUILD_CROSS_COMPILATION@" = "1" ] && [ "@CMAKE_SYSTEM_NAME@" = "Linux" ]; then
  _tc_activation \
     "QEMU_LD_PREFIX,${QEMU_LD_PREFIX:-${CONDA_BUILD_SYSROOT}}"
fi

# shellcheck disable=SC2050 # templating will fix this error
if [ "@CMAKE_SYSTEM_NAME@" != "Darwin" ]; then
  _tc_activation \
    "CONDA_BUILD_SYSROOT,${CONDA_PREFIX}@LIBRARY_PREFIX@/@CHOST@/sysroot"
fi

if [ $? -ne 0 ]; then
  echo "ERROR: $(_get_sourced_filename) failed, see above for details"
else
  if [ "${CONDA_BUILD:-0}" = "1" ]; then
    if [ -f /tmp/new-env-$$.txt ]; then
      rm -f /tmp/new-env-$$.txt || true
    fi
    env > /tmp/new-env-$$.txt

    echo "INFO: $(_get_sourced_filename) made the following environmental changes:"
    diff -U 0 -rN /tmp/old-env-$$.txt /tmp/new-env-$$.txt | tail -n +4 | grep "^-.*\|^+.*" | grep -v "CONDA_BACKUP_" | sort
    rm -f /tmp/old-env-$$.txt /tmp/new-env-$$.txt || true
  fi

  # fix prompt for zsh
  if [ -n "${ZSH_NAME:-}" ]; then
    autoload -Uz add-zsh-hook

    _conda_clang_precmd() {
      # shellcheck disable=SC2034 # guarded for zsh
      HOST="${CONDA_BACKUP_HOST}"
    }
    add-zsh-hook -Uz precmd _conda_clang_precmd

    _conda_clang_preexec() {
      # shellcheck disable=SC2034 # guarded for zsh
      HOST="${CONDA_TOOLCHAIN_HOST}"
    }
    add-zsh-hook -Uz preexec _conda_clang_preexec
  fi
fi

if [ "@IS_WIN@" = "1" ]; then
  CONDA_PREFIX=$(echo "${CONDA_PREFIX:-}" | sed 's,\/,\\,g')
fi
