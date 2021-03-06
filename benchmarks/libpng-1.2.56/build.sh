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

cd libpng
./configure
make clean
make -j $(nproc)

mkdir -p $OUT/libpng
$CXX $CXXFLAGS -std=c++11 target.cc .libs/libpng12.a $FUZZER_LIB -I . -lz \
    -o $OUT/libpng/libpng_read_fuzzer
# cp -r /opt/seeds $OUT/

popd
