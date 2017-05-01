$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test"
        Install-NuGetPackage -Name Pask.Test.dotCover
    }

    Context "No tests" {
        BeforeAll {
            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, Test, New-dotCoverReport
        }

        It "does not create any report" {
            Join-Path $Here "NoTests\.build\output\TestResults\*.*" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test, New-dotCoverReport -dotCoverReportType "XML"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml" | Should Exist
        }

        It "creates the NUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.dotCover.Snapshot.dcvr" | Should Exist
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

        It "runs all MSpec tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 5
        }

        It "runs all NUnit tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml")
            $NUnitResult.'test-run'.total | Should Be 4
        }
    }

    Context "All tests from tests artifact" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, New-Artifact, New-TestsArtifact
            (Join-Path $TestSolutionFullPath "**\bin"), (Join-Path $TestSolutionFullPath "**\obj") | Remove-ItemSilently
            Invoke-Pask $TestSolutionFullPath -Task Test, New-dotCoverReport -dotCoverReportType "XML"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml" | Should Exist
        }

        It "creates the NUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.dotCover.Snapshot.dcvr" | Should Exist
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

        It "runs all MSpec tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 5
        }

        It "runs all NUnit tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml")
            $NUnitResult.'test-run'.total | Should Be 4
        }
    }

    Context "All tests with code coverage disabled" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test -EnableCodeCoverage $false
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml" | Should Exist
        }

        It "does not create the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.dotCover.Snapshot.dcvr" | Should Not Exist
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml" | Should Exist
        }

        It "does not create the NUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.dotCover.Snapshot.dcvr" | Should Not Exist
        }

        It "runs all MSpec tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 5
        }

        It "runs all NUnit tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml")
            $NUnitResult.'test-run'.total | Should Be 4
        }
    }
}