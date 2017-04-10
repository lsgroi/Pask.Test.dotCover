Import-Script Pask.Test -Package Pask.Test

Set-Property NUnitTestSelection -Default ""

# Synopsis: Run NUnit tests
Task Test-NUnit {
    $Assemblies = Get-TestAssemblies -TestFrameworkAssemblyName "nunit.framework"

    if ($Assemblies) {
        $NUnit = Join-Path (Get-PackageDir "NUnit.ConsoleRunner") "tools\nunit3-console.exe"
        $NUnitTestsResults = Join-Path $TestsResultsFullPath "NUnit.xml"
        
        if ($NUnitTestSelection) { 
            $Where = @("--where", $NUnitTestSelection) 
        }

        New-Directory $TestsResultsFullPath | Out-Null

        Exec { & "$NUnit" --work:"$TestsResultsFullPath" --result:"$NUnitTestsResults" $Where --noheader $Assemblies }
    } else {
        Write-BuildMessage "NUnit tests not found" -ForegroundColor "Yellow"
    }
}