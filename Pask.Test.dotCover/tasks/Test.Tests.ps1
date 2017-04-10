$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test"
        Install-NuGetPackage -Name Pask.Test
    }

    Context "No tests" {
        BeforeAll {
            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, Test
        }

        It "does not create any report" {
            Join-Path $Here "NoTests\.build\output\TestsResults\*.*" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml" | Should Exist
        }

        It "creates the NUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\NUnit.xml" | Should Exist
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