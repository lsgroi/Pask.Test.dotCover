Import-Task Test-VSTest -Package Pask.Test

if ($EnableCodeCoverage -and $EnableCodeCoverage -eq $true) {

    Import-Script Pask.Test.dotCover, Properties.dotCoverFilters -Package Pask.Test.dotCover

    # Synopsis: Run tests via VSTest.Console
    Task Test-VSTest {
        $Assemblies = Get-TestAssemblies

        if ($Assemblies) {
            New-Directory $TestResultsFullPath | Out-Null

            if ($VSTestCaseFilterExpression) {
                $VSTestCaseFilterOption = "/TestCaseFilter:`"`"{0}`"`"" -f $VSTestCaseFilterExpression
            }

            if ($VSTestPlatform) {
                $VSTestPlatformOption = "/Platform:`"`"{0}`"`"" -f $VSTestPlatform
            }

            if ($VSTestFramework) {
                $VSTestFrameworkOption = "/Framework:`"`"{0}`"`"" -f $VSTestFramework
            }

            if ($VSTestSettingsFile -and (Test-Path $VSTestSettingsFile)) {
                $VSTestSettingsFileOption = "/Settings:`"`"{0}`"`"" -f $VSTestSettingsFile
            }

            $dotCover = Get-dotCoverExe
            $dotCoverOutput = Join-Path $TestResultsFullPath "VSTest.dotCover.Snapshot.dcvr"
            Remove-PaskItem $dotCoverOutput
            $dotCoverScope = Get-dotCoverScope $Assemblies

            $VSTestAssemblies = $Assemblies -join "`"`" `"`""
            $VSTestArguments = "`"`"$VSTestAssemblies`"`" /TestAdapterPath:`"`"$(Get-PackagesDir)`"`" /Parallel /Logger:`"`"$VSTestLogger`"`" $VSTestCaseFilterOption $VSTestPlatformOption $VSTestFrameworkOption $VSTestSettingsFileOption"

            Exec { & "$dotCover" cover /TargetExecutable="$(Get-VSTest)" /TargetArguments="$VSTestArguments" /TargetWorkingDir="$TestResultsFullPath" /Output="$dotCoverOutput" /Scope="$dotCoverScope" /Filters="`"$dotCoverFilters`"" /AttributeFilters="`"$dotCoverAttributeFilters`"" /ReturnTargetExitCode }

            $VSTestResultsFullPath = Join-Path $TestResultsFullPath "TestResults"
            if (Test-Path $VSTestResultsFullPath) {
                Move-Item -Path (Join-Path $VSTestResultsFullPath "*") $TestResultsFullPath
                Remove-PaskItem $VSTestResultsFullPath
            }
        } else {
            Write-BuildMessage "Tests not found" -ForegroundColor "Yellow"
        }
    }

}