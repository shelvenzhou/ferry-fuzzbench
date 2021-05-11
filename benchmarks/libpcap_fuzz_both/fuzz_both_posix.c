#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>

#include <pcap/pcap.h>

FILE * outfile = NULL;

static int bufferToFile(const char * name, const uint8_t *Data, size_t Size) {
    FILE * fd;
    if (remove(name) != 0) {
        if (errno != ENOENT) {
            printf("failed remove, errno=%d\n", errno);
            return -1;
        }
    }
    fd = fopen(name, "wb");
    if (fd == NULL) {
        printf("failed open, errno=%d\n", errno);
        return -2;
    }
    if (fwrite (Data, 1, Size, fd) != Size) {
        fclose(fd);
        return -3;
    }
    fclose(fd);
    return 0;
}

void fuzz_openFile(const char * name) {
    if (outfile != NULL) {
        fclose(outfile);
    }
    outfile = fopen(name, "w");
}

int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
    pcap_t * pkts;
    char errbuf[PCAP_ERRBUF_SIZE];
    const u_char *pkt;
    struct pcap_pkthdr *header;
    int r;
    size_t filterSize;
    char * filter;
    struct bpf_program bpf;


    //initialize output file
    if (outfile == NULL) {
        outfile = fopen("/dev/null", "w");
        if (outfile == NULL) {
            return 0;
        }
    }

    if (Size < 1) {
        return 0;
    }
    filterSize = Data[0];
    if (Size < 1+filterSize || filterSize == 0) {
        return 0;
    }

    //rewrite buffer to a file as libpcap does not have buffer inputs
    if (bufferToFile("/tmp/fuzz.pcap", Data+1+filterSize, Size-(1+filterSize)) < 0) {
        return 0;
    }

    //initialize structure
    pkts = pcap_open_offline("/tmp/fuzz.pcap", errbuf);
    if (pkts == NULL) {
        fprintf(outfile, "Couldn't open pcap file %s\n", errbuf);
        return 0;
    }

    filter = malloc(filterSize);
    memcpy(filter, Data+1, filterSize);
    //null terminate string
    filter[filterSize-1] = 0;

    if (pcap_compile(pkts, &bpf, filter, 1, PCAP_NETMASK_UNKNOWN) == 0) {
        //loop over packets
        r = pcap_next_ex(pkts, &header, &pkt);
        while (r > 0) {
            //checks filter
            fprintf(outfile, "packet length=%d/%d filter=%d\n",header->caplen, header->len, pcap_offline_filter(&bpf, header, pkt));
            r = pcap_next_ex(pkts, &header, &pkt);
        }
        //close structure
        pcap_close(pkts);
        pcap_freecode(&bpf);
    }
    else {
        pcap_close(pkts);
    }
    free(filter);

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
