$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test-VSTest" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test-VSTest"
        Install-NuGetPackage -Name Pask.Test.dotCover
    }

    Context "No tests" {
        BeforeAll {
            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, Test-VSTest, New-dotCoverReport -dotCoverReportType "XML"
        }

        It "does not create the test report" {
            Join-Path $Here "NoTests\.build\output\TestResults\*.trx" | Should Not Exist
        }

        It "creates empty dotCover report" {
            $dotCoverReport = Join-Path $Here "NoTests\.build\output\TestResults\dotCover.Report.xml"
            $dotCoverReport | Should Exist
            [xml]$dotCoverReportXml = Get-Content $dotCoverReport
            $dotCoverReportXml.Root.TotalStatements | Should Be 0
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-VSTest, New-dotCoverReport -dotCoverReportType "XML"
        }

        It "creates the test report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\*.trx" | Should Exist
        }

        It "creates the VSTest dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\VSTest.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the merged dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the dotCover report" {
            $dotCoverReport = Join-Path $TestSolutionFullPath ".build\output\TestResults\dotCover.Report.xml"
            $dotCoverReport | Should Exist
            [xml]$dotCoverReportXml = Get-Content $dotCoverReport
            $Class = $dotCoverReportXml.Root.Assembly.Namespace.Type | Where { $_.Name -eq "Class" }
            $Class.Method | Measure | Select -ExpandProperty Count | Should Be 4
            $Class.Method | Where { $_.Name -eq "Method_Excluded_From_Code_Coverage_By_Custom_Attribute():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 0
            $Class.Method | Where { $_.Name -eq "Method_Covered_By_MSpec():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 100
            $Class.Method | Where { $_.Name -eq "Method_Covered_By_NUnit():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 100
            $Class.Method | Where { $_.Name -eq "Method_Not_Covered():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 0
        }

        It "runs all the tests" {
            [xml]$TestResult = Get-Content -Path (Get-Item -Path (Join-Path $TestSolutionFullPath ".build\output\TestResults\*.trx")).FullName
            $TestResult.TestRun.ResultSummary.Counters.passed | Should Be 9
        }
    }

    Context "All tests from tests artifact" {
        BeforeAll {
            # Arrange
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, New-Artifact, New-TestsArtifact
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary.UnitTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary.UnitTests\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.AcceptanceTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.AcceptanceTests\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.IntegrationTests\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ApplicationTests\ClassLibrary.IntegrationTests\obj")
            
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Test-VSTest, New-dotCoverReport -dotCoverReportType "XML" -TestFromArtifact $true
        }

        It "creates the test report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\*.trx" | Should Exist
        }

        It "creates the VSTest dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\VSTest.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the merged dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the dotCover report" {
            $dotCoverReport = Join-Path $TestSolutionFullPath ".build\output\TestResults\dotCover.Report.xml"
            $dotCoverReport | Should Exist
            [xml]$dotCoverReportXml = Get-Content $dotCoverReport
            $Class = $dotCoverReportXml.Root.Assembly.Namespace.Type | Where { $_.Name -eq "Class" }
            $Class.Method | Measure | Select -ExpandProperty Count | Should Be 4
            $Class.Method | Where { $_.Name -eq "Method_Excluded_From_Code_Coverage_By_Custom_Attribute():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 0
            $Class.Method | Where { $_.Name -eq "Method_Covered_By_MSpec():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 100
            $Class.Method | Where { $_.Name -eq "Method_Covered_By_NUnit():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 100
            $Class.Method | Where { $_.Name -eq "Method_Not_Covered():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 0
        }

        It "runs all the tests" {
            [xml]$TestResult = Get-Content -Path (Get-Item -Path (Join-Path $TestSolutionFullPath ".build\output\TestResults\*.trx")).FullName
            $TestResult.TestRun.ResultSummary.Counters.passed | Should Be 9
        }
    }

    Context "All tests with code coverage disabled" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-VSTest -EnableCodeCoverage $false
        }

        It "creates the test report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\*.trx" | Should Exist
        }

        It "does not create any dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\*.dcvr" | Should Not Exist
        }

        It "runs all the tests" {
            [xml]$TestResult = Get-Content -Path (Get-Item -Path (Join-Path $TestSolutionFullPath ".build\output\TestResults\*.trx")).FullName
            $TestResult.TestRun.ResultSummary.Counters.passed | Should Be 9
        }
    }
}