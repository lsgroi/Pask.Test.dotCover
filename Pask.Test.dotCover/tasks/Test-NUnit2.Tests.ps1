$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test-NUnit2" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test-NUnit2"
        Install-NuGetPackage -Name Pask.Test.dotCover
    }

    Context "No tests" {
        BeforeAll {
            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, Test-NUnit2, New-dotCoverReport
        }

        It "does not create any report" {
            Join-Path $Here "NoTests\.build\output\TestResults\*.*" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-NUnit2, New-dotCoverReport -dotCoverReportType "XML"
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
            $Class.Method | Measure | Select -ExpandProperty Count | Should Be 3
            $Class.Method | Where { $_.Name -eq "Method_Excluded_From_Code_Coverage_By_Custom_Attribute():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 0
            $Class.Method | Where { $_.Name -eq "Method_Covered():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 100
            $Class.Method | Where { $_.Name -eq "Method_Not_Covered():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 0
        }

        It "runs all the tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml")
            $NUnitResult.'test-results'.total | Should Be 5
            $TestCaseName = @('ClassLibrary.UnitTests.Tests.Test_1','ClassLibrary.UnitTests.Tests.Test_2','ClassLibrary.AcceptanceTests.Tests.Test_3', 'ClassLibrary.AcceptanceTests.Tests.Test_4', 'ClassLibrary.AcceptanceTests.Tests.Test_5')
            $NUnitResult.'test-results'.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-case'.name | Should Be $TestCaseName
        }
    }

    Context "All tests with dotCover filters" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-NUnit2, New-dotCoverReport -dotCoverReportType "XML" -dotCoverFilters "-:function=Method_Not_Covered"
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
            $Class.Method | Measure | Select -ExpandProperty Count | Should Be 2
            $Class.Method | Where { $_.Name -eq "Method_Excluded_From_Code_Coverage_By_Custom_Attribute():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 0
            $Class.Method | Where { $_.Name -eq "Method_Covered():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 100
        }

        It "runs all the tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml")
            $NUnitResult.'test-results'.total | Should Be 5
            $TestCaseName = @('ClassLibrary.UnitTests.Tests.Test_1','ClassLibrary.UnitTests.Tests.Test_2','ClassLibrary.AcceptanceTests.Tests.Test_3', 'ClassLibrary.AcceptanceTests.Tests.Test_4', 'ClassLibrary.AcceptanceTests.Tests.Test_5')
            $NUnitResult.'test-results'.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-case'.name | Should Be $TestCaseName
        }
    }

    Context "All tests with dotCover attribute filters" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-NUnit2, New-dotCoverReport -dotCoverReportType "XML" -dotCoverAttributeFilters "ClassLibrary.CustomExcludeFromCodeCoverageAttribute"
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
            $Class.Method | Measure | Select -ExpandProperty Count | Should Be 2
            $Class.Method | Where { $_.Name -eq "Method_Covered():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 100
            $Class.Method | Where { $_.Name -eq "Method_Not_Covered():bool" } | Select -ExpandProperty CoveragePercent -First 1 | Should Be 0
        }

        It "runs all the tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml")
            $NUnitResult.'test-results'.total | Should Be 5
            $TestCaseName = @('ClassLibrary.UnitTests.Tests.Test_1','ClassLibrary.UnitTests.Tests.Test_2','ClassLibrary.AcceptanceTests.Tests.Test_3', 'ClassLibrary.AcceptanceTests.Tests.Test_4', 'ClassLibrary.AcceptanceTests.Tests.Test_5')
            $NUnitResult.'test-results'.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-case'.name | Should Be $TestCaseName
        }
    }

    Context "Tests with categories" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-NUnit2 -NUnitCategory "category1,category2"
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml" | Should Exist
        }

        It "creates the NUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "runs all the tests with the given categories" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml")
            $NUnitResult.'test-results'.total | Should Be 3
            $TestCaseName = @('ClassLibrary.UnitTests.Tests.Test_1','ClassLibrary.UnitTests.Tests.Test_2','ClassLibrary.AcceptanceTests.Tests.Test_4')
            $NUnitResult.'test-results'.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-case'.name | Should Be $TestCaseName
        }
    }

    Context "Tests excluding a category" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-NUnit2 -NUnitExcludeCategory "category1"
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml" | Should Exist
        }

        It "creates the NUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "runs all the tests without the given category" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml")
            $NUnitResult.'test-results'.total | Should Be 4
            $TestCaseName = @('ClassLibrary.UnitTests.Tests.Test_2','ClassLibrary.AcceptanceTests.Tests.Test_3','ClassLibrary.AcceptanceTests.Tests.Test_4' ,'ClassLibrary.AcceptanceTests.Tests.Test_5')
            $NUnitResult.'test-results'.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-case'.name | Should Be $TestCaseName
        }
    }

    Context "All tests with code coverage disabled" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-NUnit2 -EnableCodeCoverage $false
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml" | Should Exist
        }

        It "does not create the NUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.dotCover.Snapshot.dcvr" | Should Not Exist
        }

        It "runs all the tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\NUnit.xml")
            $NUnitResult.'test-results'.total | Should Be 5
            $TestCaseName = @('ClassLibrary.UnitTests.Tests.Test_1','ClassLibrary.UnitTests.Tests.Test_2','ClassLibrary.AcceptanceTests.Tests.Test_3', 'ClassLibrary.AcceptanceTests.Tests.Test_4', 'ClassLibrary.AcceptanceTests.Tests.Test_5')
            $NUnitResult.'test-results'.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-case'.name | Should Be $TestCaseName
        }
    }
}