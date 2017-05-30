Import-Task Restore-NuGetPackages, Clean, Build, Test-VSTest, New-Artifact, New-TestsArtifact, TestFrom-TestsArtifact, New-dotCoverReport

# Synopsis: Default task
Task . Restore-NuGetPackages, Clean, Build, Test-VSTest, New-Artifact, New-TestsArtifact, New-dotCoverReport