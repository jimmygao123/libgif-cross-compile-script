
set -e
set -x

BUILD_ROOT="$PWD"
OUTPUT_DIR="${BUILD_ROOT}/output"
mkdir "${OUTPUT_DIR}"
mkdir "${OUTPUT_DIR}/armv7"
mkdir "${OUTPUT_DIR}/arm64"
mkdir "${OUTPUT_DIR}/i386"
mkdir "${OUTPUT_DIR}/x84_64"

OPT_FLAGS="-0s -g3"
MAKE_JOBS=4

dobuild(){
	export CC="$(xcrun -find -sdk ${SDK} cc)"
	export CXX="$(xcrun -find -sdk ${SDK} cxx)"
	export CPP="$(xcrun -find -sdk ${SDK} cpp)"
	##export CFLAGS="${HOST_FLAGS} ${OPT_FLAGS}"
	export CFLAGS="${HOST_FLAGS}"
	##export CXXFLAGS="${HOST_FLAGS} ${OPT_FLAGS}"
	export CXXFLAGS="${HOST_FLAGS}"
	export LDFLAGS="${HOST_FLAGS}"

	./configure --host=${CHOST} --prefix=${PREFIX} --enable-static --disable-shared
	
	make clean
	#make -j ${MAKE_JOBS}
	make install 
}

SDK="iphoneos"
ARCH_FLAGS="-arch armv7"
HOST_FLAGS="${ARCH_FLAGS} -miphoneos-version-min=8.0 -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="arm-apple-darwin"
PREFIX="${OUTPUT_DIR}/armv7"
dobuild
echo "================armv7 compile finished============="

SDK="iphoneos"
ARCH_FLAGS="-arch arm64"
HOST_FLAGS="${ARCH_FLAGS} -miphoneos-version-min=8.0 -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="arm-apple-darwin"
PREFIX="${OUTPUT_DIR}/arm64"
dobuild
echo "================arm64 compile finished============="

SDK="iphonesimulator"
ARCH_FLAGS="-arch i386"
HOST_FLAGS="${ARCH_FLAGS} -mios-simulator-version-min=8.0 -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="i386-apple-darwin"
PREFIX="${OUTPUT_DIR}/i386"
dobuild
echo "================i386 compile finished============="

SDK="iphonesimulator"
ARCH_FLAGS="-arch x86_64"
HOST_FLAGS="${ARCH_FLAGS} -mios-simulator-version-min=8.0 -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="x86_64-apple-darwin"
PREFIX="${OUTPUT_DIR}/x86_64"
dobuild
echo "================x86_64 compile finished============="

INSTALL_DIR="${OUTPUT_DIR}/install"
mkdir "${INSTALL_DIR}"
lipo -create -output ${INSTALL_DIR}/libgif.a "${OUTPUT_DIR}"/armv7/lib/libgif.a "${OUTPUT_DIR}"/arm64/lib/libgif.a "${OUTPUT_DIR}"/i386/lib/libgif.a "${OUTPUT_DIR}/x86_64/lib/libgif.a"

cp -f "${OUTPUT_DIR}/armv7/include/gif_lib.h" "${INSTALL_DIR}/" 
echo "================intall success==================="

