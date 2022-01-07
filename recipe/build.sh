#!/bin/bash

set -ex

source $RECIPE_DIR/get_cpu_arch.sh

FINAL_CFLAGS=FINAL_CFLAGS_${ctng_target_platform_u}
FINAL_DEBUG_CFLAGS=FINAL_DEBUG_CFLAGS_${ctng_target_platform_u}
FINAL_CXXFLAGS=FINAL_CXXFLAGS_${ctng_target_platform_u}
FINAL_DEBUG_CXXFLAGS=FINAL_DEBUG_CXXFLAGS_${ctng_target_platform_u}
FINAL_FFLAGS=FINAL_FFLAGS_${ctng_target_platform_u}
FINAL_DEBUG_FFLAGS=FINAL_DEBUG_FFLAGS_${ctng_target_platform_u}
FINAL_LDFLAGS=FINAL_LDFLAGS_${ctng_target_platform_u}
FINAL_CONDA_PYTHON_SYSCONFIGDATA_NAME=FINAL_CONDA_PYTHON_SYSCONFIGDATA_NAME_${ctng_target_platform_u}

FINAL_CFLAGS="${!FINAL_CFLAGS}"
FINAL_CXXFLAGS="${!FINAL_CXXFLAGS}"
FINAL_FFLAGS="${!FINAL_FFLAGS}"
FINAL_DEBUG_CFLAGS="${!FINAL_DEBUG_CFLAGS}"
FINAL_DEBUG_CXXFLAGS="${!FINAL_DEBUG_CXXFLAGS}"
FINAL_DEBUG_FFLAGS="${!FINAL_DEBUG_FFLAGS}"
FINAL_LDFLAGS="${!FINAL_LDFLAGS}"
FINAL_CONDA_PYTHON_SYSCONFIGDATA_NAME="${!FINAL_CONDA_PYTHON_SYSCONFIGDATA_NAME}"

MAJOR_VERSION="${PKG_VERSION%%.*}"

# See https://github.com/conda-forge/ctng-compiler-activation-feedstock/issues/42
# -std=c++17 shouldn't be a default flag, but from gcc 11 onwards it is the default.
# Not removing the flag for gcc 8, 9 because some package ABIs change according to
# the C++ standard (like boost).
if [[ "${MAJOR_VERSION}" != 8 && "${MAJOR_VERSION}" != 9 && "${MAJOR_VERSION}" != 10 ]]; then
    FINAL_CXXFLAGS="$(echo $FINAL_CXXFLAGS | sed 's/-std=c++17 //g')"
    FINAL_DEBUG_CXXFLAGS="$(echo $FINAL_DEBUG_CXXFLAGS | sed 's/-std=c++17 //g')"
fi
# -fopenmp shouldn't be a default flag. We are not removing it for gcc 9 as gcc 9.3
# already had this flag, but we are removing it for gcc 10+.
if [[ "${MAJOR_VERSION}" != 8 && "${MAJOR_VERSION}" != 9 ]]; then
    FINAL_FFLAGS="$(echo $FINAL_FFLAGS | sed 's/-fopenmp //g')"
    FINAL_DEBUG_FFLAGS="$(echo $FINAL_DEBUG_FFLAGS | sed 's/-fopenmp //g')"
fi

if [ -z "${FINAL_CFLAGS}" ]; then
    echo "FINAL_CFLAGS not set.  Did you pass in a flags variant config file?"
    exit 1
fi

if [[ "$target_platform" == "$ctng_target_platform" ]]; then
  export CONDA_BUILD_CROSS_COMPILATION=""
else
  export CONDA_BUILD_CROSS_COMPILATION="1"
fi

find . -name "*activate*.sh" -exec sed -i.bak "s|@LINUX_MACHINE@|${linux_machine}|g"                                                "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CBUILD@|${CBUILD}|g"                                                              "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CHOST@|${CHOST}|g"                                                                "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CPPFLAGS@|${FINAL_CPPFLAGS}|g"                                                    "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@DEBUG_CPPFLAGS@|${FINAL_DEBUG_CPPFLAGS}|g"                                        "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CFLAGS@|${FINAL_CFLAGS}|g"                                                       "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@DEBUG_CFLAGS@|${FINAL_DEBUG_CFLAGS}|g"                                           "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CXXFLAGS@|${FINAL_CXXFLAGS}|g"                                                   "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@DEBUG_CXXFLAGS@|${FINAL_DEBUG_CXXFLAGS}|g"                                       "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@FFLAGS@|${FINAL_FFLAGS}|g"                                                       "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@DEBUG_FFLAGS@|${FINAL_DEBUG_FFLAGS}|g"                                           "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@LDFLAGS@|${FINAL_LDFLAGS}|g"                                                     "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@_CONDA_PYTHON_SYSCONFIGDATA_NAME@|${FINAL_CONDA_PYTHON_SYSCONFIGDATA_NAME}|g"    "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@CONDA_BUILD_CROSS_COMPILATION@|${CONDA_BUILD_CROSS_COMPILATION}|g"                "{}" \;

find . -name "*activate*.sh.bak" -exec rm "{}" \;

# Check if (de-)activate scripts can be used in non-Bash shells (ignoring the commonly supported "local" keyword.)
errors=$(find . -name "*activate*.sh" -exec shellcheck -e SC3043 --severity=info --format=gcc {} \;)
echo $errors
if [[ ${errors} != "" ]]; then
  exit 1
fi
