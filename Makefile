ABSEIL_CPP_VERSION = lts_2024_01_16
NLOHMANN_JSON_VERSION = 3.11.3
GRPC_VERSION = v1.62.1
OPENSSL_VERSION = 3.2.1
GOOGLE_CLOUD_CPP_VERSION = v2.22.0
APACHE_ARROW_VERSION = 15.0.2

BUILD_DIR ?= $(shell pwd)/build
INSTALL_PREFIX ?= $(shell pwd)/install
CMAKE_CXX_STANDARD ?= 17

ifndef NPROC
UNAME_S = $(shell uname -s)
ifneq ($(UNAME_S),Darwin)
NPROC = $(shell sysctl -n hw.ncpu)
else
NPROC = $(shell nproc)
endif
endif

CMAKE_COMMON_FLAGS=-D CMAKE_CXX_STANDARD=$(CMAKE_CXX_STANDARD) -D CMAKE_POSITION_INDEPENDENT_CODE=ON
ifdef CMAKE_TOOLCHAIN_FILE
	CMAKE_CONFIGURE_FLAGS=$(CMAKE_COMMON_FLAGS) -D CMAKE_TOOLCHAIN_FILE="$(CMAKE_TOOLCHAIN_FILE)"
else
	CMAKE_CONFIGURE_FLAGS=$(CMAKE_COMMON_FLAGS)
endif

THRID_PARTY_DIR = $(shell pwd)/third_party

ABSEIL_CPP_GIT_REPO = https://github.com/abseil/abseil-cpp.git
ABSEIL_CPP_SRC_DIR = $(THRID_PARTY_DIR)/abseil-cpp
ABSEIL_CPP_BUILD_DIR = $(BUILD_DIR)/abseil-cpp
ABSEIL_CPP_CONFIG_CMAKE = $(INSTALL_PREFIX)/lib/cmake/absl/abslConfig.cmake

NLOHMANN_JSON_BASE_URL = https://github.com/nlohmann/json/releases/download
NLOHMANN_JSON_TARBALL_URL = $(NLOHMANN_JSON_BASE_URL)/v$(NLOHMANN_JSON_VERSION)/json.tar.xz
NLOHMANN_JSON_TARBALL = $(THRID_PARTY_DIR)/nlohmann-json-$(NLOHMANN_JSON_VERSION).tar.xz
NLOHMANN_JSON_SRC_DIR = $(THRID_PARTY_DIR)/nlohmann-json-$(NLOHMANN_JSON_VERSION)
NLOHMANN_JSON_BUILD_DIR = $(BUILD_DIR)/nlohmann_json
NLOHMANN_JSON_CONFIG_CMAKE = $(INSTALL_PREFIX)/share/cmake/nlohmann_json/nlohmann_jsonConfig.cmake

GRPC_GIT_REPO = https://github.com/grpc/grpc.git
GRPC_SRC_DIR = $(THRID_PARTY_DIR)/grpc
GRPC_BUILD_DIR = $(BUILD_DIR)/grpc
GRPC_CONFIG_CMAKE = $(INSTALL_PREFIX)/lib/cmake/grpc/gRPCConfig.cmake

OPENSSL_TARBALL = $(THRID_PARTY_DIR)/openssl-$(OPENSSL_VERSION).tar.gz
OPENSSL_SRC_DIR = $(THRID_PARTY_DIR)/openssl-$(OPENSSL_VERSION)
OPENSSL_INSTALL_PREFIX = $(INSTALL_PREFIX)/openssl

GOOGLE_CLOUD_CPP_GIT_REPO = https://github.com/googleapis/google-cloud-cpp.git
GOOGLE_CLOUD_CPP_SRC_DIR = $(THRID_PARTY_DIR)/google-cloud-cpp
GOOGLE_CLOUD_CPP_BUILD_DIR = $(BUILD_DIR)/google-cloud-cpp
GOOGLE_CLOUD_CPP_BIGQUERY_CONFIG_CMAKE = $(INSTALL_PREFIX)/lib/cmake/google_cloud_cpp_bigquery/google_cloud_cpp_bigquery-config.cmake

APACHE_ARROW_TARBALL_NAME = apache-arrow-$(APACHE_ARROW_VERSION)
APACHE_ARROW_URL = https://github.com/apache/arrow/archive/refs/tags/$(APACHE_ARROW_TARBALL_NAME).tar.gz
APACHE_ARROW_TARBALL = $(THRID_PARTY_DIR)/$(APACHE_ARROW_TARBALL_NAME).tar.gz
APACHE_ARROW_SRC_DIR = $(THRID_PARTY_DIR)/$(APACHE_ARROW_TARBALL_NAME)
APACHE_ARROW_CPP_SRC_DIR = $(APACHE_ARROW_SRC_DIR)/cpp
APACHE_ARROW_BUILD_DIR = $(BUILD_DIR)/apache_arrow
APACHE_ARROW_CONFIG_CMAKE = $(INSTALL_PREFIX)/lib/cmake/Arrow/ArrowConfig.cmake

build: nproc show-versions $(THRID_PARTY_DIR) $(INSTALL_PREFIX)  build-deps
	@ echo "Build done"

nproc:
	@ echo "Parallel Jobs: $(NPROC)"

show-versions:
	@ echo "ABSEIL_CPP_VERSION: $(ABSEIL_CPP_VERSION)"
	@ echo "NLOHMANN_JSON_VERSION: $(NLOHMANN_JSON_VERSION)"
	@ echo "GRPC_VERSION: $(GRPC_VERSION)"
	@ echo "OPENSSL_VERSION: $(OPENSSL_VERSION)"
	@ echo "GOOGLE_CLOUD_CPP_VERSION: $(GOOGLE_CLOUD_CPP_VERSION)"
	@ echo "APACHE_ARROW_VERSION: $(APACHE_ARROW_VERSION)"

$(THRID_PARTY_DIR):
	@ mkdir -p "$(THRID_PARTY_DIR)"

$(INSTALL_PREFIX):
	@ mkdir -p "$(INSTALL_PREFIX)"

build-deps: $(ABSEIL_CPP_CONFIG_CMAKE) $(NLOHMANN_JSON_CONFIG_CMAKE) $(GRPC_CONFIG_CMAKE) install-openssl $(GOOGLE_CLOUD_CPP_BIGQUERY_CONFIG_CMAKE) $(APACHE_ARROW_CONFIG_CMAKE)
	@ echo > /dev/null

fetch-abseil-cpp:
	@ if [ ! -d "$(ABSEIL_CPP_SRC_DIR)" ]; then \
		git clone --depth=1 --branch $(ABSEIL_CPP_VERSION) $(ABSEIL_CPP_GIT_REPO) "$(ABSEIL_CPP_SRC_DIR)" ; \
	fi

config-abseil-cpp: fetch-abseil-cpp
	@ if [ ! -f "$(ABSEIL_CPP_CONFIG_CMAKE)" ]; then \
		cd "$(ABSEIL_CPP_SRC_DIR)" && \
		cmake -S . -B "$(ABSEIL_CPP_BUILD_DIR)" \
			-D CMAKE_BUILD_TYPE=Release \
			-D CMAKE_INSTALL_PREFIX="$(INSTALL_PREFIX)" \
			$(CMAKE_CONFIGURE_FLAGS) \
			-D ABSL_PROPAGATE_CXX_STD=ON ; \
	fi

install-abseil-cpp: config-abseil-cpp
	@ if [ ! -f "$(ABSEIL_CPP_CONFIG_CMAKE)" ]; then \
		cmake --build "$(ABSEIL_CPP_BUILD_DIR)" --config Release --target install --parallel $(NPROC) ; \
	fi

$(ABSEIL_CPP_CONFIG_CMAKE): install-abseil-cpp
	@ echo > /dev/null

fetch-nlohmann-json:
	@ if [ ! -f "$(NLOHMANN_JSON_TARBALL)" ]; then \
		curl -fSL "$(NLOHMANN_JSON_TARBALL_URL)" -o "$(NLOHMANN_JSON_TARBALL)" ; \
	fi

unarchive-nlohmann-json: fetch-nlohmann-json
	@ if [ ! -d "$(NLOHMANN_JSON_SRC_DIR)" ]; then \
		mkdir -p "$(NLOHMANN_JSON_SRC_DIR)" && \
		tar -xJf "$(NLOHMANN_JSON_TARBALL)" -C "$(NLOHMANN_JSON_SRC_DIR)" --strip-components=1 ; \
	fi

config-nlohmann-json: unarchive-nlohmann-json
	@ if [ ! -d "$(NLOHMANN_JSON_BUILD_DIR)" ]; then \
		cmake -S "$(NLOHMANN_JSON_SRC_DIR)" -B "$(NLOHMANN_JSON_BUILD_DIR)" \
			-D CMAKE_BUILD_TYPE=Release \
			-D CMAKE_INSTALL_PREFIX="$(INSTALL_PREFIX)" \
			-D JSON_BuildTests=OFF \
			$(CMAKE_CONFIGURE_FLAGS) ; \
	fi

install-nlohmann-json: config-nlohmann-json
	@ if [ ! -f "$(NLOHMANN_JSON_CONFIG_CMAKE)" ]; then \
		cmake --build "$(NLOHMANN_JSON_BUILD_DIR)" --config Release --target install --parallel $(NPROC) ; \
	fi

$(NLOHMANN_JSON_CONFIG_CMAKE): install-nlohmann-json
	@ echo > /dev/null

fetch-grpc:
	@ if [ ! -d "$(GRPC_SRC_DIR)" ]; then \
		git clone $(GRPC_GIT_REPO) "$(GRPC_SRC_DIR)" ; \
	fi

config-grpc: fetch-grpc
	@ if [ ! -f "$(GRPC_CONFIG_CMAKE)" ]; then \
		cd "$(GRPC_SRC_DIR)" && \
		git submodule update --init && \
		cmake -S . -B "$(GRPC_BUILD_DIR)" \
			-D CMAKE_BUILD_TYPE=Release \
			-D CMAKE_INSTALL_PREFIX="$(INSTALL_PREFIX)" \
			$(CMAKE_CONFIGURE_FLAGS) \
			-D ABSL_PROPAGATE_CXX_STD=ON ; \
	fi

install-grpc: config-grpc
	@ if [ ! -f "$(GRPC_CONFIG_CMAKE)" ]; then \
		cmake --build "$(GRPC_BUILD_DIR)" --config Release --target install --parallel $(NPROC) ; \
	fi

$(GRPC_CONFIG_CMAKE): install-grpc
	@ echo > /dev/null

download-openssl:
	@ if [ ! -f "$(OPENSSL_TARBALL)" ]; then \
		curl -fSL "https://www.openssl.org/source/openssl-$(OPENSSL_VERSION).tar.gz" -o "$(OPENSSL_TARBALL)" ; \
	fi

unarchive-openssl: download-openssl
	@ if [ ! -d "$(OPENSSL_SRC_DIR)" ]; then \
		mkdir -p "$(OPENSSL_SRC_DIR)" && \
		tar -xzf "$(OPENSSL_TARBALL)" -C "$(OPENSSL_SRC_DIR)" --strip-components=1 ; \
	fi

install-openssl: unarchive-openssl
	@ if [ ! -f "$(OPENSSL_INSTALL_PREFIX)/include/openssl/opensslconf.h" ]; then \
		cd "$(OPENSSL_SRC_DIR)" && \
		./config --prefix="$(OPENSSL_INSTALL_PREFIX)" --openssldir="$(OPENSSL_INSTALL_PREFIX)" no-tests no-shared && \
		make -j$(NPROC) && \
		make -j$(NPROC) install_sw && \
		make -j$(NPROC) install_ssldirs ; \
	fi

fetch-google-cloud-cpp:
	@ if [ ! -d "$(GOOGLE_CLOUD_CPP_SRC_DIR)" ]; then \
		git clone --depth=1 --branch $(GOOGLE_CLOUD_CPP_VERSION) $(GOOGLE_CLOUD_CPP_GIT_REPO) "$(GOOGLE_CLOUD_CPP_SRC_DIR)" ; \
	fi

config-google-cloud-cpp: fetch-google-cloud-cpp
	@ if [ ! -f "$(GOOGLE_CLOUD_CPP_BIGQUERY_CONFIG_CMAKE)" ]; then \
		cd "$(GOOGLE_CLOUD_CPP_SRC_DIR)" && \
		cmake -S . -B "$(GOOGLE_CLOUD_CPP_BUILD_DIR)" \
			-D CMAKE_BUILD_TYPE=Release \
			-D CMAKE_INSTALL_PREFIX="$(INSTALL_PREFIX)" \
			$(CMAKE_CONFIGURE_FLAGS) \
			-D CMAKE_PREFIX_PATH="$(INSTALL_PREFIX)/lib/cmake" \
			-D OPENSSL_ROOT_DIR="$(INSTALL_PREFIX)/openssl" \
			-D BUILD_TESTING=OFF \
			-D GOOGLE_CLOUD_CPP_ENABLE_EXAMPLES=OFF \
			-D GOOGLE_CLOUD_CPP_ENABLE=bigquery,experimental-bigquery_rest ; \
	fi

install-google-cloud-cpp: config-google-cloud-cpp
	@ if [ ! -f "$(GOOGLE_CLOUD_CPP_BIGQUERY_CONFIG_CMAKE)" ]; then \
		cmake --build "$(GOOGLE_CLOUD_CPP_BUILD_DIR)" --config Release --target install --parallel $(NPROC) ; \
	fi

$(GOOGLE_CLOUD_CPP_BIGQUERY_CONFIG_CMAKE): install-google-cloud-cpp
	@ echo > /dev/null

fetch-apache-arrow:
	@ if [ ! -f "$(APACHE_ARROW_TARBALL)" ]; then \
		curl -fSL "$(APACHE_ARROW_URL)" -o "$(APACHE_ARROW_TARBALL)" ; \
	fi

unarchive-apache-arrow: fetch-apache-arrow
	@ if [ ! -d "$(APACHE_ARROW_SRC_DIR)" ]; then \
		mkdir -p "$(APACHE_ARROW_SRC_DIR)" && \
		tar -xzf "$(APACHE_ARROW_TARBALL)" -C "$(APACHE_ARROW_SRC_DIR)" --strip-components=1 ; \
	fi

config-apache-arrow: unarchive-apache-arrow
	@ if [ ! -d "$(APACHE_ARROW_BUILD_DIR)" ]; then \
		cmake -S "$(APACHE_ARROW_CPP_SRC_DIR)" -B "$(APACHE_ARROW_BUILD_DIR)" \
			-D CMAKE_BUILD_TYPE=Release \
			-D CMAKE_INSTALL_PREFIX="$(INSTALL_PREFIX)" \
			$(CMAKE_CONFIGURE_FLAGS) \
			-D ARROW_BUILD_TESTS=OFF \
			-D ARROW_BUILD_UTILITIES=OFF \
			-D ARROW_BUILD_SHARED=OFF \
			-D ARROW_BUILD_STATIC=ON \
			-D ARROW_IPC=ON \
			-D ARROW_ENABLE_TIMING_TESTS=OFF ; \
	fi

install-apache-arrow: config-apache-arrow
	@ if [ ! -f "$(APACHE_ARROW_CONFIG_CMAKE)" ]; then \
		cmake --build "$(APACHE_ARROW_BUILD_DIR)" --config Release --target install --parallel $(NPROC) ; \
	fi

$(APACHE_ARROW_CONFIG_CMAKE): install-apache-arrow
	@ echo > /dev/null

clean-abseil-cpp:
	rm -rf "$(ABSEIL_CPP_BUILD_DIR)"

clean-grpc:
	rm -rf "$(GRPC_BUILD_DIR)"

clean-openssl:
	rm -rf "$(OPENSSL_SRC_DIR)"

clean-google-cloud-cpp:
	rm -rf "$(GOOGLE_CLOUD_CPP_BUILD_DIR)"

clean-apache-arrow:
	rm -rf "$(APACHE_ARROW_BUILD_DIR)"

clean: clean-abseil-cpp clean-grpc clean-openssl clean-google-cloud-cpp clean-apache-arrow
	@ echo > /dev/null
