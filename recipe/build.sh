#!/bin/bash

set -ex

source $RECIPE_DIR/get_cpu_arch.sh

cross_target_platform_u=${cross_target_platform/-/_}

FINAL_CFLAGS=FINAL_CFLAGS_${cross_target_platform_u}
FINAL_DEBUG_CFLAGS=FINAL_DEBUG_CFLAGS_${cross_target_platform_u}
FINAL_CXXFLAGS=FINAL_CXXFLAGS_${cross_target_platform_u}
FINAL_DEBUG_CXXFLAGS=FINAL_DEBUG_CXXFLAGS_${cross_target_platform_u}
FINAL_FFLAGS=FINAL_FFLAGS_${cross_target_platform_u}
FINAL_DEBUG_FFLAGS=FINAL_DEBUG_FFLAGS_${cross_target_platform_u}
FINAL_LDFLAGS=FINAL_LDFLAGS_${cross_target_platform_u}
FINAL_CONDA_PYTHON_SYSCONFIGDATA_NAME=FINAL_CONDA_PYTHON_SYSCONFIGDATA_NAME_${cross_target_platform_u}

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

if [[ "$target_platform" == "$cross_target_platform" ]]; then
  export CONDA_BUILD_CROSS_COMPILATION=""
else
  export CONDA_BUILD_CROSS_COMPILATION="1"
fi

if [[ "$cross_target_platform" == linux-ppc64le ]]; then
  MESON_FAMILY=ppc64
else
  MESON_FAMILY=${linux_machine}
fi

TOOLS="addr2line ar as c++filt elfedit gprof ld nm objcopy objdump ranlib readelf size strings strip"
if [[ "${cross_target_platform}" == "linux-"* ]]; then
  TOOLS="${TOOLS} dwp ld.gold"
else
  TOOLS="${TOOLS} dlltool"
fi

find . -name "*activate*.sh" -exec sed -i.bak "s|@TOOLS@|${TOOLS}|g"                                                                "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@LINUX_MACHINE@|${linux_machine}|g"                                                "{}" \;
find . -name "*activate*.sh" -exec sed -i.bak "s|@MESON_FAMILY@|${MESON_FAMILY}|g"                                                  "{}" \;
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
if [[ ! -z "${FINAL_CONDA_PYTHON_SYSCONFIGDATA_NAME}" ]]; then
  find . -name "*activate*.sh" -exec sed -i.bak "s|@_CONDA_PYTHON_SYSCONFIGDATA_NAME@|${FINAL_CONDA_PYTHON_SYSCONFIGDATA_NAME}|g"    "{}" \;
fi
find . -name "*activate*.sh" -exec sed -i.bak "s|@CONDA_BUILD_CROSS_COMPILATION@|${CONDA_BUILD_CROSS_COMPILATION}|g"                "{}" \;

cp activate-gcc.sh activate-clang.sh
cp activate-g++.sh activate-clang++.sh
cp deactivate-gcc.sh deactivate-clang.sh
cp deactivate-g++.sh deactivate-clang++.sh

find . -name "*activate-gcc.sh" -exec sed -i.bak "s|@COMPILERS@|cpp gcc gcc-ar gcc-nm gcc-ranlib|g"     "{}" \;
find . -name "*activate-g++.sh" -exec sed -i.bak "s|@CXX_COMPILERS@|g++|g"                              "{}" \;
find . -name "*activate-gcc.sh" -exec sed -i.bak "s|@CC@|${CHOST}-cc|g"                                 "{}" \;
find . -name "*activate-g++.sh" -exec sed -i.bak "s|@CXX@|${CHOST}-c++|g"                               "{}" \;
find . -name "*activate-gcc.sh" -exec sed -i.bak "s|@CC_FOR_BUILD@|${CBUILD}-cc|g"                      "{}" \;
find . -name "*activate-g++.sh" -exec sed -i.bak "s|@CXX_FOR_BUILD@|${CBUILD}-c++|g"                    "{}" \;

find . -name "*activate-clang.sh" -exec sed -i.bak "s|@COMPILERS@|clang|g"                              "{}" \;
find . -name "*activate-clang++.sh" -exec sed -i.bak "s|@CXX_COMPILERS@|clang++|g"                      "{}" \;
find . -name "*activate-clang.sh" -exec sed -i.bak "s|@CC@|${CHOST}-clang|g"                            "{}" \;
find . -name "*activate-clang++.sh" -exec sed -i.bak "s|@CXX@|${CHOST}-clang++|g"                       "{}" \;
find . -name "*activate-clang.sh" -exec sed -i.bak "s|@CC_FOR_BUILD@|${CBUILD}-clang|g"                 "{}" \;
find . -name "*activate-clang++.sh" -exec sed -i.bak "s|@CXX_FOR_BUILD@|${CBUILD}-clang++|g"            "{}" \;

find . -name "*activate*.sh.bak" -exec rm "{}" \;

# Check if (de-)activate scripts can be used in non-Bash shells (ignoring the commonly supported "local" keyword.)
errors=$(find . -name "*activate*.sh" -exec shellcheck -e SC3043 --severity=info --format=gcc {} \;)
echo $errors
if [[ ${errors} != "" ]]; then
  exit 1
fi
