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

cd PROJ
./autogen.sh
./configure --disable-shared
make clean
make -j $(nproc)

# mkdir $OUT/seeds
# cp nad/* $OUT/seeds

mkdir -p $OUT/proj4
$CXX $CXXFLAGS -std=c++11 -I src test/fuzzers/standard_fuzzer.cpp \
    src/.libs/libproj.a $FUZZER_LIB -o $OUT/proj4/standard_fuzzer -lpthread

popd
