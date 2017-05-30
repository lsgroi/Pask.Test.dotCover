$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Test-xUnit" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "Test-xUnit"
        Install-NuGetPackage -Name Pask.Test.dotCover
    }

    Context "No tests" {
        BeforeAll {
            # Act
            Invoke-Pask (Join-Path $Here "NoTests") -Task Restore-NuGetPackages, Clean, Build, Test-xUnit, New-dotCoverReport
        }

        It "does not create any report" {
            Join-Path $Here "NoTests\.build\output\TestResults\*.*" | Should Not Exist
        }
    }

    Context "All tests" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-xUnit, New-dotCoverReport -dotCoverReportType "XML"
        }

        It "creates the xUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml" | Should Exist
        }

        It "creates the xUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.dotCover.Snapshot.dcvr" | Should Exist
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
            [xml]$xUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml")
            ($xUnitResult.assemblies.assembly.total | Measure -Sum).Sum | Should Be 5
            $xUnitResult.assemblies.assembly.collection.test.method | Sort | Should Be @('Test_1', 'Test_2', 'Test_3', 'Test_4', 'Test_5')
        }
    }

    Context "All tests with dotCover filters" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-xUnit, New-dotCoverReport -dotCoverReportType "XML" -dotCoverFilters "-:function=Method_Not_Covered"
        }

        It "creates the xUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml" | Should Exist
        }

        It "creates the xUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.dotCover.Snapshot.dcvr" | Should Exist
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
            [xml]$xUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml")
            ($xUnitResult.assemblies.assembly.total | Measure -Sum).Sum | Should Be 5
            $xUnitResult.assemblies.assembly.collection.test.method | Sort | Should Be @('Test_1', 'Test_2', 'Test_3', 'Test_4', 'Test_5')
        }
    }

    Context "All tests with dotCover attribute filters" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-xUnit, New-dotCoverReport -dotCoverReportType "XML" -dotCoverAttributeFilters "ClassLibrary.CustomExcludeFromCodeCoverageAttribute"
        }

        It "creates the xUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml" | Should Exist
        }

        It "creates the xUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.dotCover.Snapshot.dcvr" | Should Exist
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
            [xml]$xUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml")
            ($xUnitResult.assemblies.assembly.total | Measure -Sum).Sum | Should Be 5
            $xUnitResult.assemblies.assembly.collection.test.method | Sort | Should Be @('Test_1', 'Test_2', 'Test_3', 'Test_4', 'Test_5')
        }
    }

    Context "Tests with traits" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-xUnit -xUnitTrait @( "category=category1", "category=category2" )
        }

        It "creates the xUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml" | Should Exist
        }

        It "creates the xUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "runs all the tests with the given traits" {
            [xml]$xUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml")
            ($xUnitResult.assemblies.assembly.total | Measure -Sum).Sum | Should Be 3
            $xUnitResult.assemblies.assembly.collection.test.method | Sort | Should Be @('Test_1', 'Test_2', 'Test_4')
        }
    }

    Context "Tests without traits" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-xUnit -xUnitNoTrait @( "category=category1", "category=category2" )
        }

        It "creates the xUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml" | Should Exist
        }

        It "creates the xUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.dotCover.Snapshot.dcvr" | Should Exist
        }

        It "runs all the tests without the given traits" {
            [xml]$xUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml")
            ($xUnitResult.assemblies.assembly.total | Measure -Sum).Sum | Should Be 2
            $xUnitResult.assemblies.assembly.collection.test.method | Sort | Should Be @('Test_3', 'Test_5')
        }
    }

    Context "All tests with code coverage disabled" {
        BeforeAll {
            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Test-xUnit -EnableCodeCoverage $false
        }

        It "creates the xUnit XML report" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml" | Should Exist
        }

        It "does not create the xUnit dotCover snapshot" {
            Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.dotCover.Snapshot.dcvr" | Should Not Exist
        }

        It "runs all the tests" {
            [xml]$xUnitResult = Get-Content (Join-Path $TestSolutionFullPath ".build\output\TestResults\xUnit.xml")
            ($xUnitResult.assemblies.assembly.total | Measure -Sum).Sum | Should Be 5
            $xUnitResult.assemblies.assembly.collection.test.method | Sort | Should Be @('Test_1', 'Test_2', 'Test_3', 'Test_4', 'Test_5')
        }
    }
}