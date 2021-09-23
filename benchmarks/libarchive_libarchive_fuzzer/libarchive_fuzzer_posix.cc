// Copyright 2016 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
#include <stddef.h>
#include <stdint.h>
#include <fstream>
#include <vector>

#include "archive.h"

struct Buffer {
  const uint8_t *buf;
  size_t len;
};

ssize_t reader_callback(struct archive *a, void *client_data,
                        const void **block) {
  Buffer *buffer = reinterpret_cast<Buffer *>(client_data);
  *block = buffer->buf;
  ssize_t len = buffer->len;
  buffer->len = 0;
  return len;
}

// extern "C" int LLVMFuzzerTestOneInput(const uint8_t *buf, size_t len) {
int LLVMFuzzerTestOneInput(const uint8_t *buf, size_t len) {
  ssize_t r;
  struct archive *a = archive_read_new();

  archive_read_support_filter_all(a);
  archive_read_support_format_all(a);

  Buffer buffer = {buf, len};
  archive_read_open(a, &buffer, NULL, reader_callback, NULL);

  std::vector<uint8_t> data_buffer(getpagesize(), 0);
  struct archive_entry *entry;
  while (archive_read_next_header(a, &entry) == ARCHIVE_OK) {
    while ((r = archive_read_data(a, data_buffer.data(),
            data_buffer.size())) > 0)
      ;
    if (r == ARCHIVE_FATAL)
      break;
  }

  archive_read_free(a);
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
