#just gonna start off with a simple script that will output battery status to the CLI
#will add this to $PROFILE for startup
function Get-QuickBatteryReport {
    # spit out the battery report quickfast
    $report = Get-CimInstance -ClassName Win32_Battery
    $charge = $report.EstimatedChargeRemaining
    $status = $report.Status
    write-host "$charge% charge remaining. Status: $status."
}

#more detailed report
function Get-FullBatteryReport {
    $reportPath = "$env:TEMP\battery_report.html"   
    powercfg.exe /batteryreport #/output $reportPath
    invoke-item $reportPath
    Start-Sleep -Seconds 10
    Remove-Item -Path $reportPath-Item $reportPath
}