mkdir -p ${PREFIX}/etc/conda/{de,}activate.d
cp "${SRC_DIR}"/activate-gcc_bootstrap_noopenmp.sh ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh
cp "${SRC_DIR}"/deactivate-gcc_bootstrap_noopenmp.sh ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh
