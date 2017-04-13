Set-Property dotCoverReportName -Default "dotCover.Report"
Set-Property dotCoverReportType -Default @("HTML","XML")

# Synopsis: Merge dotCover snapshops found in the tests results directory and generate a report
Task New-dotCoverReport {
    if (-not $TestsResultsFullPath -or -not (Test-Path $TestsResultsFullPath)) {
        Write-BuildMessage "tests results directory not found" -ForegroundColor "Yellow"
        return;
    }

    $MergedSnapshot = Join-Path $TestsResultsFullPath "dotCover.Snapshot.dcvr"
    if (Test-Path $MergedSnapshot) {
        # If the merged snapshot already exists, remove it
        Remove-ItemSilently $MergedSnapshot
    }

    $Snapshots = Get-ChildItem $TestsResultsFullPath -Filter "*.dcvr" | Select -ExpandProperty FullName

    if($Snapshots) {
        "`r`nMerge dotCover Snapshots"
        $dotCover = Get-dotCoverExe
        $Source = $Snapshots -join ';'
		Exec { & "$dotCover" merge /Source="$Source" /Output="$MergedSnapshot" }
        Get-ChildItem $TestsResultsFullPath | Where { $_.BaseName.StartsWith($dotCoverReportName) } | ForEach { Remove-ItemSilently $_.FullName }
        $dotCoverReportType | ForEach {
            $dotCoverReportExtension = if ($_ -eq "NDependXML") { "xml" } else { $_.ToLower() }
            $dotCoverReport = Join-Path $TestsResultsFullPath "$dotCoverReportName.$dotCoverReportExtension"
            "`r`nGenerate dotCover $_ Report"
		    Exec { & "$dotCover" report /Source="$MergedSnapshot" /Output="$dotCoverReport" /ReportType="$_" }
        }
    } else {
        Write-BuildMessage "dotCover snapshots not found" -ForegroundColor "Yellow"
    }
}