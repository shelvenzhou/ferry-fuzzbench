// Copyright 2020 Google LLC
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

#include <iostream>
#include <iterator>
#include <fstream>
#include <assert.h>
#include <string>
#include <vector>
#include "libxml/xmlversion.h"
#include "libxml/parser.h"
#include "libxml/HTMLparser.h"
#include "libxml/tree.h"

void ignore (void * ctx, const char * msg, ...) {}

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
// extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
  xmlSetGenericErrorFunc(NULL, &ignore);
  if (auto doc = xmlReadMemory(reinterpret_cast<const char *>(data), size,
                               "noname.xml", NULL, 0))
    xmlFreeDoc(doc);
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
