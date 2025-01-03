# shellcheck shell=sh

# This function takes no arguments
# It tries to determine the name of this file in a programatic way.
_get_sourced_filename() {
    # shellcheck disable=SC3054,SC2296 # non-POSIX array access and bad '(' are guarded
    if [ -n "${BASH_SOURCE+x}" ] && [ -n "${BASH_SOURCE[0]}" ]; then
        # shellcheck disable=SC3054 # non-POSIX array access is guarded
        basename "${BASH_SOURCE[0]}"
    elif [ -n "$ZSH_NAME" ] && [ -n "${(%):-%x}" ]; then
        # in zsh use prompt-style expansion to introspect the same information
        # see http://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
        # shellcheck disable=SC2296  # bad '(' is guarded
        basename "${(%):-%x}"
    else
        echo "UNKNOWN FILE"
    fi
}

# The arguments to this are:
# 1. activation nature {activate|deactivate}
# 2. toolchain nature {build|host|ccc}
# 3. machine (should match -dumpmachine)
# 4. prefix (including any final -)
# 5+ program (or environment var comma value)
# The format for 5+ is name{,,value}. If value is specified
#  then name taken to be an environment variable, otherwise
#  it is taken to be a program. In this case, which is used
#  to find the full filename during activation. The original
#  value is stored in environment variable CONDA_BACKUP_NAME
#  For deactivation, the distinction is irrelevant as in all
#  cases NAME simply gets reset to CONDA_BACKUP_NAME.  It is
#  a fatal error if a program is identified but not present.
_tc_activation() {
  local act_nature="$1"; shift
  local tc_prefix="$1"; shift
  local thing
  local newval
  local from
  local to
  local pass

  if [ "${act_nature}" = "activate" ]; then
    from=""
    to="CONDA_BACKUP_"
  else
    from="CONDA_BACKUP_"
    to=""
  fi

  for pass in check apply; do
    for thing in "$@"; do
      case "${thing}" in
        *,*)
          newval="${thing#*,}"
          thing="${thing%%,*}"
          ;;
        *)
          newval="${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/${tc_prefix}${thing}"
          thing=$(echo "${thing}" | tr 'a-z+-' 'A-ZX_')
          if [ ! -x "${newval}" ] && [ "${pass}" = "check" ]; then
            echo "ERROR: This cross-compiler package contains no program ${newval}"
            return 1
          fi
          ;;
      esac
      if [ "${pass}" = "apply" ]; then
        eval oldval="\$${from}$thing"
        if [ -n "${oldval}" ]; then
          eval export "${to}'${thing}'=\"${oldval}\""
        else
          eval unset '${to}${thing}'
        fi
        if [ -n "${newval}" ]; then
          eval export "'${from}${thing}=${newval}'"
        else
          eval unset '${from}${thing}'
        fi
      fi
    done
  done
  return 0
}

if [ "@IS_WIN@" = "1" ]; then
  CONDA_PREFIX=$(echo "${CONDA_PREFIX:-}" | sed 's,\\,\/,g')
fi

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  CFLAGS_USED="@CFLAGS@ -isystem ${PREFIX}@LIBRARY_PREFIX@/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
  DEBUG_CFLAGS_USED="@DEBUG_CFLAGS@ -isystem ${PREFIX}@LIBRARY_PREFIX@/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
  LDFLAGS_USED="@LDFLAGS@ -Wl,-rpath,${PREFIX}@LIBRARY_PREFIX@/lib -L${PREFIX}@LIBRARY_PREFIX@/lib"
  CPPFLAGS_USED="@CPPFLAGS@ -isystem ${PREFIX}@LIBRARY_PREFIX@/include"
  DEBUG_CPPFLAGS_USED="@DEBUG_CPPFLAGS@ -isystem ${PREFIX}@LIBRARY_PREFIX@/include"
  CMAKE_PREFIX_PATH_USED="${PREFIX}:${CONDA_PREFIX}@LIBRARY_PREFIX@/@CHOST@/sysroot/usr"
else
  CFLAGS_USED="@CFLAGS@ -isystem ${CONDA_PREFIX}@LIBRARY_PREFIX@/include"
  DEBUG_CFLAGS_USED="@DEBUG_CFLAGS@ -isystem ${CONDA_PREFIX}@LIBRARY_PREFIX@/include"
  CPPFLAGS_USED="@CPPFLAGS@ -isystem ${CONDA_PREFIX}@LIBRARY_PREFIX@/include"
  DEBUG_CPPFLAGS_USED="@DEBUG_CPPFLAGS@ -isystem ${CONDA_PREFIX}@LIBRARY_PREFIX@/include"
  LDFLAGS_USED="@LDFLAGS@ -Wl,-rpath,${CONDA_PREFIX}@LIBRARY_PREFIX@/lib -Wl,-rpath-link,${CONDA_PREFIX}@LIBRARY_PREFIX@/lib -L${CONDA_PREFIX}@LIBRARY_PREFIX@/lib"
  CMAKE_PREFIX_PATH_USED="${CONDA_PREFIX}:${CONDA_PREFIX}@LIBRARY_PREFIX@/@CHOST@/sysroot/usr"
fi

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  if [ -f /tmp/old-env-$$.txt ]; then
    rm -f /tmp/old-env-$$.txt || true
  fi
  env > /tmp/old-env-$$.txt
fi

# shellcheck disable=SC2050 # templating will fix this error
if [ "@CONDA_BUILD_CROSS_COMPILATION@" = "1" ]; then
_tc_activation \
  deactivate @CHOST@- \
  "QEMU_LD_PREFIX,${QEMU_LD_PREFIX:-${CONDA_BUILD_SYSROOT}}"
fi

_tc_activation \
  deactivate @CHOST@- "HOST,@CHOST@" "BUILD,@CBUILD@" \
  "CONDA_TOOLCHAIN_HOST,@CHOST@" \
  "CONDA_TOOLCHAIN_BUILD,@CBUILD@" \
  "CC,${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/@CC@" @COMPILERS@ \
  "CPPFLAGS,${CPPFLAGS_USED}${CPPFLAGS:+ }${CPPFLAGS:-}" \
  "CFLAGS,${CFLAGS_USED}${CFLAGS:+ }${CFLAGS:-}" \
  "LDFLAGS,${LDFLAGS_USED}${LDFLAGS:+ }${LDFLAGS:-}" \
  "DEBUG_CPPFLAGS,${DEBUG_CPPFLAGS_USED}${DEBUG_CPPFLAGS:+ }${DEBUG_CPPFLAGS:-}" \
  "DEBUG_CFLAGS,${DEBUG_CFLAGS_USED}${DEBUG_CFLAGS:+ }${DEBUG_CFLAGS:-}" \
  "CMAKE_PREFIX_PATH,${CMAKE_PREFIX_PATH_USED}" \
  "_CONDA_PYTHON_SYSCONFIGDATA_NAME,${_CONDA_PYTHON_SYSCONFIGDATA_NAME_USED}" \
  "CONDA_BUILD_SYSROOT,${CONDA_PREFIX}@LIBRARY_PREFIX@/@CHOST@/sysroot" \
  "CONDA_BUILD_CROSS_COMPILATION,@CONDA_BUILD_CROSS_COMPILATION@" \
  "CC_FOR_BUILD,${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/@CC_FOR_BUILD@" \
  "build_alias,@CBUILD@" \
  "host_alias,@CHOST@" \
  "MESON_ARGS,${_MESON_ARGS:-}" \
  "CMAKE_ARGS,${_CMAKE_ARGS:-}"

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

  # unfix prompt for zsh
  if [ -n "${ZSH_NAME:-}" ]; then
    # we use eval here to avoid non-POSIX shells trying to parse the ZSH syntax
    eval "precmd_functions=(\${precmd_functions:#_conda_clang_precmd})"
    eval "preexec_functions=(\${preexec_functions:#_conda_clang_preexec})"
  fi
fi

if [ "@IS_WIN@" = "1" ]; then
  CONDA_PREFIX=$(echo "${CONDA_PREFIX:-}" | sed 's,\/,\\,g')
fi
