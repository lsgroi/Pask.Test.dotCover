Import-Task Test-NUnit2 -Package Pask.Test
Import-Script Pask.Test.dotCover, Properties.dotCoverFilters -Package Pask.Test.dotCover

Set-Property NUnitFrameworkVersion -Default "4.6"
Set-Property NUnitCategory -Default ""
Set-Property NUnitExcludeCategory -Default ""

# Synopsis: Run NUnit 2.x tests
Task Test-NUnit2 {
    $Assemblies = Get-TestAssemblies -TestFrameworkAssemblyName "nunit.framework"

    if ($Assemblies) {
        $NUnit = Join-Path (Get-PackageDir "NUnit.Runners") "tools\nunit-console.exe"
        $NUnitTestsResults = Join-Path $TestsResultsFullPath "NUnit.xml"
        
        if ($NUnitCategory) { 
            $Include = "/include:$NUnitCategory"
        }

        if ($NUnitExcludeCategory) { 
            $Exclude = "/exclude:$NUnitExcludeCategory"
        }

        New-Directory $TestsResultsFullPath | Out-Null

        $dotCover = Get-dotCoverExe
        $dotCoverOutput = Join-Path $TestsResultsFullPath "NUnit.dotCover.Snapshot.dcvr"
        Remove-ItemSilently $dotCoverOutput
        $dotCoverScope = Get-dotCoverScope $Assemblies

        $NUnitAssemblies = $Assemblies -join "`"`" `"`""
        $NUnitArguments = "/work:`"`"$TestsResultsFullPath`"`" /result:`"`"$NUnitTestsResults`"`" /framework:`"`"net-$NUnitFrameworkVersion`"`" $Include $Exclude /nologo `"`"$NUnitAssemblies`"`""

        Exec { & "$dotCover" cover /TargetExecutable="$NUnit" /TargetArguments="$NUnitArguments" /Output="$dotCoverOutput" /Scope="$dotCoverScope" /Filters="`"$dotCoverFilters`"" /AttributeFilters="`"$dotCoverAttributeFilters`"" /ReturnTargetExitCode }

    } else {
        Write-BuildMessage "NUnit tests not found" -ForegroundColor "Yellow"
    }
}