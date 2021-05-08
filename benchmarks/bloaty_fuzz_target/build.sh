#!/bin/bash -eu
# Copyright 2017 Google Inc.
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

cd bloaty
rm -rf build
mkdir build
cd build
cmake -G Ninja -DBUILD_TESTING=false ..
# add LLVM's libc++.so.1 to library search path
LD_LIBRARY_PATH="$(realpath ~/.local/lib):$LD_LIBRARY_PATH" ninja -j$(nproc)

mkdir -p $OUT/bloaty
cp fuzz_target $OUT/bloaty
# zip -j $OUT/fuzz_target_seed_corpus.zip $SRC/bloaty/tests/testdata/fuzz_corpus/*

popd