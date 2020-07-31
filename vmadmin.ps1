#Script for managing VM's from vSphere using PowerCLI
#Written by FKouhai
#Ideas
#Menu 
#OPtions for v0.1 
#List VM's
#Clone Vm's
#List Hosts
#Move VM's between hosts
#Take snapshots
#Delete Snapshots
#Revert a snapshot on a VM

$reply = Read-Host "Enter the vcenter/vsphere server URL"


$conexion = Connect-VIServer -Server $reply -Protocol https

if ($conexion -eq $true) {

    Write-Host "Successfully logged in "

}
else {
    exit 0
}



function menu {
    Write-Host "Choose an option"
    Write-Host "1. List VM's"
    Write-Host "2. Clone VM "
    Write-Host "3. List Hosts"
    Write-Host "4. Move VM to a host"
    Write-Host "5. Take snapshot"
    Write-Host "6. Delete snapshot"
    Write-Host "7. Revert VM's snapshot"
    Write-Host "8. Find VM"
    $op = Read-Host ""

    switch ($op) {
    
        "1" { list-vm }
        "2" { clone-vm }
        "3" { list-host }
        "4" { move-to-host }
        "5" { take-snapshot }
        "6" { del-snapshot }
        "7" { revert-snapshot }
        "8" { find-vm }
    
    }


}

function list-vm {
    Write-Host "Do you want to list all the VM's(a) or list the VM's of a certain host(b)"
    $rep = Read-Host
    if ($rep -eq "a") {
        Get-VM
    }

    elseif ($rep -eq "b") {

        Write-Host $(Get-VMHost | select-object  name | format-list)
        $hos = Read-Host "Type the host"
        get-vm -Location $hos

    }
    else {
        Write-Host  "Bye"
    }


}

function clone-vm {
    Write-Host "Listing data stores"

    Get-Datastore

    Write-Host  "listing Hosts" 

    Get-VMHost | select name | format-list

    $nombreVM = Read-Host "VM's name to clone"
    $servidor = Read-Host "Host's name "
    $ds = Read-Host "Data store's name"
    $vmclon = Read-Host "Cloned VM name's"

    Get-VM $nombreVM | New-VM -VMHost $servidor -Datastore $ds -OSCustomizationSpec ClientSpec -Name $vmclon 

}

function list-host {

    Get-VMHost | select Name, State, ConnectionState, Numcpu, cpuusagemhz, cputotalmhz, memoryusagegb, memorytotalgb | format-list
}

function move-to-host {
    Write-Host  "listing Hosts" 

    Get-VMHost | select name

    $nombremv = Read-Host "VM to move"
    $destHost = Read-Host "Host to move the vm"
    Move-VM -VM $nombremv -Destination $destHost

}

function take-snapshot {
    $mavirt = Read-Host "VM name "
    $nomsc = Read-Host "Snapshot name"
    $respuesta = Read-Host "Do you wanna keep the memory state(Y/N)?"
    if ($respuesta -eq "No" -or $respuesta -eq "NO" -or $respuesta -eq "no" -or $respuesta -eq "n"-or $respuesta -eq "N") {
        Write-Host "Taking snapshot"
        New-Snapshot -VM $mavirt -Name $nomsc -Memory $false 
        
    }elseif($respuesta -eq "Yes" -or $respuesta -eq "YES" -or $respuesta -eq "yes" -or $respuesta -eq "y"-or $respuesta -eq "Y") {
        Write-Host "Taking snapshot"
        New-Snapshot -VM $mavirt -Name $nomsc -Memory $true 
    }else {
      take-snapshot
    }

}

function del-snapshot {
    list-vm
    $maq=Read-Host "VM name"
    get-vm $maq | get-snapshost | Select-Object vm, name, description, created, sizegb
    $sc = Read-Host "Snapshot to delete"
    get-vm $maq | remove-snapshot -Snapshot  $sc

}

function revert-snapshot {
    list-snaps
    $snap = Read-Host "Snapshot to revert"
    Restore-VMSnapshot -Name $snap -VMName $maq 

}

function list-snaps{
    list-vm
    $maq = Read-Host "VM name"
     get-vm $maq | get-snapshost | Select-Object vm, name, description, created, sizegb
     return $maq
}

while ($true) {
    menu    
}

