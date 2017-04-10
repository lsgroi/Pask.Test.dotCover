Set-Property GitHubOwner -Value "lsgroi"
Set-Property GitHubRepo -Value $ProjectName

Import-Task Clean, Pack-Nuspec, Test-Pester, Push-Local, Version-BuildServer, Push, Test-PackageInstallation, New-GitHubRelease

# Synopsis: Default task
Task . Clean, Pack-Nuspec, Test, Push-Local

# Synopsis: Run all automated tests
Task Test Pack-Nuspec, Test-Pester

# Synopsis: Test a release
Task PreRelease Version-BuildServer, Clean, Pack-Nuspec, Test

# Synopsis: Release task
Task Release Version-BuildServer, Clean, Pack-Nuspec, Test, Push, New-GitHubRelease