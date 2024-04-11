# google-cloud-cpp-bigquery
Precompiled Google Cloud bigquery C++ library, [googleapis/google-cloud-cpp](https://github.com/googleapis/google-cloud-cpp), for Linux, macOS, and Windows.

Compiled with:

| Package           | Version |
|-------------------|---------|
| [abseil/abseil-cpp](https://github.com/abseil/abseil-cpp) | lts_2024_01_16 |
| [nlohmann/json](https://github.com/nlohmann/json) | 3.11.3 |
| libcurl | Latest<sup>1</sup> |
| [grpc/grpc](https://github.com/grpc/grpc) | v1.62.1 |
| [openssl](https://openssl.org) | 3.2.1<sup>2</sup> |
| [apache/arrow](https://github.com/apache/arrow) | 15.0.2 |

##### Notes:
*1. We're using libcurl 8.7.1_7 on Windows, and latest version on homebrew (for macOS) and APT (for Linux)*

*2: For Windows we're using precompiled OpenSSL binaries from [cocoa-xu/openssl-build](https://github.com/cocoa-xu/openssl-build).*

### Availability

| OS                | Arch           | ABI    |
|-------------------|----------------|--------|
| Linux             | x86_64         | gnu    |
| Linux             | aarch64        | gnu    |
| macOS 12 Monterey | x86_64         | darwin |
| macOS 14 Sonoma   | aarch64        | darwin |
| Windows 2019      | x86_64         | msvc   |
