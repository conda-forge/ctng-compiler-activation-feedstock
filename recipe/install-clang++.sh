source $RECIPE_DIR/get_cpu_arch.sh

mkdir -p ${PREFIX}/etc/conda/{de,}activate.d
cp "${SRC_DIR}"/activate-clang++.sh ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh
cp "${SRC_DIR}"/deactivate-clang++.sh ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh

if [[ "$target_platform" != "$cross_target_platform" ]]; then
  # Set clang++ symlink with target
  mkdir -p ${PREFIX}/bin
  ln -sf ${PREFIX}/bin/clang++ ${PREFIX}/bin/${CHOST}-clang++
  # Set sysroot. The other option is to use `CONDA_BUILD_SYSROOT` env variable
  # but this is better than using an env variable.
  echo "--sysroot ${PREFIX}/${CHOST}/sysroot" >> ${PREFIX}/bin/${CHOST}-clang++.cfg
fi
