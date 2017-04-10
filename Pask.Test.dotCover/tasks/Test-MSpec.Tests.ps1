$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test-MSpec" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test-MSpec"
        Install-NuGetPackage -Name Pask.Test
    }

    Context "No tests" {
        BeforeAll {
            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, Test-MSpec
        }

        It "does not create the MSpec XML report" {
            Join-Path $Here "NoTests\.build\output\TestsResults\MSpec.xml" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-MSpec
        }

        It "creates the MSpec XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml" | Should Exist
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

        It "runs all the tests without the given tag" {
            [xml]$MSpecResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestsResults\MSpec.xml")
            $MSpecResult.MSpec.assembly.concern.context | Measure | select -ExpandProperty Count | Should Be 3
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "StringSpec"} | Measure | select -ExpandProperty Count | Should Be 2
            $MSpecResult.MSpec.assembly.concern.context.name | Where { $_ -eq "ObjectSpec"} | Measure | select -ExpandProperty Count | Should Be 1
        }
    }
}