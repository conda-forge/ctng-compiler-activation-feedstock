source $RECIPE_DIR/get_cpu_arch.sh

mkdir -p ${PREFIX}/etc/conda/{de,}activate.d
cp "${SRC_DIR}"/activate-clang.sh ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh
cp "${SRC_DIR}"/deactivate-clang.sh ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh
