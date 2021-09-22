#!/bin/bash -ex

OUTPUT_PATH=/home/ferry/Documents/ferry-fuzzbench/outputs/AFL-2021-06-06T19:39:00.165207
TARGET_PATH=/home/ferry/Documents/ferry-fuzzbench/benchmarks/GCOV-target
SOURCE_PATH=/home/ferry/Documents/ferry-fuzzbench/benchmarks/GCOV-source

# OUTPUT_PATH=/home/ferry/Documents/ferry-fuzzbench/outputs/QSYM-without-dict
# TARGET_PATH=/home/ferry/Documents/ferry-fuzzbench/benchmarks/GCOV2-target
# SOURCE_PATH=/home/ferry/Documents/ferry-fuzzbench/benchmarks/GCOV2-source

# OUTPUT_PATH=/home/ferry/Documents/ferry-fuzzbench/outputs/Angora
# TARGET_PATH=/home/ferry/Documents/ferry-fuzzbench/benchmarks/GCOV1-target
# SOURCE_PATH=/home/ferry/Documents/ferry-fuzzbench/benchmarks/GCOV1-source

find $SOURCE_PATH -name "*.gcda" | xargs rm
find $SOURCE_PATH -name "*.gcov" | xargs rm

find $OUTPUT_PATH/bloaty/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/bloaty/fuzz_target
find $OUTPUT_PATH/freetype2/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/freetype2/ftfuzzer
find $OUTPUT_PATH/harfbuzz/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/harfbuzz/hb-shape-fuzzer
find $OUTPUT_PATH/jsoncpp/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/jsoncpp/jsoncpp_fuzzer
find $OUTPUT_PATH/lcms/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/lcms/cms_transform_fuzzer
find $OUTPUT_PATH/libjpeg-turbo/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/libjpeg-turbo/libjpeg_turbo_fuzzer
find $OUTPUT_PATH/libpcap/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/libpcap/fuzz_both
find $OUTPUT_PATH/libpng/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/libpng/libpng_read_fuzzer
find $OUTPUT_PATH/libxml2/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/libxml2/xml
find $OUTPUT_PATH/mbedtls/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/mbedtls/fuzz_dtlsclient
find $OUTPUT_PATH/openthread/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/openthread/ip6-send-fuzzer
find $OUTPUT_PATH/proj4/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/proj4/standard_fuzzer
find $OUTPUT_PATH/re2/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/re2/fuzzer
find $OUTPUT_PATH/vorbis/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/vorbis/decode_fuzzer
find $OUTPUT_PATH/woff2/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/woff2/convert_woff2ttf_fuzzer
find $OUTPUT_PATH/zlib/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/zlib/zlib_uncompress_fuzzer

find $OUTPUT_PATH/bloaty/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/bloaty/fuzz_target
find $OUTPUT_PATH/freetype2/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/freetype2/ftfuzzer
find $OUTPUT_PATH/harfbuzz/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/harfbuzz/hb-shape-fuzzer
find $OUTPUT_PATH/jsoncpp/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/jsoncpp/jsoncpp_fuzzer
find $OUTPUT_PATH/lcms/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/lcms/cms_transform_fuzzer
find $OUTPUT_PATH/libjpeg-turbo/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/libjpeg-turbo/libjpeg_turbo_fuzzer
find $OUTPUT_PATH/libpcap/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/libpcap/fuzz_both
find $OUTPUT_PATH/libpng/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/libpng/libpng_read_fuzzer
find $OUTPUT_PATH/libxml2/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/libxml2/xml
find $OUTPUT_PATH/mbedtls/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/mbedtls/fuzz_dtlsclient
find $OUTPUT_PATH/openthread/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/openthread/ip6-send-fuzzer
find $OUTPUT_PATH/proj4/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/proj4/standard_fuzzer
find $OUTPUT_PATH/re2/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/re2/fuzzer
find $OUTPUT_PATH/vorbis/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/vorbis/decode_fuzzer
find $OUTPUT_PATH/woff2/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/woff2/convert_woff2ttf_fuzzer
find $OUTPUT_PATH/zlib/*/queue -name 'id:*' | timeout -s INT 5s xargs -n1 $TARGET_PATH/zlib/zlib_uncompress_fuzzer
