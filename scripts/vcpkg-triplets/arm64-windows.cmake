set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
# CI 只发布 release，省去不进入应用包的 debug 依赖。
set(VCPKG_BUILD_TYPE release)
