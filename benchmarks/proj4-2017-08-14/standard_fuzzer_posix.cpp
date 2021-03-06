/******************************************************************************
 *
 * Project:  proj.4
 * Purpose:  Fuzzer
 * Author:   Even Rouault, even.rouault at spatialys.com
 *
 ******************************************************************************
 * Copyright (c) 2017, Even Rouault <even.rouault at spatialys.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ****************************************************************************/

#include <iostream>
#include <iterator>
#include <fstream>
#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

#include "projects.h" // For pj_gc_unloadall()
#include "proj_api.h"

/* Standalone build:
g++ -g -std=c++11 standard_fuzzer.cpp -o standard_fuzzer -DSTANDALONE ../../src/.libs/libproj.a -lpthread
*/

// extern "C" int LLVMFuzzerInitialize(int* argc, char*** argv);
// extern "C" int LLVMFuzzerTestOneInput(const uint8_t *buf, size_t len);

int LLVMFuzzerInitialize(int* /*argc*/, char*** argv)
{
    const char* argv0 = (*argv)[0];
    char* path = strdup(argv0);
    char* lastslash = strrchr(path, '/');
    if( lastslash )
    {
        *lastslash = '\0';
        setenv("PROJ_LIB", path, 1);
    }
    else
    {
        setenv("PROJ_LIB", ".", 1);
    }
    free(path);
    return 0;
}

int LLVMFuzzerTestOneInput(const uint8_t *buf, size_t len)
{
    /* We expect the blob to be 3 lines: */
    /* source proj string\ndestination proj string\nx y */
    char* buf_dup = (char*)malloc(len+1);
    memcpy(buf_dup, buf, len);
    buf_dup[len] = 0;
    char* first_line = buf_dup;
    char* first_newline = strchr(first_line, '\n');
    if( !first_newline )
    {
        free(buf_dup);
        return 0;
    }
    first_newline[0] = 0;
    char* second_line = first_newline + 1;
    char* second_newline = strchr(second_line, '\n');
    if( !second_newline )
    {
        free(buf_dup);
        return 0;
    }
    second_newline[0] = 0;
    char* third_line = second_newline + 1;
    projPJ pj_src = pj_init_plus(first_line);
    if( !pj_src )
    {
        free(buf_dup);
        return 0;
    }
    projPJ pj_dst = pj_init_plus(second_line);
    if( !pj_dst )
    {
        free(buf_dup);
        pj_free(pj_src);
        pj_gc_unloadall(pj_get_default_ctx());
        pj_deallocate_grids();
        return 0;
    }
    double x = 0, y = 0, z = 9;
    bool from_binary = false;
    bool has_z = false;
    if( strncmp(third_line, "BINARY_2D:", strlen("BINARY_2D:")) == 0 &&
        third_line - first_line + strlen("BINARY_2D:") + 2 * sizeof(double) <= len )
    {
        from_binary = true;
        memcpy(&x, third_line + strlen("BINARY_2D:"), sizeof(double));
        memcpy(&y, third_line + strlen("BINARY_2D:") + sizeof(double), sizeof(double));
    }
    else if( strncmp(third_line, "BINARY_3D:", strlen("BINARY_3D:")) == 0 &&
             third_line - first_line + strlen("BINARY_3D:") + 3 * sizeof(double) <= len )
    {
        from_binary = true;
        has_z = true;
        memcpy(&x, third_line + strlen("BINARY_3D:"), sizeof(double));
        memcpy(&y, third_line + strlen("BINARY_3D:") + sizeof(double), sizeof(double));
        memcpy(&z, third_line + strlen("BINARY_3D:") + 2 * sizeof(double), sizeof(double));
    }
    else if( sscanf(third_line, "%lf %lf", &x, &y) != 2 )
    {
        free(buf_dup);
        pj_free(pj_src);
        pj_free(pj_dst);
        pj_gc_unloadall(pj_get_default_ctx());
        pj_deallocate_grids();
        return 0;
    }
#ifdef STANDALONE
    fprintf(stderr, "src=%s\n", first_line);
    fprintf(stderr, "dst=%s\n", second_line);
    if( from_binary )
    {
        if( has_z )
            fprintf(stderr, "coord (from binary)=%.18g %.18g %.18g\n", x, y, z);
        else
            fprintf(stderr, "coord (from binary)=%.18g %.18g\n", x, y);
    }
    else
        fprintf(stderr, "coord=%s\n", third_line);
#endif
    if( has_z )
        pj_transform( pj_src, pj_dst, 1, 0, &x, &y, &z );
    else
        pj_transform( pj_src, pj_dst, 1, 0, &x, &y, NULL );
    free(buf_dup);
    pj_free(pj_src);
    pj_free(pj_dst);
    pj_gc_unloadall(pj_get_default_ctx());
    pj_deallocate_grids();
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
