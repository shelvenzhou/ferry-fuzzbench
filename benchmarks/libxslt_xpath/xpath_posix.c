/*
 * xpath.c: libFuzzer target for XPath expressions
 *
 * See Copyright for the status of this software.
 */

#include <fcntl.h>

#include "fuzz.h"

int
LLVMFuzzerInitialize(int *argc_p, char ***argv_p) {
    return xsltFuzzXPathInit(argc_p, argv_p, NULL);
}

int
LLVMFuzzerTestOneInput(const char *data, size_t size) {
    xmlXPathObjectPtr xpathObj = xsltFuzzXPath(data, size);
    xsltFuzzXPathFreeObject(xpathObj);

    return 0;
}

int main(int argc, char** argv)
{
    FILE * fp;
    uint8_t *Data;
    size_t Size;

    if (argc != 2) {
        return 1;
    }
    //opens the file, get its size, and reads it into a buffer
    fp = fopen(argv[1], "rb");
    if (fp == NULL) {
        return 2;
    }
    if (fseek(fp, 0L, SEEK_END) != 0) {
        fclose(fp);
        return 2;
    }
    Size = ftell(fp);
    if (Size == (size_t) -1) {
        fclose(fp);
        return 2;
    }
    if (fseek(fp, 0L, SEEK_SET) != 0) {
        fclose(fp);
        return 2;
    }
    Data = malloc(Size);
    if (Data == NULL) {
        fclose(fp);
        return 2;
    }
    if (fread(Data, Size, 1, fp) != 1) {
        fclose(fp);
        free(Data);
        return 2;
    }

    //launch fuzzer
    LLVMFuzzerTestOneInput(Data, Size);
    free(Data);
    fclose(fp);
    return 0;
}
