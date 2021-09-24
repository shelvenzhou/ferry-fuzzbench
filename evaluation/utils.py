import os
import subprocess

import yaml

ROOT_DIR = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))
BENCHMARKS_DIR = os.path.join(ROOT_DIR, 'benchmarks')

AFLCOV_PATH = "/home/ferry/Documents/ferry-fuzzbench/statistic/afl-cov/afl-cov"
SOURCE_BASE = "/home/ferry/Documents/ferry-fuzzbench/benchmarks/GCOV-source"
TARGET_BASE = "/home/ferry/Documents/ferry-fuzzbench/benchmarks/GCOV-target"

whitelist = [
            # 'bloaty_fuzz_target',
            # 'freetype2-2017',
            # 'harfbuzz-1.3.2',
            # 'jsoncpp_jsoncpp_fuzzer',
            # 'lcms-2017-03-21',
            'libarchive_libarchive_fuzzer',
            'libhevc_hevc_dec_fuzzer',
            'libhtp_fuzz_htp',
            # 'libjpeg-turbo-07-2017',
            # 'libpcap_fuzz_both',
            # 'libpng-1.2.56',
            # 'libxml2-v2.9.2',
            'libxslt_xpath',
            # 'mbedtls_fuzz_dtlsclient',
            'muparser_set_eval_fuzzer',
            'openh264_decoder_fuzzer',
            # 'openthread-2019-12-23',
            # 'proj4-2017-08-14',
            # 're2-2014-12-09',
            # 'vorbis-2017-12-11',
            # 'woff2-2016-05-06',
            # 'zlib_zlib_uncompress_fuzzer',
    ]


def get_config_value(benchmark, attribute):
    """Gets config attribute value from benchmark config yaml file."""
    with open(os.path.join(BENCHMARKS_DIR, benchmark, 'benchmark.yaml')) as file_handle:
        config = yaml.load(file_handle, yaml.SafeLoader)
        return config.get(attribute)


def get_branch_and_line_coverage():
    output_folder = os.environ.get('OUTPUT_FOLDER')
    if output_folder is None:
        print("OUTPUT_FOLDER needs to be set")
        exit(-1)

    for benchmark in os.listdir(BENCHMARKS_DIR):
        if benchmark not in whitelist:
            print('Skip unsupported benchmark {benchmark}'.format(
                benchmark=benchmark))
            continue

        project = get_config_value(benchmark, 'project')
        fuzz_target = get_config_value(benchmark, 'fuzz_target')

        output_path = os.path.join(output_folder, project)
        if not os.path.exists(output_path):
            print('Folder {} not exists'.format(output_path))
            continue

        command = [
            AFLCOV_PATH,
            '-d', output_path,
            '--enable-branch-coverage',
            '-c', os.path.join(SOURCE_BASE, project),
            '-e', '{} AFL_FILE'.format(os.path.join(TARGET_BASE, project, fuzz_target)),
            '--cover-corpus', '--coverage-include-lines'
        ]

        print("Get branch and line coverage of {}".format(project))
        subprocess.check_call(command)


if __name__ == '__main__':
    get_branch_and_line_coverage()
