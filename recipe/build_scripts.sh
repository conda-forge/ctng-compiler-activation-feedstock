!/bin/bash

set -ex

source $RECIPE_DIR/get_cpu_arch.sh

FINAL_CPPFLAGS="-DNDEBUG -D_FORTIFY_SOURCE=2 -O2"

FINAL_CFLAGS_linux_64="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe"
FINAL_CFLAGS_linux_ppc64le="-mcpu=power8 -mtune=power8 -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O3 -pipe"
FINAL_CFLAGS_linux_aarch64="-ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O3 -pipe"
FINAL_CFLAGS_linux_s390x="-ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O3 -pipe"
FINAL_CFLAGS_win_64="-ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O3 -pipe"
FINAL_CFLAGS_osx_64="-march=core2 -mtune=haswell -mssse3 -ftree-vectorize -fPIC -fstack-protector-strong -O2 -pipe"
FINAL_CFLAGS_osx_arm64="-ftree-vectorize -fPIC -fstack-protector-strong -O2 -pipe"

FINAL_CXXFLAGS_linux_64="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe"
FINAL_CXXFLAGS_linux_ppc64le="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -mcpu=power8 -mtune=power8 -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O3 -pipe"
FINAL_CXXFLAGS_linux_aarch64="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O3 -pipe"
FINAL_CXXFLAGS_linux_s390x="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O3 -pipe"
FINAL_CXXFLAGS_win_64="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O3 -pipe"
FINAL_CXXFLAGS_osx_64="-march=core2 -mtune=haswell -mssse3 -ftree-vectorize -fPIC -fstack-protector-strong -O2 -pipe -stdlib=libc++ -fvisibility-inlines-hidden -fmessage-length=0"
FINAL_CXXFLAGS_osx_arm64="-ftree-vectorize -fPIC -fstack-protector-strong -O2 -pipe -stdlib=libc++ -fvisibility-inlines-hidden -fmessage-length=0"

FINAL_FFLAGS_linux_64="-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe"
FINAL_FFLAGS_linux_ppc64le="-fopenmp -mcpu=power8 -mtune=power8 -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O3 -pipe"
FINAL_FFLAGS_linux_aarch64="-fopenmp -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O3 -pipe"
FINAL_FFLAGS_linux_s390x="-fopenmp -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O3 -pipe"
FINAL_FFLAGS_win_64="-fopenmp -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O3 -pipe"
FINAL_FFLAGS_osx_64="-march=core2 -mtune=haswell -ftree-vectorize -fPIC -fstack-protector -O2 -pipe"
FINAL_FFLAGS_osx_arm64="-march=armv8.3-a -ftree-vectorize -fPIC -fno-stack-protector -O2 -pipe"

FINAL_LDFLAGS_linux_64="-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--disable-new-dtags -Wl,--gc-sections -Wl,--allow-shlib-undefined"
FINAL_LDFLAGS_linux_ppc64le="-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--allow-shlib-undefined"
FINAL_LDFLAGS_linux_aarch64="-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--allow-shlib-undefined"
FINAL_LDFLAGS_linux_s390x="-Wl,-O2 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,--allow-shlib-undefined"
FINAL_LDFLAGS_win_64="-Wl,-O2 -Wl,--sort-common"
FINAL_LDFLAGS_osx_64="-Wl,-headerpad_max_install_names -Wl,-dead_strip_dylibs"
FINAL_LDFLAGS_osx_arm64="-Wl,-headerpad_max_install_names -Wl,-dead_strip_dylibs"

FINAL_LDFLAGS_LD_linux_64="-O2 --sort-common --as-needed -z relro -z now --disable-new-dtags --gc-sections --allow-shlib-undefined"
FINAL_LDFLAGS_LD_linux_ppc64le="-O2 --sort-common --as-needed -z relro -z now --allow-shlib-undefined"
FINAL_LDFLAGS_LD_linux_aarch64="-O2 --sort-common --as-needed -z relro -z now --allow-shlib-undefined"
FINAL_LDFLAGS_LD_linux_s390x="-O2 --sort-common --as-needed -z relro -z now --allow-shlib-undefined"
FINAL_LDFLAGS_LD_win_64="-O2 --sort-common"
FINAL_LDFLAGS_LD_osx_64="-headerpad_max_install_names -dead_strip_dylibs"
FINAL_LDFLAGS_LD_osx_arm64="-headerpad_max_install_names -dead_strip_dylibs"

FINAL_DEBUG_CPPFLAGS="-D_DEBUG -D_FORTIFY_SOURCE=2 -Og"

FINAL_DEBUG_CFLAGS_linux_64="-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe"
FINAL_DEBUG_CFLAGS_linux_ppc64le="-mcpu=power8 -mtune=power8 -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -pipe"
FINAL_DEBUG_CFLAGS_linux_aarch64="-ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -pipe"
FINAL_DEBUG_CFLAGS_linux_s390x="-ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -pipe"
FINAL_DEBUG_CFLAGS_win_64="-ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -pipe"
FINAL_DEBUG_CFLAGS_osx_64="-Og -g -Wall -Wextra"
FINAL_DEBUG_CFLAGS_osx_arm64="-Og -g -Wall -Wextra"

FINAL_DEBUG_CXXFLAGS_linux_64="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -ffunction-sections -pipe"
FINAL_DEBUG_CXXFLAGS_linux_ppc64le="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -mcpu=power8 -mtune=power8 -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -pipe"
FINAL_DEBUG_CXXFLAGS_linux_aarch64="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -pipe"
FINAL_DEBUG_CXXFLAGS_linux_s390x="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -pipe"
FINAL_DEBUG_CXXFLAGS_win_64="-fvisibility-inlines-hidden -std=c++17 -fmessage-length=0 -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fvar-tracking-assignments -pipe"
FINAL_DEBUG_CXXFLAGS_osx_64="-Og -g -Wall -Wextra"
FINAL_DEBUG_CXXFLAGS_osx_arm64="-Og -g -Wall -Wextra"

FINAL_DEBUG_FFLAGS_linux_64="-fopenmp -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-all -fno-plt -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments -ffunction-sections -pipe"
FINAL_DEBUG_FFLAGS_linux_ppc64le="-fopenmp -mcpu=power8 -mtune=power8 -ftree-vectorize -fPIC -fstack-protector-strong -pipe -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fvar-tracking-assignments -pipe"
FINAL_DEBUG_FFLAGS_linux_aarch64="-fopenmp -ftree-vectorize -fPIC -fstack-protector-strong -pipe -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fvar-tracking-assignments -pipe"
FINAL_DEBUG_FFLAGS_linux_s390x="-fopenmp -ftree-vectorize -fPIC -fstack-protector-strong -pipe -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fvar-tracking-assignments -pipe"
FINAL_DEBUG_FFLAGS_win_64="-fopenmp -ftree-vectorize -fPIC -fstack-protector-strong -pipe -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fvar-tracking-assignments -pipe"
FINAL_DEBUG_FFLAGS_osx_64="-march=core2 -mtune=haswell -ftree-vectorize -fPIC -fstack-protector -O2 -pipe -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments"
FINAL_DEBUG_FFLAGS_osx_64="-march=armv8.3-a -ftree-vectorize -fPIC -fno-stack-protector -O2 -pipe -Og -g -Wall -Wextra -fcheck=all -fbacktrace -fimplicit-none -fvar-tracking-assignments"

cross_target_platform_u=${cross_target_platform/-/_}

FINAL_CFLAGS=FINAL_CFLAGS_${cross_target_platform_u}
FINAL_DEBUG_CFLAGS=FINAL_DEBUG_CFLAGS_${cross_target_platform_u}
FINAL_CXXFLAGS=FINAL_CXXFLAGS_${cross_target_platform_u}
FINAL_DEBUG_CXXFLAGS=FINAL_DEBUG_CXXFLAGS_${cross_target_platform_u}
FINAL_FFLAGS=FINAL_FFLAGS_${cross_target_platform_u}
FINAL_DEBUG_FFLAGS=FINAL_DEBUG_FFLAGS_${cross_target_platform_u}
FINAL_LDFLAGS=FINAL_LDFLAGS_${cross_target_platform_u}
FINAL_LDFLAGS_LD=FINAL_LDFLAGS_LD_${cross_target_platform_u}

echo "FINAL_CFLAGS_linux_64: ${FINAL_CFLAGS_linux_64}"

FINAL_CFLAGS="${!FINAL_CFLAGS}"
echo "$FINAL_CFLAGS"
FINAL_CXXFLAGS="${!FINAL_CXXFLAGS}"
FINAL_FFLAGS="${!FINAL_FFLAGS}"
FINAL_DEBUG_CFLAGS="${!FINAL_DEBUG_CFLAGS}"
FINAL_DEBUG_CXXFLAGS="${!FINAL_DEBUG_CXXFLAGS}"
FINAL_DEBUG_FFLAGS="${!FINAL_DEBUG_FFLAGS}"
FINAL_LDFLAGS="${!FINAL_LDFLAGS}"
FINAL_LDFLAGS_LD="${!FINAL_LDFLAGS_LD}"

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

if [[ "$target_platform" == "win-"* ]]; then
  IS_WIN=1
else
  IS_WIN=0
fi


if [[ "${cross_target_platform}" == "linux-"* ]]; then
  CMAKE_SYSTEM_NAME="Linux"
elif [[ "${cross_target_platform}" == "win-"* ]]; then
  CMAKE_SYSTEM_NAME="Windows"
else
  CMAKE_SYSTEM_NAME="Darwin"
fi

MESON_NAME=$(echo "$CMAKE_SYSTEM_NAME" | tr '[:upper:]' '[:lower:]')

if [[ "${target_platform}" == "win-"* ]]; then
  LIBRARY_PREFIX="/Library"
  EXE_EXT=".exe"
else
  LIBRARY_PREFIX=""
  EXE_EXT=""
fi

MACHINE=$(echo ${CHOST} | cut -d "-" -f1)
MESON_FAMILY=${MACHINE}

if [[ "$cross_target_platform" == linux-ppc64le ]]; then
  MACHINE="ppc64le"
  MESON_FAMILY="ppc64"
fi

if [[ "${cross_target_platform}" == "osx-64" ]]; then
  uname_kernel_release=13.4.0
elif [[ "${cross_target_platform}" == "osx-arm64" ]]; then
  uname_kernel_release=20.0.0
fi

find . -name "*activate*.*" -exec sed -i.bak "s|@UNAME_KERNEL_RELEASE@|${uname_kernel_release}|g"                                  "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@IS_WIN@|${IS_WIN}|g"                                                              "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@TOOLS@|${TOOLS}|g"                                                                "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@MACHINE@|${MACHINE}|g"                                                            "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@CMAKE_SYSTEM_NAME@|${CMAKE_SYSTEM_NAME}|g"                                        "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@MESON_SYSTEM@|${MESON_SYSTEM}|g"                                                  "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@MESON_FAMILY@|${MESON_FAMILY}|g"                                                  "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@CBUILD@|${CBUILD}|g"                                                              "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@CHOST@|${CHOST}|g"                                                                "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@CPPFLAGS@|${FINAL_CPPFLAGS}|g"                                                    "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@DEBUG_CPPFLAGS@|${FINAL_DEBUG_CPPFLAGS}|g"                                        "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@CFLAGS@|${FINAL_CFLAGS}|g"                                                       "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@DEBUG_CFLAGS@|${FINAL_DEBUG_CFLAGS}|g"                                           "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@CXXFLAGS@|${FINAL_CXXFLAGS}|g"                                                   "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@DEBUG_CXXFLAGS@|${FINAL_DEBUG_CXXFLAGS}|g"                                       "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@FFLAGS@|${FINAL_FFLAGS}|g"                                                       "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@DEBUG_FFLAGS@|${FINAL_DEBUG_FFLAGS}|g"                                           "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@LDFLAGS@|${FINAL_LDFLAGS}|g"                                                     "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@LDFLAGS_LD@|${FINAL_LDFLAGS_LD}|g"                                               "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@EXE_EXT@|${EXE_EXT}|g"                                                           "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@LIBRARY_PREFIX@|${LIBRARY_PREFIX}|g"                                             "{}" \;
find . -name "*activate*.*" -exec sed -i.bak "s|@CONDA_BUILD_CROSS_COMPILATION@|${CONDA_BUILD_CROSS_COMPILATION}|g"                "{}" \;

cp activate-gcc.sh activate-clang.sh
cp activate-g++.sh activate-clang++.sh
cp deactivate-gcc.sh deactivate-clang.sh
cp deactivate-g++.sh deactivate-clang++.sh

GCC_EXTRA="
\"GCC,\${CONDA_PREFIX}${LIBRARY_PREFIX}/bin/${CHOST}-gcc\"
\"GCC_AR,\${CONDA_PREFIX}${LIBRARY_PREFIX}/bin/${CHOST}-gcc-ar\"
\"GCC_NM,\${CONDA_PREFIX}${LIBRARY_PREFIX}/bin/${CHOST}-gcc-nm\"
\"GCC_RANLIB,\${CONDA_PREFIX}${LIBRARY_PREFIX}/bin/${CHOST}-gcc-ranlib\"
"
GXX_EXTRA="
\"GXX,\${CONDA_PREFIX}${LIBRARY_PREFIX}/bin/${CHOST}-g++\"
"
find . -name "*activate-gcc.sh" -exec sed -i.bak "s|@C_EXTRA@|"${GCC_EXTRA}"|g"                         "{}" \;
find . -name "*activate-gcc.sh" -exec sed -i.bak "s|@CPP@|${CHOST}-cpp|g"                               "{}" \;
find . -name "*activate-gcc.sh" -exec sed -i.bak "s|@CPP_FOR_BUILD@|${CBUILD}-cpp|g"                    "{}" \;
find . -name "*activate-gcc.sh" -exec sed -i.bak "s|@AR@|${CHOST}-gcc-ar|g"                             "{}" \;
find . -name "*activate-gcc.sh" -exec sed -i.bak "s|@NM@|${CHOST}-gcc-nm|g"                             "{}" \;
find . -name "*activate-gcc.sh" -exec sed -i.bak "s|@RANLIB@|${CHOST}-gcc-ranlib|g"                     "{}" \;
find . -name "*activate-gcc.sh" -exec sed -i.bak "s|@CC@|${CHOST}-cc|g"                                 "{}" \;
find . -name "*activate-gcc.sh" -exec sed -i.bak "s|@CC_FOR_BUILD@|${CBUILD}-cc|g"                      "{}" \;
find . -name "*activate-g++.sh" -exec sed -i.bak "s|@CXX@|${CHOST}-c++|g"                               "{}" \;
find . -name "*activate-g++.sh" -exec sed -i.bak "s|@CXX_FOR_BUILD@|${CBUILD}-c++|g"                    "{}" \;
find . -name "*activate-g++.sh" -exec sed -i.bak "s|@CXX_EXTRA@|"${GXX_EXTRA}"|g"                       "{}" \;

CLANG_EXTRA='
\"CLANG,\${CONDA_PREFIX}{LIBRARY_PREFIX}/bin/${CHOST}-clang\"
\"OBJC,\${CONDA_PREFIX}{LIBRARY_PREFIX}/bin/${CHOST}-clang\"
\"OBJC_FOR_BUILD,\${CONDA_PREFIX}{LIBRARY_PREFIX}/bin/${CBUILD}-clang\"
\"ac_cv_func_malloc_0_nonnull,yes\"
\"ac_cv_func_realloc_0_nonnull,yes\"
'
CLANGXX_EXTRA='
\"CLANGXX,\${CONDA_PREFIX}{LIBRARY_PREFIX}/bin/${CHOST}-clang++\"
"
find . -name "*activate-clang.sh" -exec sed -i.bak "s|@C_EXTRA@|"${CLANG_EXTRA}"|g"                     "{}" \;
find . -name "*activate-clang.sh" -exec sed -i.bak "s|@CPP@|${CHOST}-clang-cpp|g"                       "{}" \;
find . -name "*activate-clang.sh" -exec sed -i.bak "s|@CPP_FOR_BUILD@|${CBUILD}-clang-cpp|g"            "{}" \;
find . -name "*activate-clang.sh" -exec sed -i.bak "s|@AR@|${CHOST}-ar|g"                               "{}" \;
find . -name "*activate-clang.sh" -exec sed -i.bak "s|@NM@|${CHOST}-nm|g"                               "{}" \;
find . -name "*activate-clang.sh" -exec sed -i.bak "s|@RANLIB@|${CHOST}-ranlib|g"                       "{}" \;
find . -name "*activate-clang.sh" -exec sed -i.bak "s|@CC@|${CHOST}-clang|g"                            "{}" \;
find . -name "*activate-clang.sh" -exec sed -i.bak "s|@CC_FOR_BUILD@|${CBUILD}-clang|g"                 "{}" \;
find . -name "*activate-clang++.sh" -exec sed -i.bak "s|@CXX_EXTRA@|"${CLANGXX_EXTRA}"|g"               "{}" \;
find . -name "*activate-clang++.sh" -exec sed -i.bak "s|@CXX@|${CHOST}-clang++|g"                       "{}" \;
find . -name "*activate-clang++.sh" -exec sed -i.bak "s|@CXX_FOR_BUILD@|${CBUILD}-clang++|g"            "{}" \;

find . -name "*activate*.sh.bak" -exec rm "{}" \;

# Check if (de-)activate scripts can be used in non-Bash shells (ignoring the commonly supported "local" keyword.)
errors=$(find . -name "*activate*.sh" -exec shellcheck -e SC3043 -e SC2050 --severity=info --format=gcc {} \;)
echo $errors
if [[ ${errors} != "" ]]; then
  exit 1
fi
