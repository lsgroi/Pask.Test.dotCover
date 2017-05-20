<#
.SYNOPSIS 
   Gets the dotCover executable

.OUTPUTS <string>
   Full name
#>
function script:Get-dotCoverExe {
    Join-Path (Get-PackageDir "JetBrains.dotCover.CommandLineTools") "tools\dotCover.exe"
}

<#
.SYNOPSIS 
   Gets the scope of assemblies whose information should be added to the coverage snapshot

.PARAMETER Assemblies <string[]>
   Full name of test assemblies

.PARAMETER TestNamePattern <string> = $TestNamePattern
   Regex pattern to identify tests in the solution

.OUTPUTS <string>
   Semicolon separated list of assemblies in scope (full name)

.NOTE
   By default, when the coverage snapshot is ready, it only includes information on assemblies that were loaded for analysis, 
   i.e. the assemblies that were not filtered out and that have tests. This can make the overall coverage percentage incorrect.
   This function would define the scope of assemblies whose information should be added to the snapshot.
#>
function script:Get-dotCoverScope {
    param([string[]]$Assemblies, $TestNamePattern = $TestNamePattern)

    if (-not $Assemblies) {
        return;
    }

    # NuGet packages assemblies to exclude from the scope
    $PackageBaseName = Get-ChildItem -Path $(Get-PackagesDir) -Recurse -File -Include "*.dll" `
                        | Sort -Property BaseName -Unique `
                        | Select -ExpandProperty BaseName

    # Search scope assemblies within all projects build output directory
    $ScopeSearchFullPath = Get-SolutionProjects | Select -ExpandProperty Name | Get-ProjectBuildOutputDir | Where { Test-Path $_ }

    # Search scope assemblies in the artifact directory
    if (Test-Path $ArtifactFullPath) {
        $ScopeSearchFullPath += @($ArtifactFullPath)        
    }
	
    # Search scope assemblies in the tests assemblies directory
    $ScopeSearchFullPath += $Assemblies | Split-Path

    # Return filtered list of assemblies in scope
    return ($ScopeSearchFullPath | Get-ChildItem -Recurse -File -Include @("*.dll","*.exe") `
            | Where { $_.BaseName -notmatch  $TestNamePattern } `
            | Where { $PackageBaseName -notcontains $_.BaseName } `
            | Where { (Split-Path (Split-Path $_.FullName) -Leaf) -ne "roslyn" } `
            | Sort -Property BaseName -Unique `
            | Select -ExpandProperty FullName) -Join ";"
}