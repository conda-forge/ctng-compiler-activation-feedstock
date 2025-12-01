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

# The arguments to this are space separated environment
#  variable names. The value in CONDA_BACKUP_ is restore
#  and the CONDA_BACKUP_ is removed.
_tc_deactivation() {
  local thing
  local newval
  local from
  local to
  local pass

  from="CONDA_BACKUP_"
  to=""

  for thing in "$@"; do
    case "${thing}" in
      *,*)
        thing="${thing%%,*}"
        ;;
      *)
        ;;
    esac
    eval oldval="\$${from}$thing"
    if [ -n "${oldval}" ]; then
      eval export "${to}'${thing}'=\"${oldval}\""
    else
      eval unset '${to}${thing}'
    fi
    eval unset '${from}${thing}'
  done
  return 0
}

if [ "@IS_WIN@" = "1" ]; then
  CONDA_PREFIX=$(echo "${CONDA_PREFIX:-}" | sed 's,\\,\/,g')
fi

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  if [ -f /tmp/old-env-$$.txt ]; then
    rm -f /tmp/old-env-$$.txt || true
  fi
  env > /tmp/old-env-$$.txt
fi

# shellcheck disable=SC2050 # templating will fix this error
if [ "@CMAKE_SYSTEM_NAME@" != "Darwin" ]; then
  _tc_deactivation "CONDA_BUILD_SYSROOT"
fi

# shellcheck disable=SC2050 # templating will fix this error
if [ "@CONDA_BUILD_CROSS_COMPILATION@" = "1" ] && [ "@CMAKE_SYSTEM_NAME@" = "Linux" ]; then
  _tc_deactivation "QEMU_LD_PREFIX"
fi

_tc_deactivation \
  "HOST" \
  "BUILD" \
  "CONDA_TOOLCHAIN_HOST" \
  "CONDA_TOOLCHAIN_BUILD" \
  "CC" \
  "CPP" \
  "CC_FOR_BUILD" \
  "CPP_FOR_BUILD" \
  @C_EXTRA@ \
  "CPPFLAGS" \
  "CFLAGS" \
  "LDFLAGS" \
  "LDFLAGS_LD" \
  "DEBUG_CPPFLAGS" \
  "DEBUG_CFLAGS" \
  "CMAKE_PREFIX_PATH \
  "CONDA_BUILD_CROSS_COMPILATION" \
  "build_alias" \
  "host_alias" \
  "MESON_ARGS" \
  "CMAKE_ARGS"

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
