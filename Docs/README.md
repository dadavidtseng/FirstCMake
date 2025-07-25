# FirstCMake

A modern C++20 project demonstrating CMake build system with organized project structure.

## Features

- **C++20 Support**: Uses modern C++ features including concepts and ranges
- **Cross-Platform**: CMake build system supports Windows, Linux, and macOS
- **Organized Structure**: Clean separation between source code, build outputs, and temporary files
- **Multiple Configurations**: Supports Debug/Release builds for x64/x86 platforms
- **Professional Naming**: Consistent naming conventions across all build artifacts

## Project Structure

```
FirstCMake/
├── Code/
│   └── Game/
│       ├── include/        # Header files
│       ├── lib/           # Library source files  
│       └── src/           # Main application source
├── Run/
│   ├── CMake/            # CMake build executables
│   └── IDE/              # IDE build executables
├── Temporary/
│   ├── CMake/            # CMake build artifacts
│   └── IDE/              # IDE build artifacts
├── CMakeLists.txt        # CMake configuration
└── Build.ps1            # Build script
```

## Requirements

- **CMake** 3.20 or higher
- **C++20 compatible compiler**:
    - Visual Studio 2019 16.11+ / 2022
    - GCC 10+
    - Clang 12+
- **PowerShell** (for build script)

## Building

### Using Build Script (Recommended)

```powershell
# Interactive mode
.\Build.ps1

# Build all configurations
.\Build.ps1 -All

# Build specific configuration
.\Build.ps1 -Configuration Debug -Platform x64

# Clean outputs
.\Build.ps1 -Clean

# Show help
.\Build.ps1 -Help
```

### Manual CMake

```bash
# Create build directory
mkdir build && cd build

# Configure
cmake .. -A x64 -DCMAKE_BUILD_TYPE=Debug

# Build
cmake --build . --config Debug
```

## Output Files

After building, executables will be available in:

- `Run/CMake/FirstCMake_Debug_x64.exe`
- `Run/CMake/FirstCMake_Release_x64.exe`
- `Run/CMake/FirstCMake_Debug_x86.exe`
- `Run/CMake/FirstCMake_Release_x86.exe`

## Development

### IDE Support

- **Visual Studio**: Open the `.sln` file
- **JetBrains Rider**: Open the project folder
- **CLion**: Open the project folder
- **VS Code**: Install C++ and CMake extensions

### Code Style

- **Naming**: PascalCase for functions and classes
- **Standard**: C++20 with concepts and ranges
- **Headers**: `#pragma once` for header guards

## License

This project is for educational purposes.