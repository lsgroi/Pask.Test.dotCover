Set-Property dotCoverReportName -Default "dotCover.Report"
Set-Property dotCoverReportType -Default @("HTML","XML")

# Synopsis: Merge dotCover snapshots found in the tests results directory and generate a report
Task New-dotCoverReport {
    if (-not $TestResultsFullPath -or -not (Test-Path $TestResultsFullPath)) {
        Write-BuildMessage "tests results directory not found" -ForegroundColor "Yellow"
        return;
    }

    $MergedSnapshot = Join-Path $TestResultsFullPath "dotCover.Snapshot.dcvr"
    if (Test-Path $MergedSnapshot) {
        # If the merged snapshot already exists, remove it
        Remove-PaskItem $MergedSnapshot
    }

    $Snapshots = Get-ChildItem $TestResultsFullPath -Filter "*.dcvr" | Select -ExpandProperty FullName

    if($Snapshots) {
        "`r`nMerge dotCover Snapshots"
        $dotCover = Get-dotCoverExe
        $Source = $Snapshots -join ';'
		Exec { & "$dotCover" merge /Source="$Source" /Output="$MergedSnapshot" }
        Get-ChildItem $TestResultsFullPath | Where { $_.BaseName.StartsWith($dotCoverReportName) } | ForEach { Remove-PaskItem $_.FullName }
        $dotCoverReportType | ForEach {
            $dotCoverReportExtension = if ($_ -eq "NDependXML") { "xml" } else { $_.ToLower() }
            $dotCoverReport = Join-Path $TestResultsFullPath "$dotCoverReportName.$dotCoverReportExtension"
            "`r`nGenerate dotCover $_ Report"
		    Exec { & "$dotCover" report /Source="$MergedSnapshot" /Output="$dotCoverReport" /ReportType="$_" }
        }
    } else {
        Write-BuildMessage "dotCover snapshots not found" -ForegroundColor "Yellow"
    }
}