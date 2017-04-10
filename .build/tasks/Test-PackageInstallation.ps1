Import-Script Pask.Tests.Infrastructure -Package Pask

# Synopsis: Test manually the package installation
Task Test-PackageInstallation Clean, Pack-Nuspec, Push-Local, {
    $Assertion = {
        $PaskVersion = (([xml](Get-Content (Join-Path $ProjectFullPath "Pask.Test.dotCover.nuspec"))).package.metadata.dependencies.dependency | Where { $_.id -eq "Pask.Test" }).version
        Assert ((([xml](Get-Content (Join-Path $SolutionFullPath "Application.Domain\packages.config"))).packages.package | Where { $_.id -eq "Pask.Test" }).version -eq $PaskVersion) "Incorrect version of Pask.Test installed into project 'Application.Domain'"
    }

    Test-PackageInstallation -Name Pask.Test -Assertion $Assertion -InstallationTargetInfo "Install into 'Application.Domain' project"
}