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
            Join-Path $Here "NoTests\.build\output\TestsResults\*.*" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test, New-dotCoverReport -dotCoverReportType "XML"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml" | Should Exist
        }

        It "creates the NUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the merged dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the dotCover report" {
            $dotCoverReport = Join-Path $TestSolutionFullPath ".build\output\TestsResults\dotCover.Report.xml"
            $dotCoverReport | Should Exist
            [xml]$dotCoverReportXml = Get-Content $dotCoverReport
            $Class = $dotCoverReportXml.Root.Assembly.Namespace.Type | Where { $_.Name -eq "Class" }
            $Class.Method.Count | Should Be 2
            $Class.Method | Where { $_.Name -eq "Method2():bool" } | Should Not BeNullOrEmpty
            $Class.Method | Where { $_.Name -eq "Method3():bool" } | Should Not BeNullOrEmpty
        }

        It "runs all MSpec tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 4
        }

        It "runs all NUnit tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml")
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
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml" | Should Exist
        }

        It "creates the NUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the merged dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the dotCover report" {
            $dotCoverReport = Join-Path $TestSolutionFullPath ".build\output\TestsResults\dotCover.Report.xml"
            $dotCoverReport | Should Exist
            [xml]$dotCoverReportXml = Get-Content $dotCoverReport
            $Class = $dotCoverReportXml.Root.Assembly.Namespace.Type | Where { $_.Name -eq "Class" }
            $Class.Method.Count | Should Be 2
            $Class.Method | Where { $_.Name -eq "Method2():bool" } | Should Not BeNullOrEmpty
            $Class.Method | Where { $_.Name -eq "Method3():bool" } | Should Not BeNullOrEmpty
        }

        It "runs all MSpec tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 4
        }

        It "runs all NUnit tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml")
            $NUnitResult.'test-run'.total | Should Be 4
        }
    }
}