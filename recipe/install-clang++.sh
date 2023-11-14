mkdir -p ${PREFIX}/etc/conda/{de,}activate.d
cp "${SRC_DIR}"/activate-clang++.sh ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh
cp "${SRC_DIR}"/deactivate-clang++.sh ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh

mkdir -p ${PREFIX}/bin
if [[ "$target_platform" != "$cross_target_platform" ]]; then
  ln -sf ${PREFIX}/bin/clang++ ${PREFIX}/bin/${ctng_cpu_arch}-conda-linux-gnu-clang++
  echo "--sysroot ${PREFIX}/${ctng_cpu_arch}-conda-linux-gnu/sysroot" >> ${PREFIX}/bin/${ctng_cpu_arch}-conda-linux-gnu-clang++.cfg
fi
