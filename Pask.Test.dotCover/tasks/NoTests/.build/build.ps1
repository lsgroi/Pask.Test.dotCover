Import-Task Restore-NuGetPackages, Clean, Build, Test, Test-MSpec, Test-NUnit, Test-NUnit2, Test-xUnit, New-dotCoverReport

# Synopsis: Default task
Task . Restore-NuGetPackages, Clean, Build, Test, New-dotCoverReport