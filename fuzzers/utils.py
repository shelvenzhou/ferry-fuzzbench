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
"""Utility functions for running fuzzers."""

import ast
import configparser
import contextlib
import os
import shutil
import subprocess
import tempfile

import yaml

ROOT_DIR = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))
BENCHMARKS_DIR = os.path.join(ROOT_DIR, 'benchmarks')
FUZZERS_DIR = os.path.join(ROOT_DIR, 'fuzzers')
SEEDS_DIR = os.path.join(ROOT_DIR, 'seeds')

# Keep all fuzzers at same optimization level until fuzzer explicitly needs or
# specifies it.
DEFAULT_OPTIMIZATION_LEVEL = '-O3'
BUGS_OPTIMIZATION_LEVEL = '-O1'

LIBCPLUSPLUS_FLAG = '-stdlib=libc++'

# Flags to use when using sanitizer for bug based benchmarking.
SANITIZER_FLAGS = [
    '-fsanitize=address',
    # Matches UBSan features enabled in OSS-Fuzz.
    # See https://github.com/google/oss-fuzz/blob/master/infra/base-images/base-builder/Dockerfile#L94
    '-fsanitize=array-bounds,bool,builtin,enum,float-divide-by-zero,function,'
    'integer-divide-by-zero,null,object-size,return,returns-nonnull-attribute,'
    'shift,signed-integer-overflow,unreachable,vla-bound,vptr',
]

# Use these flags when compiling benchmark code without a sanitizer (e.g. when
# using eclipser). This is necessary because many OSS-Fuzz targets cannot
# otherwise be compiled without a sanitizer because they implicitly depend on
# libraries linked into the sanitizer runtime. These flags link against those
# libraries.
NO_SANITIZER_COMPAT_CFLAGS = [
    '-pthread', '-Wl,--no-as-needed', '-Wl,-ldl', '-Wl,-lm',
    '-Wno-unused-command-line-argument'
]

OSS_FUZZ_LIB_FUZZING_ENGINE_PATH = '/usr/lib/libFuzzingEngine.a'
BENCHMARK_CONFIG_YAML_PATH = '/benchmark.yaml'


def build_benchmark(env=None):
    """Build a benchmark using fuzzer library."""
    if not env:
        env = os.environ.copy()

    # Add OSS-Fuzz environment variable for fuzzer library.
    fuzzer_lib = env['FUZZER_LIB']
    env['LIB_FUZZING_ENGINE'] = fuzzer_lib
    if os.path.exists(fuzzer_lib):
        # Make /usr/lib/libFuzzingEngine.a point to our library for OSS-Fuzz
        # so we can build projects that are using -lFuzzingEngine.
        shutil.copy(fuzzer_lib, OSS_FUZZ_LIB_FUZZING_ENGINE_PATH)

    build_script = os.path.join(os.environ['SRC'], 'build.sh')

    benchmark = os.getenv('BENCHMARK')
    fuzzer = os.getenv('FUZZER')
    print('Building benchmark {benchmark} with fuzzer {fuzzer}'.format(
        benchmark=benchmark, fuzzer=fuzzer))
    subprocess.check_call(['/bin/bash', '-ex', build_script], env=env)


def build_benchmarks(env=None, unsupported_benchmarks=[]):
    """Build a benchmark using fuzzer library."""
    if not env:
        env = os.environ.copy()

    # Add OSS-Fuzz environment variable for fuzzer library.
    fuzzer_lib = env['FUZZER_LIB']
    env['LIB_FUZZING_ENGINE'] = fuzzer_lib

    source_base = env.get('SOURCE_BASE')
    if source_base is None:
        print('$SOURCE_BASE has to be set')
        exit(-1)

    fuzzer = os.getenv('FUZZER')
    source_path = os.path.join(source_base, "{}-source".format(fuzzer))
    target_path = os.path.join(source_base, "{}-target".format(fuzzer))

    os.makedirs(source_path, exist_ok=True)
    os.makedirs(target_path, exist_ok=True)

    env['SOURCE_PATH'] = source_path
    env['OUT'] = target_path

    whitelist = [
        'harfbuzz-1.3.2',
        'vorbis-2017-12-11',
        'woff2-2016-05-06',
        'mbedtls_fuzz_dtlsclient',
        'openthread-2019-12-23',
        'libpcap_fuzz_both',
        'freetype2-2017',
        'zlib_zlib_uncompress_fuzzer',
        're2-2014-12-09',
        'libjpeg-turbo-07-2017',
        'bloaty_fuzz_target',
        'jsoncpp_jsoncpp_fuzzer',
        'libxml2-v2.9.2',
        'libpng-1.2.56',
        'lcms-2017-03-21',
        'proj4-2017-08-14',
    ]

    for benchmark in os.listdir(BENCHMARKS_DIR):
        if benchmark in unsupported_benchmarks or benchmark not in whitelist:
            print('Skip unsupported benchmark {benchmark} with fuzzer {fuzzer}'.format(
                benchmark=benchmark, fuzzer=fuzzer))
            continue

        download_script = os.path.join(BENCHMARKS_DIR, benchmark, 'download.sh')
        build_script = os.path.join(BENCHMARKS_DIR, benchmark, 'build.sh')

        if not os.path.exists(download_script):
            print('Skip benchmark {benchmark}'.format(benchmark=benchmark))
            continue

        print('Downloading benchmark {benchmark} with fuzzer {fuzzer}'.format(
            benchmark=benchmark, fuzzer=fuzzer))

        args = ['/bin/bash', '-ex', download_script]
        if os.getenv('USE_PROXY') is not None:
            args = ['proxychains', *args]
        subprocess.check_call(args, env=env)

        print('Building benchmark {benchmark} with fuzzer {fuzzer}'.format(
            benchmark=benchmark, fuzzer=fuzzer))
        subprocess.check_call(['/bin/bash', '-ex', build_script], env=env)


def append_flags(env_var, additional_flags, env=None):
    """Append |additional_flags| to those already set in the value of |env_var|
    and assign env_var to the result."""
    if env is None:
        env = os.environ

    env_var_value = env.get(env_var)
    flags = env_var_value.split(' ') if env_var_value else []
    flags.extend(additional_flags)
    env[env_var] = ' '.join(flags)


def get_config_value(benchmark, attribute):
    """Gets config attribute value from benchmark config yaml file."""
    with open(os.path.join(BENCHMARKS_DIR, benchmark, 'benchmark.yaml')) as file_handle:
        config = yaml.load(file_handle, yaml.SafeLoader)
        return config.get(attribute)


@contextlib.contextmanager
def restore_directory(directory):
    """Helper contextmanager that when created saves a backup of |directory| and
    when closed/exited replaces |directory| with the backup.

    Example usage:

    directory = 'my-directory'
    with restore_directory(directory):
       shutil.rmtree(directory)
    # At this point directory is in the same state where it was before we
    # deleted it.
    """
    # TODO(metzman): Figure out if this is worth it, so far it only allows QSYM
    # to compile bloaty.
    if not directory:
        # Don't do anything if directory is None.
        yield
        return
    # Save cwd so that if it gets deleted we can just switch into the restored
    # version without code that runs after us running into issues.
    initial_cwd = os.getcwd()
    with tempfile.TemporaryDirectory() as temp_dir:
        backup = os.path.join(temp_dir, os.path.basename(directory))
        shutil.copytree(directory, backup, symlinks=True)
        yield
        shutil.rmtree(directory)
        shutil.move(backup, directory)
        try:
            os.getcwd()
        except FileNotFoundError:
            os.chdir(initial_cwd)


def get_dictionary_path(target_binary):
    """Return dictionary path for a target binary."""
    if get_env('NO_DICTIONARIES'):
        # Don't use dictionaries if experiment specifies not to.
        return None

    dictionary_path = target_binary + '.dict'
    if os.path.exists(dictionary_path):
        return dictionary_path

    options_file_path = target_binary + '.options'
    if not os.path.exists(options_file_path):
        return None

    config = configparser.ConfigParser()
    with open(options_file_path, 'r') as file_handle:
        try:
            config.read_file(file_handle)
        except configparser.Error as error:
            raise Exception('Failed to parse fuzzer options file: ' +
                            options_file_path) from error

    for section in config.sections():
        for key, value in config.items(section):
            if key == 'dict':
                dictionary_path = os.path.join(os.path.dirname(target_binary),
                                               value)
                if not os.path.exists(dictionary_path):
                    raise ValueError('Bad dictionary path in options file: ' +
                                     options_file_path)
                return dictionary_path
    return None


def set_fuzz_target(env=None):
    """Set |FUZZ_TARGET| env flag."""
    if env is None:
        env = os.environ

    env['FUZZ_TARGET'] = get_config_value('fuzz_target')


def set_compilation_flags(env=None):
    """Set compilation flags."""
    if env is None:
        env = os.environ

    env['CFLAGS'] = ''
    env['CXXFLAGS'] = ''

    if get_config_value('type') == 'bug':
        append_flags('CFLAGS',
                     SANITIZER_FLAGS + [BUGS_OPTIMIZATION_LEVEL],
                     env=env)
        append_flags('CXXFLAGS',
                     SANITIZER_FLAGS +
                     [LIBCPLUSPLUS_FLAG, BUGS_OPTIMIZATION_LEVEL],
                     env=env)
    else:
        append_flags('CFLAGS',
                     NO_SANITIZER_COMPAT_CFLAGS + [DEFAULT_OPTIMIZATION_LEVEL],
                     env=env)
        append_flags('CXXFLAGS',
                     NO_SANITIZER_COMPAT_CFLAGS +
                     [LIBCPLUSPLUS_FLAG, DEFAULT_OPTIMIZATION_LEVEL],
                     env=env)


def initialize_env(env=None):
    """Set initial flags before fuzzer.build() is called."""
    set_fuzz_target(env)
    set_compilation_flags(env)

    for env_var in ['FUZZ_TARGET', 'CFLAGS', 'CXXFLAGS']:
        print('{env_var} = {env_value}'.format(env_var=env_var,
                                               env_value=os.getenv(env_var)))


def get_env(env_var, default_value=None):
    """Return the evaluated value of |env_var| in the environment. This is
    a copy of common.environment.get function as fuzzers can't have source
    dependencies outside of this directory."""
    value_string = os.getenv(env_var)

    # value_string will be None if the variable is not defined.
    if value_string is None:
        return default_value

    try:
        return ast.literal_eval(value_string)
    except Exception:  # pylint: disable=broad-except
        # String fallback.
        return value_string


def create_seed_file_for_empty_corpus(input_corpus):
    """Create a fake seed file in an empty corpus, skip otherwise."""
    if os.listdir(input_corpus):
        # Input corpus has some files, no need of a seed file. Bail out.
        return

    print('Creating a fake seed file in empty corpus directory.')
    default_seed_file = os.path.join(input_corpus, 'default_seed')
    with open(default_seed_file, 'w') as file_handle:
        file_handle.write('hi')
