$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test-NUnit" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test-NUnit"
        Install-NuGetPackage -Name Pask.Test
    }

    Context "No tests" {
        BeforeAll {
            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, Test-NUnit
        }

        It "does not create the NUnit XML report" {
            Join-Path $Here "NoTests\.build\output\TestsResults\NUnit.xml" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-NUnit
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml" | Should Exist
        }

        It "runs all the tests" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml")
            $NUnitResult.'test-run'.total | Should Be 4
            $NUnitResult."test-run"."test-suite"."test-suite"."test-suite"."test-suite"."test-case".methodname | Should Be @('Test_1', 'Test_2', 'Test_3', 'Test_4')
        }
    }

    Context "Tests with a category" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-NUnit -NUnitTestSelection "cat == category2"
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml" | Should Exist
        }

        It "runs all the tests with the given category" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml")
            $NUnitResult.'test-run'.total | Should Be 2
            $NUnitResult."test-run"."test-suite"."test-suite"."test-suite"."test-suite"."test-case".methodname | Should Be @('Test_2', 'Test_4')
        }
    }

    Context "Tests excluding categories" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-NUnit -NUnitTestSelection "cat != category1 && cat != category2"
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml" | Should Exist
        }

        It "runs all the tests without the given categories" {
            [xml]$NUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml")
            $NUnitResult.'test-run'.total | Should Be 1
            $NUnitResult."test-run"."test-suite"."test-suite"."test-suite"."test-suite"."test-case".methodname | Should Be 'Test_3'
        }
    }
}