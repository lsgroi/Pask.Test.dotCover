Import-Script Pask.Tests.Infrastructure -Package Pask

# Synopsis: Test manually the package installation
Task Test-PackageInstallation Clean, Pack-Nuspec, Push-Local, {
    $Assertion = {
        $PaskTestVersion = (([xml](Get-Content (Join-Path $ProjectFullPath "Pask.Test.dotCover.nuspec"))).package.metadata.dependencies.dependency | Where { $_.id -eq "Pask.Test" }).version
        Assert ((([xml](Get-Content (Join-Path $SolutionFullPath "Application.Domain\packages.config"))).packages.package | Where { $_.id -eq "Pask.Test" }).version -eq $PaskTestVersion) "Incorrect version of Pask.Test installed into project 'Application.Domain'"
        $dotCoverVersion = (([xml](Get-Content (Join-Path $ProjectFullPath "Pask.Test.dotCover.nuspec"))).package.metadata.dependencies.dependency | Where { $_.id -eq "JetBrains.dotCover.CommandLineTools" }).version
        Assert ((([xml](Get-Content (Join-Path $SolutionFullPath "Application.Domain\packages.config"))).packages.package | Where { $_.id -eq "JetBrains.dotCover.CommandLineTools" }).version -eq $dotCoverVersion) "Incorrect version of JetBrains.dotCover.CommandLineTools installed into project 'Application.Domain'"
    }

    Test-PackageInstallation -Name Pask.Test.dotCover -Assertion $Assertion -InstallationTargetInfo "Install into 'Application.Domain' project"
}