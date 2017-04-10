Import-Script Pask.Test -Package Pask.Test

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

        Exec { & "$NUnit" /work:"$TestsResultsFullPath" /result:"$NUnitTestsResults" /framework:"net-$NUnitFrameworkVersion" $Include $Exclude /nologo $Assemblies }
    } else {
        Write-BuildMessage "NUnit tests not found" -ForegroundColor "Yellow"
    }
}