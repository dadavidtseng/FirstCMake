# Build.ps1 - CMake Build Script for FirstCMake
#
# Usage:
#   .\Build.ps1                              # Interactive mode
#   .\Build.ps1 -All                         # Build all configurations
#   .\Build.ps1 -Configuration Debug -Platform x64  # Build specific configuration
#   .\Build.ps1 -Help                        # Show help

param(
    [string]$Configuration,
    [string]$Platform,
    [switch]$All,
    [switch]$Help,
    [switch]$Clean
)

# Set console encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Show help information
function Show-Help {
    Write-Host "CMake Build Script for FirstCMake" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\Build.ps1                              # Interactive mode" -ForegroundColor White
    Write-Host "  .\Build.ps1 -All                         # Build all configurations" -ForegroundColor White
    Write-Host "  .\Build.ps1 -Configuration Debug -Platform x64  # Build specific configuration" -ForegroundColor White
    Write-Host "  .\Build.ps1 -Clean                       # Clean all build outputs" -ForegroundColor White
    Write-Host "  .\Build.ps1 -Help                        # Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Yellow
    Write-Host "  -Configuration  Debug|Release            # Build configuration" -ForegroundColor White
    Write-Host "  -Platform       x64|x86                  # Target platform" -ForegroundColor White
    Write-Host "  -All                                      # Build all 4 configurations" -ForegroundColor White
    Write-Host "  -Clean                                    # Clean build outputs" -ForegroundColor White
    Write-Host "  -Help                                     # Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\Build.ps1 -Configuration Debug -Platform x64" -ForegroundColor Gray
    Write-Host "  .\Build.ps1 -All" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Output:" -ForegroundColor Yellow
    Write-Host "  Executables: Run\CMake\" -ForegroundColor White
    Write-Host "  Build files: Temporary\CMake\" -ForegroundColor White
}

# Clean build outputs
function Clean-BuildOutput {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   Cleaning Build Outputs" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    $dirsToClean = @("Run\CMake", "Temporary\CMake")

    foreach ($dir in $dirsToClean) {
        if (Test-Path $dir) {
            Write-Host "Cleaning: $dir" -ForegroundColor Yellow
            Remove-Item -Recurse -Force $dir
            Write-Host "✓ Cleaned: $dir" -ForegroundColor Green
        } else {
            Write-Host "✓ Already clean: $dir" -ForegroundColor Gray
        }
    }

    Write-Host ""
    Write-Host "🧹 Clean completed!" -ForegroundColor Green
}

# Interactive menu
function Show-InteractiveMenu {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   CMake Build Options" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "What would you like to build?" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Build all configurations (Debug/Release x64/x86)" -ForegroundColor White
    Write-Host "2. Build Debug x64" -ForegroundColor White
    Write-Host "3. Build Release x64" -ForegroundColor White
    Write-Host "4. Build Debug x86" -ForegroundColor White
    Write-Host "5. Build Release x86" -ForegroundColor White
    Write-Host "6. Clean all outputs" -ForegroundColor White
    Write-Host "7. Exit" -ForegroundColor White
    Write-Host ""

    do {
        $choice = Read-Host "Please select an option (1-7)"

        switch ($choice) {
            "1" { return @{ Mode = "All" } }
            "2" { return @{ Mode = "Single"; Config = "Debug"; Platform = "x64" } }
            "3" { return @{ Mode = "Single"; Config = "Release"; Platform = "x64" } }
            "4" { return @{ Mode = "Single"; Config = "Debug"; Platform = "x86" } }
            "5" { return @{ Mode = "Single"; Config = "Release"; Platform = "x86" } }
            "6" { return @{ Mode = "Clean" } }
            "7" { return @{ Mode = "Exit" } }
            default {
                Write-Host "Invalid choice. Please select 1-7." -ForegroundColor Red
            }
        }
    } while ($true)
}

# Build single configuration
function Build-SingleConfiguration {
    param(
        [string]$Config,
        [string]$Platform
    )

    $targetName = "FirstCMake_$Config" + "_$Platform"
    $buildDir = "Temporary\CMake\$targetName"

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   Building: $targetName" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    # Check if CMake is available
    try {
        $null = cmake --version 2>$null
        if ($LASTEXITCODE -ne 0) { throw "CMake not found" }
        Write-Host "✓ CMake is available" -ForegroundColor Green
    } catch {
        Write-Host "❌ ERROR: CMake not found! Please install CMake first." -ForegroundColor Red
        Write-Host "Download from: https://cmake.org/download/" -ForegroundColor Yellow
        return $false
    }

    # Check if CMakeLists.txt exists
    if (-not (Test-Path "CMakeLists.txt")) {
        Write-Host "❌ ERROR: CMakeLists.txt not found in current directory!" -ForegroundColor Red
        Write-Host "Current directory: $(Get-Location)" -ForegroundColor Gray
        return $false
    }

    # Create build directory
    if (Test-Path $buildDir) {
        Write-Host "Cleaning old build: $buildDir" -ForegroundColor Yellow
        Remove-Item -Recurse -Force $buildDir
    }
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null

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

        Write-Host "Configuring..." -ForegroundColor Yellow
        Write-Host "Command: cmake $($cmakeArgs -join ' ')" -ForegroundColor Gray

        # Run CMake configure
        $configOutput = & cmake @cmakeArgs 2>&1

        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Configuration failed!" -ForegroundColor Red
            Write-Host "CMake output:" -ForegroundColor Red
            Write-Host $configOutput -ForegroundColor Red
            return $false
        }

        Write-Host "✓ Configuration successful" -ForegroundColor Green

        # Run build
        Write-Host "Building..." -ForegroundColor Yellow
        Write-Host "Command: cmake --build . --config $Config" -ForegroundColor Gray

        $buildOutput = & cmake --build . --config $Config 2>&1

        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Build failed!" -ForegroundColor Red
            Write-Host "Build output:" -ForegroundColor Red
            Write-Host $buildOutput -ForegroundColor Red
            return $false
        }

        Write-Host "✓ Build successful: $targetName" -ForegroundColor Green

        # Check if executable was created and copied
        $exePath = "$originalLocation\Run\CMake\$targetName.exe"
        if (Test-Path $exePath) {
            $exeSize = [math]::Round((Get-Item $exePath).Length / 1KB, 1)
            Write-Host "✓ Executable created: Run\CMake\$targetName.exe ($exeSize KB)" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Executable not found at: Run\CMake\$targetName.exe" -ForegroundColor Yellow
        }

        return $true

    } catch {
        Write-Host "❌ Build failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    } finally {
        Set-Location $originalLocation
    }
}

# Build all configurations
function Build-AllConfigurations {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   Building All Configurations" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

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
        Write-Host ""
    }

    $overallEndTime = Get-Date
    $overallDuration = $overallEndTime - $overallStartTime

    # Build summary
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   Build Summary" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    foreach ($result in $results) {
        $statusIcon = if ($result.Success) { "✓" } else { "❌" }
        $statusColor = if ($result.Success) { "Green" } else { "Red" }

        Write-Host "$statusIcon $($result.Target)" -ForegroundColor $statusColor
        Write-Host "   Duration: $($result.Duration.TotalSeconds.ToString('F1'))s" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "Results: $successCount/$totalCount builds successful" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
    Write-Host "Total time: $($overallDuration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor Gray

    if ($successCount -eq $totalCount) {
        Write-Host ""
        Write-Host "🎉 All builds completed successfully!" -ForegroundColor Green

        # Show generated files
        $runDir = "Run\CMake"
        if (Test-Path $runDir) {
            Write-Host ""
            Write-Host "Generated executables:" -ForegroundColor Yellow
            $exeFiles = Get-ChildItem -Path $runDir -Filter "*.exe" | Sort-Object Name
            foreach ($exe in $exeFiles) {
                $size = [math]::Round($exe.Length / 1KB, 1)
                Write-Host "  📁 $($exe.Name) ($size KB)" -ForegroundColor White
            }

            Write-Host ""
            Write-Host "Directory structure:" -ForegroundColor Yellow
            Write-Host "📁 Run\CMake\" -ForegroundColor White
            Write-Host "   ├── FirstCMake_Debug_x64.exe" -ForegroundColor Gray
            Write-Host "   ├── FirstCMake_Release_x64.exe" -ForegroundColor Gray
            Write-Host "   ├── FirstCMake_Debug_x86.exe" -ForegroundColor Gray
            Write-Host "   └── FirstCMake_Release_x86.exe" -ForegroundColor Gray
            Write-Host ""
            Write-Host "📁 Temporary\CMake\" -ForegroundColor White
            Write-Host "   ├── FirstCMake_Debug_x64\" -ForegroundColor Gray
            Write-Host "   ├── FirstCMake_Release_x64\" -ForegroundColor Gray
            Write-Host "   ├── FirstCMake_Debug_x86\" -ForegroundColor Gray
            Write-Host "   └── FirstCMake_Release_x86\" -ForegroundColor Gray
        }
    } else {
        Write-Host ""
        Write-Host "⚠️  Some builds failed. Check the errors above." -ForegroundColor Yellow
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
        Clean-BuildOutput
        return
    }

    # Build all configurations
    if ($All) {
        Build-AllConfigurations
        return
    }

    # Build specific configuration
    if ($Configuration -and $Platform) {
        if ($Configuration -notin @("Debug", "Release")) {
            Write-Host "Error: Configuration must be 'Debug' or 'Release'" -ForegroundColor Red
            Show-Help
            return
        }
        if ($Platform -notin @("x64", "x86")) {
            Write-Host "Error: Platform must be 'x64' or 'x86'" -ForegroundColor Red
            Show-Help
            return
        }

        $success = Build-SingleConfiguration -Config $Configuration -Platform $Platform

        if ($success) {
            Write-Host ""
            Write-Host "🎉 Build completed successfully!" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "❌ Build failed!" -ForegroundColor Red
        }
        return
    }

    # Interactive mode (default)
    $choice = Show-InteractiveMenu

    switch ($choice.Mode) {
        "All" {
            Build-AllConfigurations
        }
        "Single" {
            $success = Build-SingleConfiguration -Config $choice.Config -Platform $choice.Platform
            if ($success) {
                Write-Host ""
                Write-Host "🎉 Build completed successfully!" -ForegroundColor Green
            }
        }
        "Clean" {
            Clean-BuildOutput
        }
        "Exit" {
            Write-Host "Goodbye!" -ForegroundColor Cyan
            return
        }
    }

} catch {
    Write-Host "An unexpected error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace:" -ForegroundColor Gray
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
} finally {
    if (-not $Help -and -not ($choice.Mode -eq "Exit")) {
        Write-Host ""
        Read-Host "Press any key to exit"
    }
}