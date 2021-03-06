#!/bin/bash -eu
# Copyright 2020 Google Inc.
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
#
################################################################################

pushd $SOURCE_PATH

cd muparser

CFLAGS="${CFLAGS} -fno-sanitize=integer-divide-by-zero,float-divide-by-zero"
CXXFLAGS="${CXXFLAGS} -fno-sanitize=integer-divide-by-zero,float-divide-by-zero"

rm -rf install
mkdir install
# build project
cmake . -DBUILD_SHARED_LIBS=OFF -DENABLE_OPENMP=OFF -DCMAKE_INSTALL_PREFIX=$(realpath install)
make -j$(nproc)

# install
make install
# ldconfig

# build fuzzers
# MU_CXXFLAGS=$(pkg-config muparser --cflags)
# MU_LIBS=$(pkg-config muparser --libs)

mkdir -p $OUT/muparser
$CXX -std=c++11 $CXXFLAGS -I. \
     -I./install/include -L./install/lib \
     set_eval_fuzzer.cc -o $OUT/muparser/set_eval_fuzzer \
     $LIB_FUZZING_ENGINE libmuparser.a

popd
