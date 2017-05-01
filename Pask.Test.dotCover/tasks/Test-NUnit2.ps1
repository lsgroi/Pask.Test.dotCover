Import-Task Test-NUnit2 -Package Pask.Test

if ($EnableCodeCoverage -and $EnableCodeCoverage -eq $true) {

    Import-Script Pask.Test.dotCover, Properties.dotCoverFilters -Package Pask.Test.dotCover

    # Synopsis: Run NUnit 2.x tests
    Task Test-NUnit2 {
        $Assemblies = Get-TestAssemblies -TestFrameworkAssemblyName "nunit.framework"

        if ($Assemblies) {
            $NUnit = Join-Path (Get-PackageDir "NUnit.Runners") "tools\nunit-console.exe"
            $NUnitTestResults = Join-Path $TestResultsFullPath "NUnit.xml"
        
            if ($NUnitCategory) { 
                $Include = "/include:$NUnitCategory"
            }

            if ($NUnitExcludeCategory) { 
                $Exclude = "/exclude:$NUnitExcludeCategory"
            }

            New-Directory $TestResultsFullPath | Out-Null

            $dotCover = Get-dotCoverExe
            $dotCoverOutput = Join-Path $TestResultsFullPath "NUnit.dotCover.Snapshot.dcvr"
            Remove-ItemSilently $dotCoverOutput
            $dotCoverScope = Get-dotCoverScope $Assemblies

            $NUnitAssemblies = $Assemblies -join "`"`" `"`""
            $NUnitArguments = "/work:`"`"$TestResultsFullPath`"`" /result:`"`"$NUnitTestResults`"`" /framework:`"`"net-$NUnitFrameworkVersion`"`" $Include $Exclude /nologo `"`"$NUnitAssemblies`"`""

            Exec { & "$dotCover" cover /TargetExecutable="$NUnit" /TargetArguments="$NUnitArguments" /Output="$dotCoverOutput" /Scope="$dotCoverScope" /Filters="`"$dotCoverFilters`"" /AttributeFilters="`"$dotCoverAttributeFilters`"" /ReturnTargetExitCode }

        } else {
            Write-BuildMessage "NUnit tests not found" -ForegroundColor "Yellow"
        }
    }

}