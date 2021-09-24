# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Integration code for AFL fuzzer."""

import json
import os
import shutil
import subprocess

from fuzzers import utils

os.environ['FUZZER'] = 'Angora'


def prepare_build_environment():
    cxxflags = ['-stdlib=libc++', '-std=c++11', '-pthread']
    utils.append_flags('CXXFLAGS', cxxflags)

    os.environ['ANGORA_CC'] = '/home/ferry/Documents/tools/Angora/clang+llvm-7.0.0/bin/clang'
    os.environ['ANGORA_CXX'] = '/home/ferry/Documents/tools/Angora/clang+llvm-7.0.0/bin/clang++'
    os.environ['ANGORA_TAINT_RULE_LIST'] = '/home/ferry/Documents/tools/Angora/bin/rules/zlib_abilist.txt'

    os.environ['CC'] = '/home/ferry/Documents/tools/Angora/bin/angora-clang'
    os.environ['CXX'] = '/home/ferry/Documents/tools/Angora/bin/angora-clang++'
    os.environ['LD'] = '/home/ferry/Documents/tools/Angora/bin/angora-clang'
    os.environ['FUZZER_LIB'] = ''

    os.environ['USE_POSIX_TARGET'] = ''


def build():
    """Build benchmark."""
    prepare_build_environment()

    utils.build_benchmark()

    # print('[post_build] Copying afl-fuzz to $OUT directory')
    # # Copy out the afl-fuzz binary as a build artifact.
    # shutil.copy('/afl/afl-fuzz', os.environ['OUT'])


def build_all():
    """Build benchmarks."""
    prepare_build_environment()

    unsupported_benchmarks = [
        'bloaty_fuzz_target',
    ]

    os.environ['FUZZER'] = 'Angora-taint'
    os.environ['USE_TRACK'] = '1'
    utils.build_benchmarks(unsupported_benchmarks=unsupported_benchmarks)
    del os.environ['USE_TRACK']

    os.environ['FUZZER'] = 'Angora-fast'
    os.environ['USE_FAST'] = '1'
    utils.build_benchmarks(unsupported_benchmarks=unsupported_benchmarks)

    # print('[post_build] Copying afl-fuzz to $OUT directory')
    # # Copy out the afl-fuzz binary as a build artifact.
    # shutil.copy('/afl/afl-fuzz', os.environ['OUT'])


def prepare_fuzz_environment():
    pass


def run_angora_fuzz(angora_path,
                    input_corpus,
                    output_corpus,
                    taint_binary,
                    target_binary,
                    timeout=None,
                    hide_output=False):
    """Run Angora."""
    print('[run_angora_fuzz] Running target with angora')

    if timeout is not None:
        command = ['timeout', '-s', 'INT', timeout]

    command += [
        angora_path,
        '-i',
        input_corpus,
        '-o',
        output_corpus,
        '-t',
        taint_binary,
        '--',
        target_binary,
        '@@'
    ]
    print('[run_angora_fuzz] Running command: ' + ' '.join(command))

    output_stream = subprocess.DEVNULL if hide_output else None
    subprocess.check_call(command, stdout=output_stream, stderr=output_stream)


def fuzz(angora_path, input_corpus, output_corpus, target_binary, timeout=None):
    """Run angora on target."""
    prepare_fuzz_environment()

    run_angora_fuzz(angora_path, input_corpus, output_corpus, target_binary, timeout=timeout)
