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

# Show help information
function Show-Help {
    Write-Output ""
    Write-Output "CMake Build Script for FirstCMake"
    Write-Output "================================="
    Write-Output ""
    Write-Output "Usage:"
    Write-Output "  .\Build.ps1                              # Interactive mode"
    Write-Output "  .\Build.ps1 -All                         # Build all configurations"
    Write-Output "  .\Build.ps1 -Configuration Debug -Platform x64  # Build specific configuration"
    Write-Output "  .\Build.ps1 -Clean                       # Clean all build outputs"
    Write-Output "  .\Build.ps1 -Help                        # Show this help"
    Write-Output ""
    Write-Output "Parameters:"
    Write-Output "  -Configuration  Debug|Release            # Build configuration"
    Write-Output "  -Platform       x64|x86                  # Target platform"
    Write-Output "  -All                                      # Build all 4 configurations"
    Write-Output "  -Clean                                    # Clean build outputs"
    Write-Output "  -Help                                     # Show this help"
    Write-Output ""
    Write-Output "Examples:"
    Write-Output "  .\Build.ps1 -Configuration Debug -Platform x64"
    Write-Output "  .\Build.ps1 -All"
    Write-Output ""
    Write-Output "Output:"
    Write-Output "  Executables: Run\CMake\"
    Write-Output "  Build files: Temporary\CMake\"
}

# Clean build outputs
function Remove-BuildOutput {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Output "========================================"
    Write-Output "   Cleaning Build Outputs"
    Write-Output "========================================"

    $dirsToClean = @("Run\CMake", "Temporary\CMake")

    foreach ($dir in $dirsToClean) {
        if (Test-Path $dir) {
            if ($PSCmdlet.ShouldProcess($dir, "Remove directory")) {
                Write-Verbose "Cleaning: $dir"
                Remove-Item -Recurse -Force $dir
                Write-Output "Cleaned: $dir"
            }
        } else {
            Write-Output "Already clean: $dir"
        }
    }

    Write-Output ""
    Write-Output "Clean completed!"
}

# Interactive menu
function Show-InteractiveMenu {
    Write-Output "========================================"
    Write-Output "   CMake Build Options"
    Write-Output "========================================"
    Write-Output ""
    Write-Output "What would you like to build?"
    Write-Output ""
    Write-Output "1. Build all configurations (Debug/Release x64/x86)"
    Write-Output "2. Build Debug x64"
    Write-Output "3. Build Release x64"
    Write-Output "4. Build Debug x86"
    Write-Output "5. Build Release x86"
    Write-Output "6. Clean all outputs"
    Write-Output "7. Exit"
    Write-Output ""

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
                Write-Warning "Invalid choice. Please select 1-7."
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

    Write-Output "========================================"
    Write-Output "   Building: $targetName"
    Write-Output "========================================"

    # Check if CMake is available
    try {
        $null = cmake --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "CMake not found"
        }
        Write-Output "CMake is available"
    } catch {
        Write-Error "CMake not found! Please install CMake first."
        Write-Output "Download from: https://cmake.org/download/"
        return $false
    }

    # Check if CMakeLists.txt exists
    if (-not (Test-Path "CMakeLists.txt")) {
        Write-Error "CMakeLists.txt not found in current directory!"
        Write-Verbose "Current directory: $(Get-Location)"
        return $false
    }

    # Create build directory
    if (Test-Path $buildDir) {
        if ($PSCmdlet.ShouldProcess($buildDir, "Remove old build directory")) {
            Write-Verbose "Cleaning old build: $buildDir"
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
        Write-Verbose "Command: cmake $($cmakeArgs -join ' ')"

        # Run CMake configure
        if ($PSCmdlet.ShouldProcess("CMake", "Configure build")) {
            $configOutput = & cmake @cmakeArgs 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-Error "Configuration failed!"
                Write-Error "CMake output: $configOutput"
                return $false
            }

            Write-Output "Configuration successful"
        }

        # Run build
        Write-Output "Building..."
        Write-Verbose "Command: cmake --build . --config $Config"

        if ($PSCmdlet.ShouldProcess("CMake", "Build project")) {
            $buildOutput = & cmake --build . --config $Config 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-Error "Build failed!"
                Write-Error "Build output: $buildOutput"
                return $false
            }

            Write-Output "Build successful: $targetName"
        }

        # Check if executable was created and copied
        $exePath = "$originalLocation\Run\CMake\$targetName.exe"
        if (Test-Path $exePath) {
            $exeSize = [math]::Round((Get-Item $exePath).Length / 1KB, 1)
            Write-Output "Executable created: Run\CMake\$targetName.exe ($exeSize KB)"
        } else {
            Write-Warning "Executable not found at: Run\CMake\$targetName.exe"
        }

        return $true

    } catch {
        Write-Error "Build failed: $($_.Exception.Message)"
        return $false
    } finally {
        Set-Location $originalLocation
    }
}

# Build all configuration
function Build-AllConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Output "========================================"
    Write-Output "   Building All Configurations"
    Write-Output "========================================"

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
    Write-Output "========================================"
    Write-Output "   Build Summary"
    Write-Output "========================================"

    foreach ($result in $results) {
        $statusIcon = if ($result.Success) { "Success" } else { "Failed" }

        Write-Output "$statusIcon $($result.Target)"
        Write-Output "   Duration: $($result.Duration.TotalSeconds.ToString('F1'))s"
    }

    Write-Output ""
    Write-Output "Results: $successCount/$totalCount builds successful"
    Write-Output "Total time: $($overallDuration.TotalSeconds.ToString('F1')) seconds"

    if ($successCount -eq $totalCount) {
        Write-Output ""
        Write-Output "All builds completed successfully!"

        # Show generated files
        $runDir = "Run\CMake"
        if (Test-Path $runDir) {
            Write-Output ""
            Write-Output "Generated executables:"
            $exeFiles = Get-ChildItem -Path $runDir -Filter "*.exe" | Sort-Object Name
            foreach ($exe in $exeFiles) {
                $size = [math]::Round($exe.Length / 1KB, 1)
                Write-Output "  $($exe.Name) ($size KB)"
            }

            Write-Output ""
            Write-Output "Directory structure:"
            Write-Output "Run\CMake\"
            Write-Output "   FirstCMake_Debug_x64.exe"
            Write-Output "   FirstCMake_Release_x64.exe"
            Write-Output "   FirstCMake_Debug_x86.exe"
            Write-Output "   FirstCMake_Release_x86.exe"
            Write-Output ""
            Write-Output "Temporary\CMake\"
            Write-Output "   FirstCMake_Debug_x64\"
            Write-Output "   FirstCMake_Release_x64\"
            Write-Output "   FirstCMake_Debug_x86\"
            Write-Output "   FirstCMake_Release_x86\"
        }
    } else {
        Write-Output ""
        Write-Warning "Some builds failed. Check the errors above."
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
            Write-Output "Build completed successfully!"
        } else {
            Write-Output ""
            Write-Error "Build failed!"
        }
        return
    }

    # Interactive mode (default)
    $choice = Show-InteractiveMenu

    switch ($choice.Mode) {
        "All" {
            Build-AllConfiguration
        }
        "Single" {
            $success = Build-SingleConfiguration -Config $choice.Config -Platform $choice.Platform
            if ($success) {
                Write-Output ""
                Write-Output "Build completed successfully!"
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
    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
    Write-Verbose "Stack trace: $($_.ScriptStackTrace)"
} finally {
    if (-not $Help -and -not ($choice.Mode -eq "Exit")) {
        Write-Output ""
        Read-Host "Press any key to exit"
    }
}