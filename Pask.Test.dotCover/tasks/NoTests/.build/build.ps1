Import-Task Restore-NuGetPackages, Clean, Build, Test, Test-NUnit2, Test-VSTest, New-dotCoverReport

# Synopsis: Default task
Task . Restore-NuGetPackages, Clean, Build, Test, New-dotCoverReport