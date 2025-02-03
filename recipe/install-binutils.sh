mkdir -p ${PREFIX}/etc/conda/{de,}activate.d
cp "${SRC_DIR}"/activate-binutils.sh ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh
cp "${SRC_DIR}"/deactivate-binutils.sh ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh

if [[ "$target_platform" == "win-"* ]]; then
  cp "${SRC_DIR}"/activate-binutils.bat ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.bat
  cp "${SRC_DIR}"/deactivate-binutils.bat ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.bat
  cp "${SRC_DIR}"/activate-binutils.ps1 ${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.ps1
  cp "${SRC_DIR}"/deactivate-binutils.ps1 ${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.ps1
fi
