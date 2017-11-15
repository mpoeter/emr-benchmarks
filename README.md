# Efficient Memory Reclamation Benchmarks
This repository contains the results for the benchmarks
implemented in https://github.com/mpoeter/emr

These benchmarks were implemented and analyzed as part of my Master's
Thesis. They were run on four different architectures:

##### AMD
* CPUs: 4x AMD Opteron(tm) Processor 6168
* Frequency: max. 1.90GHz
* Cores/CPU: 12
* SMT: -
* Hardware Threads: 48
* Memory: 128GB
* OS: Linux 4.7.0-1-amd64 #1 SMP Debian 4.7.6-1 (2016-10-07) x86_64 GNU/Linux
* Compiler: gcc version 6.3.0 20170205 (Debian 6.3.0-6)

#### Intel
* CPUs: 8x Intel(R) Xeon(R) CPU E7- 8850
* Frequency: max. 2.00GHz
* Cores/CPU: 10
* SMT: 2x
* Hardware Threads: 160
* Memory: 1TB
* OS: Linux 4.7.0-1-amd64 #1 SMP Debian 4.7.6-1 (2016-10-07) x86_64 GNU/Linux
* Compiler: icpc version 17.0.1 (gcc version 6.0.0 compatibility)

##### XeonPhi
* CPUs: 1x Intel(R) Xeon Phi(TM) coprocessor x100 family
* Frequency: max. 1.33GHz
* Cores/CPU: 61
* SMT: 4x
* Hardware Threads: 244
* Memory: 16GB
* OS: Linux 2.6.38.8+mpss3.8.1 \#1 SMP Thu Jan 12 16:10:30 EST 2017 k1om GNU/Linux
* Compiler: icpc version 17.0.1 (gcc version 5.1.1 compatibility)

##### SPARC
* CPUs: 4x SPARC-T5-4
* Frequency: max. 3.60GHz
* Cores/CPU: 16
* SMT: 8x
* Hardware Threads: 512
* Memory: 1TB
* OS: SunOS 5.11 11.3 sun4v sparc sun4v
* Compiler: gcc version 6.3.0 (GCC)