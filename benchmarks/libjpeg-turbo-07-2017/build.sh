#!/bin/bash -ex
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

pushd $SOURCE_PATH

cd libjpeg-turbo
git checkout b0971e47d76fdb81270e93bbf11ff5558073350d
autoreconf -fiv
./configure --disable-shared --without-simd
make clean
make -j $(nproc)

mkdir -p $OUT/libjpeg-turbo
$CXX $CXXFLAGS -std=c++11 libjpeg_turbo_fuzzer.cc -I . \
    .libs/libturbojpeg.a $FUZZER_LIB -o $OUT/libjpeg-turbo/libjpeg_turbo_fuzzer
# cp -r /opt/seeds $OUT/

popd
