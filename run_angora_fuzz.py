import multiprocessing
import os
from datetime import datetime
import yaml

from fuzzers import utils
from fuzzers.angora import fuzzer

DEFAULT_SOURCE_BASE = os.path.join(utils.ROOT_DIR, '..', 'benchmarks')
DEFAULT_OUTPUT_BASE = os.path.join(utils.ROOT_DIR, '..', 'outputs')
DEFAULT_ANGORA_PATH = os.path.join(utils.ROOT_DIR, '..', '..', 'tools', 'Angora', 'angora_fuzzer')

FUZZBENCH_INPUTS = os.path.join(utils.ROOT_DIR, 'seeds', 'fuzzbench-inputs')


def get_input_corpus(benchmark):
    corpus_path = os.path.join(FUZZBENCH_INPUTS, benchmark)
    if not os.path.exists(corpus_path):
        print('seeds not found fot {}'.format(benchmark))
        exit(-1)

    return corpus_path


def build_targets():
    if os.environ.get('SOURCE_BASE') is None:
        if not os.path.exists(DEFAULT_SOURCE_BASE):
            os.makedirs(DEFAULT_SOURCE_BASE, exist_ok=True)
        os.environ['SOURCE_BASE'] = DEFAULT_SOURCE_BASE

    # fuzzer.build_all()


def fuzz_targets(fuzz_timeout='6h', processes=16):
    tested_fuzzer = os.environ['FUZZER']
    source_base = os.environ['SOURCE_BASE']
    fuzz_timestamp = datetime.now().isoformat()

    output_base = DEFAULT_OUTPUT_BASE
    if os.environ.get('OUTPUT_BASE') is not None:
        output_base = os.environ['OUTPUT_BASE']
    elif not os.path.exists(DEFAULT_OUTPUT_BASE):
        os.makedirs(DEFAULT_OUTPUT_BASE, exist_ok=True)

    angora_path = DEFAULT_ANGORA_PATH
    if os.environ.get('ANGORA_PATH') is not None:
        angora_path = os.environ['ANGORA_PATH']
    elif not os.path.exists(DEFAULT_ANGORA_PATH):
        print('Specify angora_fuzzer with $ANGORA_PATH')
        exit(-1)

    output_folder = os.path.join(output_base, '{}-{}'.format(tested_fuzzer, fuzz_timestamp))

    with open(os.path.join(output_folder, 'config.yaml'), 'w+') as f:
        yaml.dump({
            'fuzzer': tested_fuzzer,
            'timestamp': fuzz_timestamp,
            'input_corpus': get_input_corpus(''),
            'timeout': fuzz_timeout,
            'processes': processes,
        }, f)

    pool = multiprocessing.Pool(processes=processes)
    for benchmark in os.listdir(utils.BENCHMARKS_DIR):
        project = utils.get_config_value(benchmark, 'project')
        fuzz_target = utils.get_config_value(benchmark, 'fuzz_target')

        corpus_path = get_input_corpus(benchmark)
        input_corpus = os.path.join(corpus_path, 'seeds')
        dictionary_path = os.path.join(corpus_path, 'fuzz-target.dict')
        if not os.path.exists(dictionary_path):
            dictionary_path = None

        output_corpus = os.path.join(output_folder, project)
        os.makedirs(output_corpus)

        target_binary = os.path.join(source_base, "{}-target".format(tested_fuzzer), project, fuzz_target)

        print('Fuzz {project}: {fuzz_target} with fuzzer {fuzzer}'.format(
            project=project, fuzz_target=fuzz_target, fuzzer=tested_fuzzer))

        pool.apply_async(fuzzer.fuzz, (angora_path, input_corpus,
                         output_corpus, target_binary, fuzz_timeout))

    pool.close()
    pool.join()


if __name__ == "__main__":
    build_targets()

    fuzz_targets(fuzz_timeout='6h', processes=16)
