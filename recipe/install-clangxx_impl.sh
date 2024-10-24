source $RECIPE_DIR/get_cpu_arch.sh

mkdir -p ${PREFIX}/bin

pushd "${PREFIX}"/bin
  ln -s clang++ ${CHOST}-clang++
  if [[ "${CBUILD}" != ${CHOST} ]]; then
    ln -s clang++ ${CBUILD}-clang++
  fi
popd
