mkdir -p ${PREFIX}/etc/conda/{de,}activate.d
cp "${SRC_DIR}"/activate-gcc.sh ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh
cp "${SRC_DIR}"/deactivate-gcc.sh ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh

ln -sf $CONDA_PREFIX/bin/clang++ $CONDA_PREFIX/bin/${ctng_cpu_arch}-conda-linux-gnu-clang++
echo "--sysroot $CONDA_PREFIX/${ctng_cpu_arch}-conda-linux-gnu/sysroot" >> $CONDA_PREFIX/bin/${ctng_cpu_arch}-conda-linux-gnu-clang++.cfg
