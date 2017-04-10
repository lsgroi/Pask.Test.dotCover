$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test-NUnit2" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test-NUnit2"
        Install-NuGetPackage -Name Pask.Test
    }

    Context "No tests" {
        BeforeAll {
            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, Test-NUnit2
        }

        It "does not create the NUnit XML report" {
            Join-Path $Here "NoTests\.build\output\TestsResults\NUnit.xml" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-NUnit2
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml" | Should Exist
        }

        It "runs all the tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml")
            $NUnitResult.'test-results'.total | Should Be 4
            $TestCaseName = @('ClassLibrary.UnitTests.Tests.Test_1','ClassLibrary.UnitTests.Tests.Test_2','ClassLibrary.AcceptanceTests.Tests.Test_3', 'ClassLibrary.AcceptanceTests.Tests.Test_4')
            $NUnitResult.'test-results'.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-case'.name | Should Be $TestCaseName
        }
    }

    Context "Tests with categories" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-NUnit2 -NUnitCategory "category1,category2"
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml" | Should Exist
        }

        It "runs all the tests with the given categories" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml")
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
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml" | Should Exist
        }

        It "runs all the tests without the given category" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml")
            $NUnitResult.'test-results'.total | Should Be 3
            $TestCaseName = @('ClassLibrary.UnitTests.Tests.Test_2','ClassLibrary.AcceptanceTests.Tests.Test_3','ClassLibrary.AcceptanceTests.Tests.Test_4')
            $NUnitResult.'test-results'.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-suite'.results.'test-case'.name | Should Be $TestCaseName
        }
    }
}