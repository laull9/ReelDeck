# This file is a part of media_kit (https://github.com/media-kit/media-kit).
#
# Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
# All rights reserved.
# Use of this source code is governed by MIT license that can be found in the LICENSE file.

cmake_minimum_required(VERSION 3.18)

# This option is read by the other packages which are part of package:media_kit.
option(MEDIA_KIT_LIBS_AVAILABLE "package:media_kit libraries are available." ON)

set(PROJECT_NAME "media_kit_libs_windows_video")
project(${PROJECT_NAME} LANGUAGES CXX)

# Deal with MSVC incompatiblity
add_compile_definitions(_DISABLE_CONSTEXPR_MUTEX_CONSTRUCTOR)

# ------------------------------------------------------------------------------
function(download_and_verify url md5 locationForArchive)
  # Check if the archive exists.
  if(EXISTS "${locationForArchive}")
    file(MD5 "${locationForArchive}" ARCHIVE_MD5)

    # If MD5 doesn't match, delete the archive to download again.
    if(NOT md5 STREQUAL ARCHIVE_MD5)
      file(REMOVE "${locationForArchive}")
      message(STATUS "MD5 mismatch. File deleted.")
    endif()
  endif()

  # Download the archive if it doesn't exist.
  if(NOT EXISTS "${locationForArchive}")
    message(STATUS "Downloading archive from ${url}...")
    file(DOWNLOAD "${url}" "${locationForArchive}")
    message(STATUS "Downloaded archive to ${locationForArchive}.")

    # Verify MD5 of the newly downloaded file.
    file(MD5 "${locationForArchive}" ARCHIVE_MD5)

    if(md5 STREQUAL ARCHIVE_MD5)
      message(STATUS "${locationForArchive} Verification successful.")
    else()
      message(FATAL_ERROR "${locationForArchive} Integrity check failed, please try to re-build project again.")
    endif()
  endif()
endfunction()

function(check_directory_exists_and_not_empty dir result_var)
  # Check if the directory exists
  if(EXISTS "${dir}")
    # Check if the directory is not empty
    file(GLOB dir_contents "${dir}/*")

    if(dir_contents)
      set(${result_var} TRUE PARENT_SCOPE)
    else()
      set(${result_var} FALSE PARENT_SCOPE)
      message(STATUS "Directory ${dir} exists but is empty!")
    endif()
  else()
    set(${result_var} FALSE PARENT_SCOPE)
    message(STATUS "Directory ${dir} does not exist!")
  endif()
endfunction()

# libmpv archive containing the pre-built shared libraries & headers.
if(FLUTTER_TARGET_PLATFORM STREQUAL "windows-arm64")
  set(LIBMPV "mpv-dev-aarch64-20241021-git-0f78584.7z")
  set(LIBMPV_URL "https://github.com/media-kit/libmpv-win32-video-cmake/releases/download/20241021/${LIBMPV}")
  set(LIBMPV_MD5 "5b507a35db13eee6cb7eb21e8be7c83d")
else()
  set(LIBMPV "mpv-dev-x86_64-20230924-git-652a1dd.7z")

# Download URL & MD5 hash of the libmpv archive.
set(LIBMPV_URL "https://github.com/media-kit/libmpv-win32-video-build/releases/download/2023-09-24/${LIBMPV}")
set(LIBMPV_MD5 "a832ef24b3a6ff97cd2560b5b9d04cd8")
endif()

# Download location of the libmpv archive.
set(LIBMPV_ARCHIVE "${CMAKE_BINARY_DIR}/${LIBMPV}")
set(LIBMPV_SRC "${CMAKE_BINARY_DIR}/libmpv")

download_and_verify(
  ${LIBMPV_URL}
  ${LIBMPV_MD5}
  ${LIBMPV_ARCHIVE}
)

check_directory_exists_and_not_empty(${LIBMPV_SRC} LIBMPV_SRC_VALID)

# Extract during configure so headers exist before any plugin compiles.
if(NOT LIBMPV_SRC_VALID)
  file(MAKE_DIRECTORY "${LIBMPV_SRC}")
  file(ARCHIVE_EXTRACT INPUT "${LIBMPV_ARCHIVE}" DESTINATION "${LIBMPV_SRC}")
  file(COPY "${LIBMPV_SRC}/include/mpv/" DESTINATION "${LIBMPV_SRC}/headers")
  file(REMOVE_RECURSE "${LIBMPV_SRC}/include")
  file(RENAME "${LIBMPV_SRC}/headers" "${LIBMPV_SRC}/include")
endif()

# ------------------------------------------------------------------------------

# ANGLE archive containing the pre-built shared libraries & headers.
set(ANGLE "ANGLE.7z")

# Download URL & MD5 hash of the ANGLE archive.
set(ANGLE_URL "https://github.com/alexmercerind/flutter-windows-ANGLE-OpenGL-ES/releases/download/v1.0.1/ANGLE.7z")
set(ANGLE_MD5 "e866f13e8d552348058afaafe869b1ed")

# Download location of the ANGLE archive.
set(ANGLE_ARCHIVE "${CMAKE_BINARY_DIR}/${ANGLE}")
set(ANGLE_SRC "${CMAKE_BINARY_DIR}/ANGLE")

if(FLUTTER_TARGET_PLATFORM STREQUAL "windows-arm64")
  # ARM64 ANGLE 从 vcpkg 构建，必须同时提供头文件、导入库、DLL。
  set(ANGLE_INPUT "$ENV{REELDECK_ANGLE_DIR}")
  if(NOT EXISTS "${ANGLE_INPUT}/bin/libEGL.dll" OR NOT EXISTS "${ANGLE_INPUT}/bin/libGLESv2.dll")
    message(FATAL_ERROR "Run scripts/prepare_windows_arm64.ps1 and set REELDECK_ANGLE_DIR before building ARM64.")
  endif()
  file(MAKE_DIRECTORY "${ANGLE_SRC}/include" "${ANGLE_SRC}/lib")
  file(COPY "${ANGLE_INPUT}/include/" DESTINATION "${ANGLE_SRC}/include")
  # vcpkg EGL registry 不含 ANGLE 专属常量；与同一源码提交保持一致。
  download_and_verify(
    "https://raw.githubusercontent.com/google/angle/d9fc4a372074b1079c193c422fc4a180e79b6636/include/EGL/eglext_angle.h"
    "42fc5ac5c3e7363c9afb380f213f255b"
    "${ANGLE_SRC}/include/EGL/eglext_angle.h")
  file(APPEND "${ANGLE_SRC}/include/EGL/eglext.h" "\n#include \"eglext_angle.h\"\n")
  file(COPY "${ANGLE_INPUT}/bin/" DESTINATION "${ANGLE_SRC}")
  configure_file("${ANGLE_INPUT}/lib/libEGL.lib" "${ANGLE_SRC}/lib/libEGL.dll.lib" COPYONLY)
  configure_file("${ANGLE_INPUT}/lib/libGLESv2.lib" "${ANGLE_SRC}/lib/libGLESv2.dll.lib" COPYONLY)
  file(GLOB ANGLE_DLLS "${ANGLE_SRC}/*.dll")
else()
  download_and_verify(${ANGLE_URL} ${ANGLE_MD5} ${ANGLE_ARCHIVE})
  check_directory_exists_and_not_empty(${ANGLE_SRC} ANGLE_SRC_VALID)
  if(NOT ANGLE_SRC_VALID)
    file(MAKE_DIRECTORY "${ANGLE_SRC}")
    file(ARCHIVE_EXTRACT INPUT "${ANGLE_ARCHIVE}" DESTINATION "${ANGLE_SRC}")
  endif()
  set(ANGLE_DLLS
    "${ANGLE_SRC}/d3dcompiler_47.dll"
    "${ANGLE_SRC}/libEGL.dll"
    "${ANGLE_SRC}/libGLESv2.dll"
    "${ANGLE_SRC}/vk_swiftshader.dll"
    "${ANGLE_SRC}/vulkan-1.dll"
    "${ANGLE_SRC}/zlib.dll")
endif()

# ------------------------------------------------------------------------------
set(PLUGIN_NAME "media_kit_libs_windows_video_plugin")

add_library(
  ${PLUGIN_NAME} SHARED
  "include/media_kit_libs_windows_video/media_kit_libs_windows_video_plugin_c_api.h"
  "media_kit_libs_windows_video_plugin_c_api.cpp"
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(
  ${PLUGIN_NAME}
  PROPERTIES
  CXX_VISIBILITY_PRESET
  hidden
)
target_compile_definitions(
  ${PLUGIN_NAME}
  PRIVATE
  FLUTTER_PLUGIN_IMPL
)

target_include_directories(
  ${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
target_link_libraries(
  ${PLUGIN_NAME}
  PRIVATE
  flutter
  flutter_wrapper_plugin
)

set(
  media_kit_libs_windows_video_bundled_libraries
  "${LIBMPV_SRC}/libmpv-2.dll"
  ${ANGLE_DLLS}
  PARENT_SCOPE
)
