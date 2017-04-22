Import-Task Test-MSpec -Package Pask.Test

if ($EnableCodeCoverage -and $EnableCodeCoverage -eq $true) {

    Import-Script Pask.Test.dotCover, Properties.dotCoverFilters -Package Pask.Test.dotCover

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

            $dotCover = Get-dotCoverExe
            $dotCoverOutput = Join-Path $TestsResultsFullPath "MSpec.dotCover.Snapshot.dcvr"
            Remove-ItemSilently $dotCoverOutput
            $dotCoverScope = Get-dotCoverScope $Assemblies

            $MSpecAssemblies = $Assemblies -join "`"`" `"`""
            $MSpecArguments = "--xml `"`"$MSpecTestsResults`"`" $Include $Exclude --progress `"`"$MSpecAssemblies`"`""

            Exec { & "$dotCover" cover /TargetExecutable="$MSpec" /TargetArguments="$MSpecArguments" /Output="$dotCoverOutput" /Scope="$dotCoverScope" /Filters="`"$dotCoverFilters`"" /AttributeFilters="`"$dotCoverAttributeFilters`"" /ReturnTargetExitCode }
        } else {
            Write-BuildMessage "MSpec tests not found" -ForegroundColor "Yellow"
        }
    }

}