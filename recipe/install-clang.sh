source $RECIPE_DIR/get_cpu_arch.sh

mkdir -p ${PREFIX}/etc/conda/{de,}activate.d
cp "${SRC_DIR}"/activate-clang.sh ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh
cp "${SRC_DIR}"/deactivate-clang.sh ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh

if [[ "$target_platform" == linux-* && "$target_platform" != "$cross_target_platform" ]]; then
  # Set clang symlink with target
  mkdir -p ${CONDA_PREFIX}/bin
  ln -sf ${CONDA_PREFIX}/bin/clang ${CONDA_PREFIX}/bin/${CHOST}-clang
  # Set sysroot. The other option is to use `CONDA_BUILD_SYSROOT` env variable
  # but this is better than using an env variable.
  echo "--sysroot ${CONDA_PREFIX}/${CHOST}/sysroot" >> ${CONDA_PREFIX}/bin/${CHOST}-clang.cfg
fi

