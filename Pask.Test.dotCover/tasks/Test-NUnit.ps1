Import-Task Test-MSpec -Package Pask.Test
Import-Script Pask.Test.dotCover, Properties.dotCoverFilters -Package Pask.Test.dotCover

Set-Property NUnitTestSelection -Default ""

# Synopsis: Run NUnit tests
Task Test-NUnit {
    $Assemblies = Get-TestAssemblies -TestFrameworkAssemblyName "nunit.framework"

    if ($Assemblies) {
        $NUnit = Join-Path (Get-PackageDir "NUnit.ConsoleRunner") "tools\nunit3-console.exe"
        $NUnitTestsResults = Join-Path $TestsResultsFullPath "NUnit.xml"
        
        if ($NUnitTestSelection) { 
            $Where = "--where:`"`"$NUnitTestSelection`"`""
        }

        New-Directory $TestsResultsFullPath | Out-Null

        $dotCover = Get-dotCoverExe
        $dotCoverOutput = Join-Path $TestsResultsFullPath "NUnit.dotCover.Snapshot.dcvr"
        $dotCoverScope = Get-dotCoverScope $Assemblies
        Remove-ItemSilently $dotCoverOutput

        $NUnitAssemblies = $Assemblies -join "`"`" `"`""
        $NUnitArguments = "--work:`"`"$TestsResultsFullPath`"`" --result:`"`"$NUnitTestsResults`"`" $Where --noheader `"`"$NUnitAssemblies`"`""

        Exec { & "$dotCover" cover /TargetExecutable="$NUnit" /TargetArguments="$NUnitArguments" /Output="$dotCoverOutput" /Scope="$dotCoverScope" /Filters="`"$dotCoverFilters`"" /AttributeFilters="`"$dotCoverAttributeFilters`"" /ReturnTargetExitCode }
    } else {
        Write-BuildMessage "NUnit tests not found" -ForegroundColor "Yellow"
    }
}