source $RECIPE_DIR/get_cpu_arch.sh

mkdir -p ${PREFIX}/bin

pushd "${PREFIX}"/bin
  ln -s clang ${CHOST}-clang
  ln -s clang-cpp ${CHOST}-clang-cpp
  if [[ "${CBUILD}" != ${CHOST} ]]; then
    ln -s clang ${CBUILD}-clang
    ln -s clang-cpp ${CBUILD}-clang-cpp
  fi
popd
