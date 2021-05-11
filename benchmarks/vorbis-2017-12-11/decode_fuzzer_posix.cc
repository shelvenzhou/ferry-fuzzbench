#include <iostream>
#include <iterator>
#include <fstream>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <cstdint>
#include <vorbis/vorbisfile.h>

struct vorbis_data {
  const uint8_t *current;
  const uint8_t *data;
  size_t size;
};

size_t read_func(void *ptr, size_t size1, size_t size2, void *datasource) {
  vorbis_data* vd = (vorbis_data *)(datasource);
  size_t len = size1 * size2;
  if (vd->current + len > vd->data + vd->size) {
      len = vd->data + vd->size - vd->current;
  }
  memcpy(ptr, vd->current, len);
  vd->current += len;
  return len;
}


int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
// extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
  ov_callbacks memory_callbacks = {0};
  memory_callbacks.read_func = read_func;
  vorbis_data data_st;
  data_st.size = Size;
  data_st.current = Data;
  data_st.data = Data;
  OggVorbis_File vf;
  int result = ov_open_callbacks(&data_st, &vf, NULL, 0, memory_callbacks);
  if (result < 0) {
    return 0;
  }
  int current_section = 0;
  int eof = 0;
  char buf[4096];
  int read_result;
  while (!eof) {
    read_result = ov_read(&vf, buf, sizeof(buf), 0, 2, 1, &current_section);
    if (read_result != OV_HOLE && read_result <= 0) {
      eof = 1;
    }
  }
  ov_clear(&vf);
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
