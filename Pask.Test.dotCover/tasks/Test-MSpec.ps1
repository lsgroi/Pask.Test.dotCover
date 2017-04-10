Import-Script Pask.Test -Package Pask.Test

Set-Property MSpecTag -Default ""
Set-Property MSpecExcludeTag -Default ""

# Synopsis: Run MSpec tests
Task Test-MSpec {
    $Assemblies = Get-TestAssemblies -TestFrameworkAssemblyName "Machine.Specifications"

    if ($Assemblies) {
        $MSpec = Join-Path (Get-PackageDir "Machine.Specifications.Runner.Console") "tools\mspec-clr4.exe"
        $MSpecTestsResults = Join-Path $TestsResultsFullPath "MSpec.xml"
        
        if ($MSpecTag) { 
            $Include = @("--include", $MSpecTag) 
        }

        if ($MSpecExcludeTag) { 
            $Exclude = @("--exclude", $MSpecExcludeTag)
        }

        New-Directory $TestsResultsFullPath | Out-Null

        Exec { & "$MSpec" --xml "$MSpecTestsResults" $Include $Exclude --progress $Assemblies }
    } else {
        Write-BuildMessage "MSpec tests not found" -ForegroundColor "Yellow"
    }
}