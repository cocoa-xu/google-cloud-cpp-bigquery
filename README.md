# google-cloud-cpp-bigquery
Precompiled Google Cloud bigquery C++ library.

Compiled with:

- [abseil/abseil-cpp](https://github.com/abseil/abseil-cpp), lts_2024_01_16
- [grpc/grpc](https://github.com/grpc/grpc), v1.62.1
- [openssl](https://openssl.org), 3.2.1; precompiled version from [cocoa-xu/openssl](https://github.com/cocoa-xu/openssl-build) is used for Windows.
- [googleapis/google-cloud-cpp](https://github.com/googleapis/google-cloud-cpp), v2.22.0

### Availability

| OS                | Arch           | ABI    |
|-------------------|----------------|--------|
| Linux             | x86_64         | gnu    |
| Linux             | aarch64        | gnu    |
| macOS 12 Monterey | x86_64         | darwin |
| macOS 14 Sonoma   | aarch64        | darwin |
| Windows 2019      | x86_64         | msvc   |
