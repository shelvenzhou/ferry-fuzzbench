#include <iostream>
#include <iterator>
#include <fstream>
#include <assert.h>
#include <stddef.h>
#include <hb.h>
#include <hb-ot.h>
#include <string.h>

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
// extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {

  hb_blob_t *blob = hb_blob_create((const char *)data, size,
                                   HB_MEMORY_MODE_READONLY, NULL, NULL);
  hb_face_t *face = hb_face_create(blob, 0);
  hb_font_t *font = hb_font_create(face);
  hb_ot_font_set_funcs(font);
  hb_font_set_scale(font, 12, 12);

  {
    const char text[] = "ABCDEXYZ123@_%&)*$!";
    hb_buffer_t *buffer = hb_buffer_create();
    hb_buffer_add_utf8(buffer, text, -1, 0, -1);
    hb_buffer_guess_segment_properties(buffer);
    hb_shape(font, buffer, NULL, 0);
    hb_buffer_destroy(buffer);
  }

  uint32_t text32[16];
  if (size > sizeof(text32)) {
    memcpy(text32, data + size - sizeof(text32), sizeof(text32));
    hb_buffer_t *buffer = hb_buffer_create();
    hb_buffer_add_utf32(buffer, text32, sizeof(text32)/sizeof(text32[0]), 0, -1);
    hb_buffer_guess_segment_properties(buffer);
    hb_shape(font, buffer, NULL, 0);
    hb_buffer_destroy(buffer);
  }


  hb_font_destroy(font);
  hb_face_destroy(face);
  hb_blob_destroy(blob);
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
