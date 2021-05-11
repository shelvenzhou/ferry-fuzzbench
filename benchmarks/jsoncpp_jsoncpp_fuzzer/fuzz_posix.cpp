// Copyright 2007-2019 The JsonCpp Authors
// Distributed under MIT license, or public domain if desired and
// recognized in your jurisdiction.
// See file LICENSE for detail or copy at http://jsoncpp.sourceforge.net/LICENSE

#include "fuzz.h"

#include <iostream>
#include <iterator>
#include <fstream>
#include <assert.h>
#include <cstdint>
#include <json/config.h>
#include <json/json.h>
#include <memory>
#include <string>

namespace Json {
class Exception;
}

int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
// extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
  Json::CharReaderBuilder builder;

  if (size < sizeof(uint32_t)) {
    return 0;
  }

  const uint32_t hash_settings = static_cast<uint32_t>(data[0]) |
                                 (static_cast<uint32_t>(data[1]) << 8) |
                                 (static_cast<uint32_t>(data[2]) << 16) |
                                 (static_cast<uint32_t>(data[3]) << 24);
  data += sizeof(uint32_t);
  size -= sizeof(uint32_t);

  builder.settings_["failIfExtra"] = hash_settings & (1 << 0);
  builder.settings_["allowComments_"] = hash_settings & (1 << 1);
  builder.settings_["strictRoot_"] = hash_settings & (1 << 2);
  builder.settings_["allowDroppedNullPlaceholders_"] = hash_settings & (1 << 3);
  builder.settings_["allowNumericKeys_"] = hash_settings & (1 << 4);
  builder.settings_["allowSingleQuotes_"] = hash_settings & (1 << 5);
  builder.settings_["failIfExtra_"] = hash_settings & (1 << 6);
  builder.settings_["rejectDupKeys_"] = hash_settings & (1 << 7);
  builder.settings_["allowSpecialFloats_"] = hash_settings & (1 << 8);
  builder.settings_["collectComments"] = hash_settings & (1 << 9);
  builder.settings_["allowTrailingCommas_"] = hash_settings & (1 << 10);

  std::unique_ptr<Json::CharReader> reader(builder.newCharReader());

  Json::Value root;
  const auto data_str = reinterpret_cast<const char*>(data);
  try {
    reader->parse(data_str, data_str + size, &root, nullptr);
  } catch (Json::Exception const&) {
  }
  // Whether it succeeded or not doesn't matter.
  return 0;
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    std::fprintf(stdout, "usage: %s filepath\n", argv[0]);
    return -1;
  }

  std::FILE *file = std::fopen(argv[1], "rb");
  if (!file) {
    std::fprintf(stdout, "%s not found\n", argv[1]);
    return -1;
  }

  uint8_t *data = NULL;
  int filesize = 0;
  size_t size = 0;

  // get the real size of file
  std::fseek (file , 0 , SEEK_END);
  filesize = std::ftell(file);
  std::rewind(file);

  data = new uint8_t[filesize];
  if (!data) {
    std::fprintf(stdout, "out of memory");
    std::fclose(file);
    return -1;
  }

  size = std::fread(data, sizeof(data[0]), filesize, file);
  LLVMFuzzerTestOneInput(data, size);
  std::fclose(file);
  delete[] data;
  return 0;
}
