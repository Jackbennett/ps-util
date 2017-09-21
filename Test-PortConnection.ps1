function Test-PortConnection {
    param(
     [String]$ComputerName="localhost",
     [Int16]$Port=8080
     ,[ValidateSet('TCP','UDP')]
     [string]$Type='TCP'
    )
    $Status = [PSCustomObject]@{
            'ComputerName' = $Computername
            'Port' = $Port
            'Type' = $Type
            'Open' = $Null
        }

    switch ($Type) {
        'UDP'   { $socket = new-object System.Net.Sockets.UdpClient }
        Default { $socket = new-object System.Net.Sockets.TcpClient }
    }

    try {
        $socket.Connect($ComputerName, $port)
    } catch [System.Net.Sockets.SocketException] {
        if($PSItem.Exception -match "actively refused"){
            $Status.Open = $false
        }
        if($PSItem.Exception -match "No such host is known"){
            Write-Warning "No Host: $ComputerName"
        }
    } catch {
        Throw $PSItem
    }

    if($Type -eq 'UDP'){
        UDPTestData($socket)
    }

    if ($socket.Connected) {
        $Status.Open = $True
    }

    $socket.Close()
    $socket.Dispose()

    Write-Output $Status
}

function UDPTestData($Socket){
    $Enc = New-Object System.Text.ASCIIEncoding
    $byte = $Enc.GetBytes('teststring')
    $socket.Client.ReceiveTimeout = 200
    $socket.Send($byte, $byte.length) > $null #Do not return data length
    $Endpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any, 0)
    try {
        $Recieve = $socket.Receive([ref]$Endpoint)
    } catch {
        return $psitem
    }
}
