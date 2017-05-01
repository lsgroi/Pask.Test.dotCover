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

        It "does not create any report" {
            Join-Path $Here "NoTests\.build\output\TestResults\*.*" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec, New-dotCoverReport -dotCoverReportType "XML"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the merged dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the dotCover report" {
            $dotCoverReport = Join-Path $TestSolutionFullPath ".build\output\TestResults\dotCover.Report.xml"
            $dotCoverReport | Should Exist
            [xml]$dotCoverReportXml = Get-Content $dotCoverReport
            $Class = $dotCoverReportXml.Root.Assembly.Namespace.Type | Where { $_.Name -eq "Class" }
            $Class.Method | Measure | Select -ExpandProperty Count | Should Be 3
            $Class.Method | Where { $_.Name -eq "Method_Excluded_From_Code_Coverage_By_Custom_Attribute():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 0
            $Class.Method | Where { $_.Name -eq "Method_Covered():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 100
            $Class.Method | Where { $_.Name -eq "Method_Not_Covered():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 0
        }

        It "runs all the tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 5
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "StringSpec"} | Measure | select -ExpandProperty Count | Should Be 2
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "IntSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ObjectSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ClassSpec"} | Measure | select -ExpandProperty Count | Should Be 1
        }
    }

    Context "All tests with dotCover filters" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec, New-dotCoverReport -dotCoverReportType "XML" -dotCoverFilters "-:function=Method_Not_Covered"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the merged dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the dotCover report" {
            $dotCoverReport = Join-Path $TestSolutionFullPath ".build\output\TestResults\dotCover.Report.xml"
            $dotCoverReport | Should Exist
            [xml]$dotCoverReportXml = Get-Content $dotCoverReport
            $Class = $dotCoverReportXml.Root.Assembly.Namespace.Type | Where { $_.Name -eq "Class" }
            $Class.Method | Measure | Select -ExpandProperty Count | Should Be 2
            $Class.Method | Where { $_.Name -eq "Method_Excluded_From_Code_Coverage_By_Custom_Attribute():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 0
            $Class.Method | Where { $_.Name -eq "Method_Covered():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 100
        }

        It "runs all the tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 5
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "StringSpec"} | Measure | select -ExpandProperty Count | Should Be 2
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "IntSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ObjectSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ClassSpec"} | Measure | select -ExpandProperty Count | Should Be 1
        }
    }

    Context "All tests with dotCover attribute filters" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec, New-dotCoverReport -dotCoverReportType "XML" -dotCoverAttributeFilters "ClassLibrary.CustomExcludeFromCodeCoverageAttribute"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the merged dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\dotCover.Snapshot.dcvr" | Should Exist
        }

        It "creates the dotCover report" {
            $dotCoverReport = Join-Path $TestSolutionFullPath ".build\output\TestResults\dotCover.Report.xml"
            $dotCoverReport | Should Exist
            [xml]$dotCoverReportXml = Get-Content $dotCoverReport
            $Class = $dotCoverReportXml.Root.Assembly.Namespace.Type | Where { $_.Name -eq "Class" }
            $Class.Method | Measure | Select -ExpandProperty Count | Should Be 2
            $Class.Method | Where { $_.Name -eq "Method_Covered():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 100
            $Class.Method | Where { $_.Name -eq "Method_Not_Covered():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 0
        }

        It "runs all the tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 5
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "StringSpec"} | Measure | select -ExpandProperty Count | Should Be 2
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "IntSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ObjectSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ClassSpec"} | Measure | select -ExpandProperty Count | Should Be 1
        }
    }

    Context "Tests with tags" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec -MSpecTag "tag1,tag2"
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "runs all the tests matching the given tags" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml")
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
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml" | Should Exist
        }

        It "creates the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "runs all the tests without the given tag" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 4
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "StringSpec"} | Measure | select -ExpandProperty Count | Should Be 2
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ObjectSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ClassSpec"} | Measure | select -ExpandProperty Count | Should Be 1
        }
    }

    Context "All tests with code coverage disabled" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec -EnableCodeCoverage $false
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml" | Should Exist
        }

        It "does not create the MSpec dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.dotCover.Snapshot.dcvr" | Should Not Exist
        }

        It "runs all the tests" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 5
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "StringSpec"} | Measure | select -ExpandProperty Count | Should Be 2
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "IntSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ObjectSpec"} | Measure | select -ExpandProperty Count | Should Be 1
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ClassSpec"} | Measure | select -ExpandProperty Count | Should Be 1
        }
    }
}