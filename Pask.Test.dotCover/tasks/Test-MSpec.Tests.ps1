$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test-MSpec" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test-MSpec"
        Install-NuGetPackage -Name Pask.Test.dotCover
    }

    Context "No tests" {
        BeforeAll {
            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, Test-MSpec, New-dotCoverReport
        }

        It "does not create the MSpec XML report" {
            Join-Path $Here "NoTests\.build\output\TestsResults\MSpec.xml" | Should Not Exist
        }
        
        It "does not create the MSpec dotCover snapshot" {
            Join-Path $Here "NoTests\.build\output\TestsResults\MSpec.dotCover.Snapshot.dcvr" | Should Not Exist
        }

        It "does not create the merged dotCover snapshot" {
            Join-Path $Here "NoTests\.build\output\TestsResults\dotCover.Snapshot.dcvr" | Should Not Exist
        }

        It "does not create the dotCover report" {
            Join-Path $Here "NoTests\.build\output\TestsResults\dotCover.Report.xml" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec, New-dotCoverReport -dotCoverReportType "XML"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
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

        It "runs all the tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 4
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "StringSpec"} | Measure | select -ExpandProperty Count | Should Be 2
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "IntSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ObjectSpec"} | Measure | select -ExpandProperty Count | Should Be 1
        }
    }

    Context "All tests with dotCover filters" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec, New-dotCoverReport -dotCoverReportType "XML" -dotCoverFilters "-:function=Method3"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the merged dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the dotCover report" {
            $dotCoverReport = Join-Path $TestSolutionFullPath ".build\output\TestsResults\dotCover.Report.xml"
            $dotCoverReport | Should Exist
            [xml]$dotCoverReportXml = Get-Content $dotCoverReport
            $Class = $dotCoverReportXml.Root.Assembly.Namespace.Type | Where { $_.Name -eq "Class" }
            $Class.Method | Measure | Select -ExpandProperty Count | Should Be 1
            $Class.Method.Name | Should Be "Method2():bool"
        }

        It "runs all the tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 4
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "StringSpec"} | Measure | select -ExpandProperty Count | Should Be 2
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "IntSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ObjectSpec"} | Measure | select -ExpandProperty Count | Should Be 1
        }
    }

    Context "All tests with dotCover attribute filters" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec, New-dotCoverReport -dotCoverReportType "XML" -dotCoverAttributeFilters "ClassLibrary.CustomExcludeFromCodeCoverageAttribute"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the merged dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the dotCover report" {
            $dotCoverReport = Join-Path $TestSolutionFullPath ".build\output\TestsResults\dotCover.Report.xml"
            $dotCoverReport | Should Exist
            [xml]$dotCoverReportXml = Get-Content $dotCoverReport
            $Class = $dotCoverReportXml.Root.Assembly.Namespace.Type | Where { $_.Name -eq "Class" }
            $Class.Method | Measure | Select -ExpandProperty Count | Should Be 1
            $Class.Method.Name | Should Be "Method3():bool"
        }

        It "runs all the tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 4
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "StringSpec"} | Measure | select -ExpandProperty Count | Should Be 2
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "IntSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ObjectSpec"} | Measure | select -ExpandProperty Count | Should Be 1
        }
    }

    Context "Tests with tags" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec -MSpecTag "tag1,tag2"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "runs all the tests matching the given tags" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 3
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "StringSpec"} | Measure | select -ExpandProperty Count | Should Be 2
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "IntSpec"} | Measure | select -ExpandProperty Count | Should Be 1
        }
    }

    Context "Tests excluding a tag" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec -MSpecExcludeTag "tag2"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "runs all the tests without the given tag" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 3
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "StringSpec"} | Measure | select -ExpandProperty Count | Should Be 2
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ObjectSpec"} | Measure | select -ExpandProperty Count | Should Be 1
        }
    }

    Context "All tests with code coverage disabled" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec -EnableCodeCoverage $false
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml" | Should Exist
        }

        It "does not create the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.dotCover.Snapshot.dcvr" | Should Not Exist
        }

        It "runs all the tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 4
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "StringSpec"} | Measure | select -ExpandProperty Count | Should Be 2
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "IntSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ObjectSpec"} | Measure | select -ExpandProperty Count | Should Be 1
        }
    }
}