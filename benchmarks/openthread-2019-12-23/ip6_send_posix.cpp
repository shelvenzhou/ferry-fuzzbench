/*
 *  Copyright (c) 2017, The OpenThread Authors.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. Neither the name of the copyright holder nor the
 *     names of its contributors may be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 */

#define MAX_ITERATIONS 100

#include <iostream>
#include <iterator>
#include <fstream>
#include <assert.h>
#include <stddef.h>

#include <openthread/instance.h>
#include <openthread/ip6.h>
#include <openthread/link.h>
#include <openthread/message.h>
#include <openthread/tasklet.h>
#include <openthread/thread.h>
#include <openthread/thread_ftd.h>

#include "fuzzer_platform.h"
#include "common/code_utils.hpp"

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
// extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
    const otPanId panId = 0xdead;

    otInstance *      instance = NULL;
    otMessage *       message  = NULL;
    otError           error    = OT_ERROR_NONE;
    otMessageSettings settings;

    VerifyOrExit(size > 0);

    FuzzerPlatformInit();

    instance = otInstanceInitSingle();
    otLinkSetPanId(instance, panId);
    otIp6SetEnabled(instance, true);
    otThreadSetEnabled(instance, true);
    otThreadBecomeLeader(instance);

    settings.mLinkSecurityEnabled = (data[0] & 0x1) != 0;
    settings.mPriority            = OT_MESSAGE_PRIORITY_NORMAL;

    message = otIp6NewMessage(instance, &settings);
    VerifyOrExit(message != NULL, error = OT_ERROR_NO_BUFS);

    error = otMessageAppend(message, data + 1, static_cast<uint16_t>(size - 1));
    SuccessOrExit(error);

    error = otIp6Send(instance, message);

    message = NULL;

    VerifyOrExit(!FuzzerPlatformResetWasRequested());

    for (int i = 0; i < MAX_ITERATIONS; i++)
    {
        while (otTaskletsArePending(instance))
        {
            otTaskletsProcess(instance);
        }

        FuzzerPlatformProcess(instance);
    }

exit:

    if (message != NULL)
    {
        otMessageFree(message);
    }

    if (instance != NULL)
    {
        otInstanceFinalize(instance);
    }

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
