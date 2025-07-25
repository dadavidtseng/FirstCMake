# 指定最低 CMake 版本
cmake_minimum_required(VERSION 3.20)

# 定義專案名稱和版本
project(FirstCMake VERSION 1.0.0 LANGUAGES CXX)

# 設定 C++20 標準
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 設定平台簡稱
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(PLATFORM_NAME "x64")
else()
  set(PLATFORM_NAME "x86")
endif()

# 設定組態名稱（保持原始大小寫）
set(CONFIG_NAME ${CMAKE_BUILD_TYPE})

# 設定目標名稱格式：ProjectName_Config_Platform
set(TARGET_NAME "${PROJECT_NAME}_${CONFIG_NAME}_${PLATFORM_NAME}")

# 設定輸出目錄
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY
    ${CMAKE_SOURCE_DIR}/Temporary/CMake/${TARGET_NAME})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG
    ${CMAKE_SOURCE_DIR}/Temporary/CMake/${TARGET_NAME})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE
    ${CMAKE_SOURCE_DIR}/Temporary/CMake/${TARGET_NAME})

# 設定中間檔案和函式庫輸出目錄
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY
    ${CMAKE_SOURCE_DIR}/Temporary/CMake/${TARGET_NAME})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY
    ${CMAKE_SOURCE_DIR}/Temporary/CMake/${TARGET_NAME})
set(CMAKE_PDB_OUTPUT_DIRECTORY
    ${CMAKE_SOURCE_DIR}/Temporary/CMake/${TARGET_NAME})

# 顯示重要訊息
message(STATUS "=== CMake with Unified Naming Convention ===")
message(STATUS "Project: ${PROJECT_NAME}")
message(STATUS "Configuration: ${CMAKE_BUILD_TYPE}")
message(STATUS "Platform: ${PLATFORM_NAME}")
message(STATUS "Target Name: ${TARGET_NAME}")
message(STATUS "Output Directory: ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")

# 建立靜態函式庫
add_library(utils STATIC
    Code/Game/lib/Utils.cpp
)

# 設定函式庫命名
set_target_properties(utils PROPERTIES
    OUTPUT_NAME "utils_${CONFIG_NAME}_${PLATFORM_NAME}"
)

# 設定函式庫的公開 include 目錄
target_include_directories(utils PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Code/Game/include>
    $<INSTALL_INTERFACE:include>
)

# 建立主執行檔
add_executable(FirstCMake
    Code/Game/src/FirstCMake.cpp
)

# 設定執行檔命名
set_target_properties(FirstCMake PROPERTIES
    OUTPUT_NAME "${TARGET_NAME}"
)

# 連結函式庫到執行檔
target_link_libraries(FirstCMake PRIVATE utils)

# 設定編譯選項
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  target_compile_options(FirstCMake PRIVATE /W4)
  target_compile_options(utils PRIVATE /W4)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(FirstCMake PRIVATE -Wall -Wextra -Wpedantic)
  target_compile_options(utils PRIVATE -Wall -Wextra -Wpedantic)
endif()

# 建立目錄結構
file(MAKE_DIRECTORY ${CMAKE_SOURCE_DIR}/Run/CMake)
file(MAKE_DIRECTORY ${CMAKE_SOURCE_DIR}/Temporary/CMake)

# 自訂目標：複製執行檔到 Run 目錄
add_custom_command(TARGET FirstCMake POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory
            ${CMAKE_SOURCE_DIR}/Run/CMake
    COMMAND ${CMAKE_COMMAND} -E copy
            $<TARGET_FILE:FirstCMake>
            ${CMAKE_SOURCE_DIR}/Run/CMake/${TARGET_NAME}.exe
    COMMENT "Copying ${TARGET_NAME}.exe to Run/CMake/"
)

# 顯示建置資訊
message(STATUS "")
message(STATUS "Output Structure:")
message(STATUS "  Executable: Run/CMake/${TARGET_NAME}.exe")
message(STATUS "  All build files: Temporary/CMake/${TARGET_NAME}/")
message(STATUS "")
message(STATUS "Naming Convention:")
message(STATUS "  Debug x64:   FirstCMake_Debug_x64.exe")
message(STATUS "  Release x64: FirstCMake_Release_x64.exe")
message(STATUS "  Debug x86:   FirstCMake_Debug_x86.exe")
message(STATUS "  Release x86: FirstCMake_Release_x86.exe")
message(STATUS "//////////////////////////////////////////////")
