/*
 *  Copyright 2021 NVIDIA Corporation
 *
 *  Licensed under the Apache License, Version 2.0 with the LLVM exception
 *  (the "License"); you may not use this file except in compliance with
 *  the License.
 *
 *  You may obtain a copy of the License at
 *
 *      http://llvm.org/foundation/relicensing/LICENSE.txt
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#include <nvbench/nvbench.cuh>

// Grab some testing kernels from NVBench:
#include <nvbench/test_kernels.cuh>

unsigned int seconds; // Global variable; will be set with command-line
                       // argument.

//==============================================================================
// `sleep bench` calls a simple sleep kernel.
//
// This is example demonstrates how to parse additional arguments. `seconds`
// (defined above) is a global variable that will be set with a command-line
// argument and passed to the sleep kernel. The main function parses that
// argument before passing the remaining arguments to NVBench. This is a simple
// example that could also be accomplished with a parameter axis, but the method
// generalizes to arguments not representable by parameter axes (filenames for
// example).
// Usage: ./nvbench.example.additional_arguments <unsigned int seconds>
// [additional NVBench arguments]
void sleep_bench(nvbench::state &state)
{
  // This is a contrived example that focuses on additional arguments, so this
  // is just a sleep kernel:
  state.exec([](nvbench::launch &launch) {
    nvbench::sleep_kernel<<<1, 1, 0, launch.get_stream()>>>((double)seconds);
  });
}

int main(int argc, char **argv)
{
  // Make sure we have enough arguments.
  if (argc < 2)
  {
    std::cout << "Usage: ./nvbench.example.additional_arguments <unsigned int "
                 "seconds> [additional NVBench arguments]\n";
    std::exit(0);
  }

  // Parse seconds.
  // Check that argv[1] is a positive int.
  char *string_portion;
  long int_portion = strtol(argv[1], &string_portion, 10);
  if (!string_portion[0] && int_portion >= 0)
  {
    seconds = atoi(argv[1]);
    std::cout << "seconds " << seconds << "\n";
  }
  else
  {
    std::cout << "Usage: ./nvbench.example.additional_arguments <unsigned int "
                 "seconds> [additional NVBench arguments]\n";
    std::exit(0);
  }

  // Create a new argument array without seconds (argv[1]) to pass to NVBench.
  char **args = new char *[argc];
  args[0]     = argv[0];
  for (int i = 2; i < argc; i++)
  {
    args[i - 1] = argv[i];
  }
  args[argc - 1] = NULL;

  NVBENCH_BENCH(sleep_bench);
  NVBENCH_MAIN_BODY(argc - 1, args);

  delete[] args;
}
