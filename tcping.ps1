Function tcping {
       param (
              [Parameter(Position=0)][string] $Server,
              [Parameter(Position=1)][string] $Port,
              [Parameter(Position=2)][string] $VM,
              [Parameter(Position=3)][int] $TimeOut = 2
       )
       
       if($Server -eq "") { $Server = Read-Host "Server" }
       if($Port -eq "") { $Port = Read-Host "Port" }
       if($Timeout -eq "") { $Timeout = 2 }
       [int]$TimeOutMS = $TimeOut*1000
       if($VM -eq "") { $VM = Read-Host "VM" }
       $IP = [System.Net.Dns]::GetHostAddresses($Server)
       $Address = [System.Net.IPAddress]::Parse($IP)
       $Socket = New-Object System.Net.Sockets.TCPClient
       
       Write-Host "Connecting to $Address on port $Port" -ForegroundColor Cyan
       Try {
              $Connect = $Socket.BeginConnect($Address,$Port,$null,$null)
       }
       Catch {
              Restart-VM $VM -force
        Return $false
              Exit
       }

Start-Sleep -Seconds $TimeOut
       
       if ( $Connect.IsCompleted )
       {
              $Wait = $Connect.AsyncWaitHandle.WaitOne($TimeOutMS,$false)                
              if(!$Wait)
              {
                     $Socket.Close()
                     Restart-VM $VM -force
            Return $false
              }
              else
              {
                     Try {
                           $Socket.EndConnect($Connect)
                           Write-Host "$Server IS responding on port $Port. Not going to restart $VM" -ForegroundColor Green
                Return $true
                     }
                     Catch { Restart-VM $VM -force }
                     $Socket.Close()
            Return $false
              }
       }
       else
       {
              Restart-VM $VM -force

        Return $false
       }
       Write-Host ""

} 
