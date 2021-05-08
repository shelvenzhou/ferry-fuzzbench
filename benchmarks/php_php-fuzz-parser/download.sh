#!/bin/bash -ex

pushd $SOURCE_PATH

if [ ! -d "php-src" ]
then
git clone --depth 1 --branch master https://github.com/php/php-src.git php-src
git clone https://github.com/kkos/oniguruma.git php-src/oniguruma
git -C php-src/oniguruma/ checkout -f 14f5efb82321e26502caa2df3c58aa1c2d36c801
fi

popd
