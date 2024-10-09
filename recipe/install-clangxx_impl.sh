source $RECIPE_DIR/get_cpu_arch.sh

mkdir -p ${PREFIX}/bin

pushd "${PREFIX}"/bin
  ln -s clang++ ${CHOST}-clang++
  # In the cross compiling case, we set CONDA_BUILD_SYSROOT to host platform
  # which makes compiling for build platform not work correctly.
  # The following overrides CONDA_BUILD_SYSROOT, so that a clang for a given
  # CHOST will always use the appropriate sysroot. In particular, this means
  # that a clang in the build environment will work correctly for its native
  # architecture also in cross compilation scenarios.
  echo "--sysroot ${PREFIX}/${CHOST}/sysroot" >> ${PREFIX}/bin/${CHOST}-clang++.cfg

  if [[ "${CBUILD}" != ${CHOST} ]]; then
    ln -s clang++ ${CBUILD}-clang++
  fi
popd
