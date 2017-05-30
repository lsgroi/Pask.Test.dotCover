Import-Task Test-xUnit -Package Pask.Test

if ($EnableCodeCoverage -and $EnableCodeCoverage -eq $true) {

    Import-Script Pask.Test.dotCover, Properties.dotCoverFilters -Package Pask.Test.dotCover

    # Synopsis: Run xUnit tests
    Task Test-xUnit {
        $Assemblies = Get-TestAssemblies -TestFrameworkAssemblyName "xunit.core"

        if ($Assemblies) {
            $xUnit = Join-Path (Get-PackageDir "xunit.runner.console") "tools\xunit.console.exe"
            $xUnitTestResults = Join-Path $TestResultsFullPath "xUnit.xml"
        
            if ($xUnitTrait) { 
                $xUnitTrait | ForEach { [System.Array]$Trait += @("-trait", $_) }
            }

            if ($xUnitNoTrait) { 
                $xUnitNoTrait | ForEach { [System.Array]$NoTrait += @("-notrait", $_) }
            }

            if ($xUnitParallel) {
                $Parallel = @("-parallel", "$xUnitParallel")
            }

            if ($xUnitMaxThreads) {
                $MaxThreads = @("-maxthreads", "$xUnitMaxThreads")
            }

            New-Directory $TestResultsFullPath | Out-Null

            $dotCover = Get-dotCoverExe
            $dotCoverOutput = Join-Path $TestResultsFullPath "xUnit.dotCover.Snapshot.dcvr"
            Remove-PaskItem $dotCoverOutput
            $dotCoverScope = Get-dotCoverScope $Assemblies

            $xUnitAssemblies = $Assemblies -join "`"`" `"`""
            $xUnitArguments = "`"`"$xUnitAssemblies`"`" -xml `"`"$xUnitTestResults`"`" $Trait $NoTrait $Parallel $MaxThreads"

            #$NUnitAssemblies = $Assemblies -join "`"`" `"`""
            #$NUnitArguments = "--work:`"`"$TestResultsFullPath`"`" --result:`"`"$NUnitTestResults`"`" $Where --noheader `"`"$NUnitAssemblies`"`""

            Exec { & "$dotCover" cover /TargetExecutable="$xUnit" /TargetArguments="$xUnitArguments" /Output="$dotCoverOutput" /Scope="$dotCoverScope" /Filters="`"$dotCoverFilters`"" /AttributeFilters="`"$dotCoverAttributeFilters`"" /ReturnTargetExitCode }
        } else {
            Write-BuildMessage "NUnit tests not found" -ForegroundColor "Yellow"
        }
    }

}