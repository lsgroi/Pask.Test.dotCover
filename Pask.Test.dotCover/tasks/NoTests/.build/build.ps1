Import-Task Restore-NuGetPackages, Clean, Build, Test, Test-NUnit2, New-dotCoverReport

# Synopsis: Default task
Task . Restore-NuGetPackages, Clean, Build, Test, New-dotCoverReport