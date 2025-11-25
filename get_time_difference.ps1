#get time difference between host and all AD controllers
Get-Date
$ntpServers = ((Get-ADForest).Domains | foreach {Get-ADDomainController -Server $_ -Filter *} | select HostName).HostName

foreach ($server in $ntpServers) {
    try {
        $result = w32tm /monitor /computers:$server
        $offsetLine = $result | Where-Object { $_ -match "NTP:" }
        $RefIDLine = $result | Where-Object { $_ -match "RefID:" }
        $StratLine = $result | Where-Object { $_ -match "Страта:" }
        
        if ($offsetLine) {
            $offset = $offsetLine.Split(":")[1].Trim().Split(" ")[0]
            if ($RefIDLine) {$RefID = $RefIDLine.Split(":")[1].Trim()} else {$RefID = $RefIDLine}
            if ($StratLine) {$Strat = $StratLine.Split(":")[1].Trim()} else {$Strat = $StratLine}
            
            
            Write-Host "$server Offset: $offset секунд RefID:$RefID Страта:$Strat" -ForegroundColor Yellow
           
        }
    }
    catch {
        Write-Host "Ошибка при проверке $server : $($_.Exception.Message)" -ForegroundColor Red
    }
}
