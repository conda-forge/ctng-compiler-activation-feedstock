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

# When people are using conda-build, assume that adding rpath during build, and pointing at
#    the host env's includes and libs is helpful default behavior
if [ "${CONDA_BUILD:-0}" = "1" ]; then
  CXXFLAGS_USED="@CXXFLAGS@ -isystem ${PREFIX}@LIBRARY_PREFIX@/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
  DEBUG_CXXFLAGS_USED="@DEBUG_CXXFLAGS@ -isystem ${PREFIX}@LIBRARY_PREFIX@/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
else
  CXXFLAGS_USED="@CXXFLAGS@ -isystem ${CONDA_PREFIX}@LIBRARY_PREFIX@/include"
  DEBUG_CXXFLAGS_USED="@DEBUG_CXXFLAGS@ -isystem ${CONDA_PREFIX}@LIBRARY_PREFIX@/include"
fi

if [ "${CONDA_BUILD:-0}" = "1" ]; then
  if [ -f /tmp/old-env-$$.txt ]; then
    rm -f /tmp/old-env-$$.txt || true
  fi
  env > /tmp/old-env-$$.txt
fi

_tc_activation \
  @CXX_EXTRA@ \
  "CXX,${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/@CXX@" \
  "CXXFLAGS,${CXXFLAGS_USED}${CXXFLAGS:+ }${CXXFLAGS:-}" \
  "DEBUG_CXXFLAGS,${DEBUG_CXXFLAGS_USED}${DEBUG_CXXFLAGS:+ }${DEBUG_CXXFLAGS:-}" \
  "CXX_FOR_BUILD,${CONDA_PREFIX}@LIBRARY_PREFIX@/bin/@CXX_FOR_BUILD@"

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
fi

if [ "@IS_WIN@" = "1" ]; then
  CONDA_PREFIX=$(echo "${CONDA_PREFIX:-}" | sed 's,\/,\\,g')
fi
