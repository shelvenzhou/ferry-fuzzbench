import multiprocessing
import os
from datetime import datetime

from fuzzers import utils
from fuzzers.afl import fuzzer

DEFAULT_SOURCE_BASE = os.path.join(utils.ROOT_DIR, '..', 'benchmarks')
DEFAULT_OUTPUT_BASE = os.path.join(utils.ROOT_DIR, '..', 'outputs')
DEFAULT_AFL_PATH = os.path.join(utils.ROOT_DIR, '..', '..', 'tools', 'AFL', 'afl-fuzz')

FUZZBENCH_INPUTS = os.path.join(utils.ROOT_DIR, 'seeds', 'fuzzbench-inputs')


def get_input_corpus(benchmark):
    corpus_path = os.path.join(FUZZBENCH_INPUTS, benchmark)
    if not os.path.exists(corpus_path):
        print('seeds not found fot {}'.format(benchmark))
        exit(-1)

    return corpus_path


if __name__ == "__main__":

    tested_fuzzer = os.environ['FUZZER']

    if os.environ.get('SOURCE_BASE') is None:
        if not os.path.exists(DEFAULT_SOURCE_BASE):
            os.makedirs(DEFAULT_SOURCE_BASE, exist_ok=True)
        os.environ['SOURCE_BASE'] = DEFAULT_SOURCE_BASE
    source_base = os.environ['SOURCE_BASE']

    # fuzzer.build_all()

    fuzz_timestamp = datetime.now().isoformat()

    output_base = DEFAULT_OUTPUT_BASE
    if os.environ.get('OUTPUT_BASE') is not None:
        output_base = os.environ['OUTPUT_BASE']
    elif not os.path.exists(DEFAULT_OUTPUT_BASE):
        os.makedirs(DEFAULT_OUTPUT_BASE, exist_ok=True)

    afl_path = DEFAULT_AFL_PATH
    if os.environ.get('AFL_PATH') is not None:
        afl_path = os.environ['AFL_PATH']
    elif not os.path.exists(DEFAULT_AFL_PATH):
        print('Specify afl-fuzz with $AFL_PATH')
        exit(-1)

    pool = multiprocessing.Pool(processes=10)
    for benchmark in os.listdir(utils.BENCHMARKS_DIR):
        project = utils.get_config_value(benchmark, 'project')
        fuzz_target = utils.get_config_value(benchmark, 'fuzz_target')

        corpus_path = get_input_corpus(benchmark)
        input_corpus = os.path.join(corpus_path, 'seeds')
        dictionary_path = os.path.join(corpus_path, 'fuzz-target.dict')
        if not os.path.exists(dictionary_path):
            dictionary_path = None

        output_corpus = os.path.join(output_base, project, fuzz_timestamp)
        os.makedirs(output_corpus)

        target_binary = os.path.join(source_base, "{}-target".format(tested_fuzzer), project, fuzz_target)

        print('Fuzz {project}: {fuzz_target} with fuzzer {fuzzer}'.format(
            project=project, fuzz_target=fuzz_target, fuzzer=tested_fuzzer))

        pool.apply_async(fuzzer.fuzz, (afl_path, input_corpus,
                         output_corpus, target_binary, dictionary_path, '6h'))

    pool.close()
    pool.join()
