# Build.ps1 - CMake Build Script for FirstCMake
#
# Usage:
#   .\Build.ps1                              # Interactive mode
#   .\Build.ps1 -All                         # Build all configurations
#   .\Build.ps1 -Configuration Debug -Platform x64  # Build specific configuration
#   .\Build.ps1 -Help                        # Show help

[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration,

    [ValidateSet('x64', 'x86')]
    [string]$Platform,

    [switch]$All,
    [switch]$Help,
    [switch]$Clean
)

# Set console encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Safe output function that works in all PowerShell hosts
function Write-FormattedOutput {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Header', 'Verbose')]
        [string]$Type = 'Info'
    )

    $prefix = switch ($Type) {
        'Success' { '[SUCCESS] ' }
        'Warning' { '[WARNING] ' }
        'Error'   { '[ERROR] ' }
        'Header'  { '' }
        'Verbose' { '[VERBOSE] ' }
        default   { '' }
    }

    $outputMessage = $prefix + $Message

    switch ($Type) {
        'Error'   { Write-Error $outputMessage }
        'Warning' { Write-Warning $outputMessage }
        'Verbose' { Write-Verbose $outputMessage }
        default   { Write-Output $outputMessage }
    }
}

# Show help information
function Show-Help {
    Write-FormattedOutput "CMake Build Script for FirstCMake" -Type Header
    Write-FormattedOutput "=================================" -Type Header
    Write-Output ""
    Write-FormattedOutput "Usage:" -Type Header
    Write-Output "  .\Build.ps1                              # Interactive mode"
    Write-Output "  .\Build.ps1 -All                         # Build all configurations"
    Write-Output "  .\Build.ps1 -Configuration Debug -Platform x64  # Build specific configuration"
    Write-Output "  .\Build.ps1 -Clean                       # Clean all build outputs"
    Write-Output "  .\Build.ps1 -Help                        # Show this help"
    Write-Output ""
    Write-FormattedOutput "Parameters:" -Type Header
    Write-Output "  -Configuration  Debug|Release            # Build configuration"
    Write-Output "  -Platform       x64|x86                  # Target platform"
    Write-Output "  -All                                      # Build all 4 configurations"
    Write-Output "  -Clean                                    # Clean build outputs"
    Write-Output "  -Help                                     # Show this help"
    Write-Output ""
    Write-FormattedOutput "Examples:" -Type Header
    Write-Output "  .\Build.ps1 -Configuration Debug -Platform x64"
    Write-Output "  .\Build.ps1 -All"
    Write-Output ""
    Write-FormattedOutput "Output:" -Type Header
    Write-Output "  Executables: Run\CMake\"
    Write-Output "  Build files: Temporary\CMake\"
}

# Clean build outputs
function Remove-BuildOutput {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-FormattedOutput "========================================" -Type Header
    Write-FormattedOutput "   Cleaning Build Outputs" -Type Header
    Write-FormattedOutput "========================================" -Type Header

    $dirsToClean = @("Run\CMake", "Temporary\CMake")

    foreach ($dir in $dirsToClean) {
        if (Test-Path $dir) {
            if ($PSCmdlet.ShouldProcess($dir, "Remove directory")) {
                Write-FormattedOutput "Cleaning: $dir" -Type Verbose
                Remove-Item -Recurse -Force $dir
                Write-FormattedOutput "Cleaned: $dir" -Type Success
            }
        } else {
            Write-FormattedOutput "Already clean: $dir" -Type Info
        }
    }

    Write-Output ""
    Write-FormattedOutput "Clean completed!" -Type Success
}

# Interactive menu
function Show-InteractiveMenu {
    Write-FormattedOutput "========================================" -Type Header
    Write-FormattedOutput "   Available Build Options" -Type Header
    Write-FormattedOutput "========================================" -Type Header
    Write-Output ""
    Write-FormattedOutput "What would you like to build?" -Type Header
    Write-Output ""
    Write-Output "1. Build all configurations (Debug/Release x64/x86)"
    Write-Output "   - This will build all 4 combinations and show a summary"
    Write-Output ""
    Write-Output "2. Build Debug x64"
    Write-Output "   - Debug build with full debugging symbols (64-bit)"
    Write-Output ""
    Write-Output "3. Build Release x64"
    Write-Output "   - Optimized release build (64-bit)"
    Write-Output ""
    Write-Output "4. Build Debug x86"
    Write-Output "   - Debug build with full debugging symbols (32-bit)"
    Write-Output ""
    Write-Output "5. Build Release x86"
    Write-Output "   - Optimized release build (32-bit)"
    Write-Output ""
    Write-Output "6. Clean all outputs"
    Write-Output "   - Remove all generated files and build directories"
    Write-Output ""
    Write-Output "7. Exit"
    Write-Output "   - Exit the build script"
    Write-Output ""

    do {
        $choice = Read-Host "Please select an option (1-7)"

        switch ($choice) {
            "1" {
                Write-Output ""
                Write-FormattedOutput "Starting build for all configurations..." -Type Header
                return @{ Mode = "All" }
            }
            "2" {
                Write-Output ""
                Write-FormattedOutput "Starting Debug x64 build..." -Type Header
                return @{ Mode = "Single"; Config = "Debug"; Platform = "x64" }
            }
            "3" {
                Write-Output ""
                Write-FormattedOutput "Starting Release x64 build..." -Type Header
                return @{ Mode = "Single"; Config = "Release"; Platform = "x64" }
            }
            "4" {
                Write-Output ""
                Write-FormattedOutput "Starting Debug x86 build..." -Type Header
                return @{ Mode = "Single"; Config = "Debug"; Platform = "x86" }
            }
            "5" {
                Write-Output ""
                Write-FormattedOutput "Starting Release x86 build..." -Type Header
                return @{ Mode = "Single"; Config = "Release"; Platform = "x86" }
            }
            "6" {
                Write-Output ""
                Write-FormattedOutput "Starting cleanup..." -Type Header
                return @{ Mode = "Clean" }
            }
            "7" {
                return @{ Mode = "Exit" }
            }
            default {
                Write-Output ""
                Write-FormattedOutput "Invalid choice '$choice'. Please select a number from 1 to 7." -Type Warning
                Write-Output ""
            }
        }
    } while ($true)
}

# Build single configuration
function Build-SingleConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Debug', 'Release')]
        [string]$Config,

        [Parameter(Mandatory)]
        [ValidateSet('x64', 'x86')]
        [string]$Platform
    )

    $targetName = "FirstCMake_$Config" + "_$Platform"
    $buildDir = "Temporary\CMake\$targetName"

    Write-FormattedOutput "========================================" -Type Header
    Write-FormattedOutput "   Building: $targetName" -Type Header
    Write-FormattedOutput "========================================" -Type Header

    # Check if CMake is available
    try {
        $null = cmake --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "CMake not found"
        }
        Write-FormattedOutput "CMake is available" -Type Success
    } catch {
        Write-FormattedOutput "CMake not found! Please install CMake first." -Type Error
        Write-Output "Download from: https://cmake.org/download/"
        return $false
    }

    # Check if CMakeLists.txt exists
    if (-not (Test-Path "CMakeLists.txt")) {
        Write-FormattedOutput "CMakeLists.txt not found in current directory!" -Type Error
        Write-FormattedOutput "Current directory: $(Get-Location)" -Type Verbose
        return $false
    }

    # Create build directory
    if (Test-Path $buildDir) {
        if ($PSCmdlet.ShouldProcess($buildDir, "Remove old build directory")) {
            Write-FormattedOutput "Cleaning old build: $buildDir" -Type Verbose
            Remove-Item -Recurse -Force $buildDir
        }
    }

    if ($PSCmdlet.ShouldProcess($buildDir, "Create build directory")) {
        New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
    }

    # Enter build directory
    $originalLocation = Get-Location
    Set-Location $buildDir

    try {
        # Prepare CMake arguments
        $cmakeArgs = @("..\..\..")  # Point to project root

        if ($Platform -eq "x86") {
            $cmakeArgs += "-A", "Win32"
        } else {
            $cmakeArgs += "-A", "x64"
        }
        $cmakeArgs += "-DCMAKE_BUILD_TYPE=$Config"

        Write-Output "Configuring..."
        Write-FormattedOutput "Command: cmake $($cmakeArgs -join ' ')" -Type Verbose

        # Run CMake configure
        if ($PSCmdlet.ShouldProcess("CMake", "Configure build")) {
            $configOutput = & cmake @cmakeArgs 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-FormattedOutput "Configuration failed!" -Type Error
                Write-Output "CMake output:"
                Write-Output $configOutput
                return $false
            }

            Write-FormattedOutput "Configuration successful" -Type Success
        }

        # Run build
        Write-Output "Building..."
        Write-FormattedOutput "Command: cmake --build . --config $Config" -Type Verbose

        if ($PSCmdlet.ShouldProcess("CMake", "Build project")) {
            $buildOutput = & cmake --build . --config $Config 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-FormattedOutput "Build failed!" -Type Error
                Write-Output "Build output:"
                Write-Output $buildOutput
                return $false
            }

            Write-FormattedOutput "Build successful: $targetName" -Type Success
        }

        # Check if executable was created and copied
        $exePath = "$originalLocation\Run\CMake\$targetName.exe"
        if (Test-Path $exePath) {
            $exeSize = [math]::Round((Get-Item $exePath).Length / 1KB, 1)
            Write-FormattedOutput "Executable created: Run\CMake\$targetName.exe ($exeSize KB)" -Type Success
        } else {
            Write-FormattedOutput "Executable not found at: Run\CMake\$targetName.exe" -Type Warning
        }

        return $true

    } catch {
        Write-FormattedOutput "Build failed: $($_.Exception.Message)" -Type Error
        return $false
    } finally {
        Set-Location $originalLocation
    }
}

# Build all configuration
function Build-AllConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-FormattedOutput "========================================" -Type Header
    Write-FormattedOutput "   Building All Configurations" -Type Header
    Write-FormattedOutput "========================================" -Type Header

    $configurations = @(
        @{ Config = "Debug"; Platform = "x64" },
        @{ Config = "Release"; Platform = "x64" },
        @{ Config = "Debug"; Platform = "x86" },
        @{ Config = "Release"; Platform = "x86" }
    )

    $successCount = 0
    $totalCount = $configurations.Count
    $results = @()

    $overallStartTime = Get-Date

    foreach ($build in $configurations) {
        $startTime = Get-Date
        $success = Build-SingleConfiguration -Config $build.Config -Platform $build.Platform
        $endTime = Get-Date
        $duration = $endTime - $startTime

        $results += @{
            Target = "FirstCMake_$($build.Config)_$($build.Platform)"
            Success = $success
            Duration = $duration
        }

        if ($success) { $successCount++ }
        Write-Output ""
    }

    $overallEndTime = Get-Date
    $overallDuration = $overallEndTime - $overallStartTime

    # Build summary
    Write-FormattedOutput "========================================" -Type Header
    Write-FormattedOutput "   Build Summary" -Type Header
    Write-FormattedOutput "========================================" -Type Header

    foreach ($result in $results) {
        if ($result.Success) {
            Write-FormattedOutput "$($result.Target) - PASSED" -Type Success
        } else {
            Write-FormattedOutput "$($result.Target) - FAILED" -Type Error
        }
        Write-Output "   Duration: $($result.Duration.TotalSeconds.ToString('F1'))s"
    }

    Write-Output ""
    Write-Output "Results: $successCount/$totalCount builds successful"
    Write-Output "Total time: $($overallDuration.TotalSeconds.ToString('F1')) seconds"

    if ($successCount -eq $totalCount) {
        Write-Output ""
        Write-FormattedOutput "All builds completed successfully!" -Type Success

        # Show generated files
        $runDir = "Run\CMake"
        if (Test-Path $runDir) {
            Write-Output ""
            Write-Output "Generated executables:"
            $exeFiles = Get-ChildItem -Path $runDir -Filter "*.exe" | Sort-Object Name
            foreach ($exe in $exeFiles) {
                $size = [math]::Round($exe.Length / 1KB, 1)
                Write-Output "  - $($exe.Name) ($size KB)"
            }

            Write-Output ""
            Write-Output "Directory structure:"
            Write-Output "Run\CMake\"
            Write-Output "   |-- FirstCMake_Debug_x64.exe"
            Write-Output "   |-- FirstCMake_Release_x64.exe"
            Write-Output "   |-- FirstCMake_Debug_x86.exe"
            Write-Output "   +-- FirstCMake_Release_x86.exe"
            Write-Output ""
            Write-Output "Temporary\CMake\"
            Write-Output "   |-- FirstCMake_Debug_x64\"
            Write-Output "   |-- FirstCMake_Release_x64\"
            Write-Output "   |-- FirstCMake_Debug_x86\"
            Write-Output "   +-- FirstCMake_Release_x86\"
        }
    } else {
        Write-Output ""
        Write-FormattedOutput "Some builds failed. Check the errors above." -Type Warning
    }
}

# Main script logic
try {
    # Show help
    if ($Help) {
        Show-Help
        return
    }

    # Clean mode
    if ($Clean) {
        Remove-BuildOutput
        return
    }

    # Build all configurations
    if ($All) {
        Build-AllConfiguration
        return
    }

    # Build specific configuration
    if ($Configuration -and $Platform) {
        $success = Build-SingleConfiguration -Config $Configuration -Platform $Platform

        if ($success) {
            Write-Output ""
            Write-FormattedOutput "Build completed successfully!" -Type Success
        } else {
            Write-Output ""
            Write-FormattedOutput "Build failed!" -Type Error
            exit 1
        }
        return
    }

    # Interactive mode (default)
    Write-Output ""
    Write-FormattedOutput "========================================" -Type Header
    Write-FormattedOutput "   CMake Build Script for FirstCMake" -Type Header
    Write-FormattedOutput "========================================" -Type Header
    Write-Output ""
    Write-FormattedOutput "Welcome to the interactive build system!" -Type Header
    Write-Output ""
    Write-FormattedOutput "This script will help you build your CMake project with different configurations." -Type Info
    Write-FormattedOutput "All executables will be created in: Run\CMake\" -Type Info
    Write-FormattedOutput "Build files will be stored in: Temporary\CMake\" -Type Info
    Write-Output ""

    Write-FormattedOutput "========================================" -Type Header
    Write-FormattedOutput "   Available Build Options" -Type Header
    Write-FormattedOutput "========================================" -Type Header
    Write-Output ""
    Write-FormattedOutput "What would you like to build?" -Type Header
    Write-Output ""
    Write-Output "1. Build all configurations (Debug/Release x64/x86)"
    Write-Output "   - This will build all 4 combinations and show a summary"
    Write-Output ""
    Write-Output "2. Build Debug x64"
    Write-Output "   - Debug build with full debugging symbols (64-bit)"
    Write-Output ""
    Write-Output "3. Build Release x64"
    Write-Output "   - Optimized release build (64-bit)"
    Write-Output ""
    Write-Output "4. Build Debug x86"
    Write-Output "   - Debug build with full debugging symbols (32-bit)"
    Write-Output ""
    Write-Output "5. Build Release x86"
    Write-Output "   - Optimized release build (32-bit)"
    Write-Output ""
    Write-Output "6. Clean all outputs"
    Write-Output "   - Remove all generated files and build directories"
    Write-Output ""
    Write-Output "7. Exit"
    Write-Output "   - Exit the build script"
    Write-Output ""

    do {
        $choice = Read-Host "Please select an option (1-7)"

        switch ($choice) {
            "1" {
                Write-Output ""
                Write-FormattedOutput "Starting build for all configurations..." -Type Header
                $choiceResult = @{ Mode = "All" }
                break
            }
            "2" {
                Write-Output ""
                Write-FormattedOutput "Starting Debug x64 build..." -Type Header
                $choiceResult = @{ Mode = "Single"; Config = "Debug"; Platform = "x64" }
                break
            }
            "3" {
                Write-Output ""
                Write-FormattedOutput "Starting Release x64 build..." -Type Header
                $choiceResult = @{ Mode = "Single"; Config = "Release"; Platform = "x64" }
                break
            }
            "4" {
                Write-Output ""
                Write-FormattedOutput "Starting Debug x86 build..." -Type Header
                $choiceResult = @{ Mode = "Single"; Config = "Debug"; Platform = "x86" }
                break
            }
            "5" {
                Write-Output ""
                Write-FormattedOutput "Starting Release x86 build..." -Type Header
                $choiceResult = @{ Mode = "Single"; Config = "Release"; Platform = "x86" }
                break
            }
            "6" {
                Write-Output ""
                Write-FormattedOutput "Starting cleanup..." -Type Header
                $choiceResult = @{ Mode = "Clean" }
                break
            }
            "7" {
                $choiceResult = @{ Mode = "Exit" }
                break
            }
            default {
                Write-Output ""
                Write-FormattedOutput "Invalid choice '$choice'. Please select a number from 1 to 7." -Type Warning
                Write-Output ""
            }
        }
    } while (-not $choiceResult)

    $choice = $choiceResult

    switch ($choice.Mode) {
        "All" {
            Build-AllConfiguration
        }
        "Single" {
            $success = Build-SingleConfiguration -Config $choice.Config -Platform $choice.Platform
            if ($success) {
                Write-Output ""
                Write-FormattedOutput "Build completed successfully!" -Type Success
            }
        }
        "Clean" {
            Remove-BuildOutput
        }
        "Exit" {
            Write-Output "Goodbye!"
            return
        }
    }

} catch {
    Write-FormattedOutput "An unexpected error occurred: $($_.Exception.Message)" -Type Error
    Write-Verbose "Stack trace: $($_.ScriptStackTrace)"
    exit 1
} finally {
    if (-not $Help -and -not ($choice.Mode -eq "Exit")) {
        Write-Output ""
        Read-Host "Press any key to exit"
    }
}