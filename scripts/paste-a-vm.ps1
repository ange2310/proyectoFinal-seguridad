function Paste-VM {
    param(
        [Parameter(Mandatory)] [string]$VM,
        [Parameter(ValueFromPipeline=$true)] [string]$Texto
    )
    $env:PATH += ";C:\Program Files\Oracle\VirtualBox"
    foreach ($linea in ($Texto -split "`r?`n")) {
        if ($linea -ne "") {
            VBoxManage controlvm $VM keyboardputstring "$linea" | Out-Null
        }
        # Enter (scancode 1c = press, 9c = release)
        VBoxManage controlvm $VM keyboardputscancode 1c 9c | Out-Null
        Start-Sleep -Milliseconds 150
    }
}
