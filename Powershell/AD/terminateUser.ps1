#get the username of the terminated user
$terminatedUser = Read-Host "Type the username of the user you're looking to terminate"

function loading {
    for ($a=0; $a -le 100; $a++) {
        Write-Host -NoNewLine "`r$a% complete"
        Start-Sleep -Milliseconds 15
      }
      Write-Host #ends the line after loop      
}

#check if user exists then confirm the correct user
try {
    Get-ADUser -Identity $terminatedUser
    $confirm = Read-Host "User $terminatedUser found, type y to pull group membership"
    if ($confirm -ne "y" -or $confirm -ne "Y") {
        Write-Host "Termination cancelled"
        return
    }
} catch {
    Write-Error "Failed to find user $terminatedUser. Please check the user name and try again."
    return
}

#get terminated user's group membership for exporting later
$groupMembership = Get-ADPrincipalGroupMembership $terminatedUser | Select-Object name | ft
$groupMembership
Read-Host "Grabbed group membership for $terminatedUser. Press Enter to disable account"

#disable user account
try {
    Set-ADUser -Identity $terminatedUser -Enabled $false
    Read-Host "User $terminatedUser disabled successfully, press Enter to change account attributes/OU"
} catch {
    Write-Error "Failed to disable user $terminatedUser. Please check the user name and try again."
    return
}

#change account attributes
$currentDate = (Get-Date)
$finalTerminationDate = ($currentDate.AddDays(90)).ToString("MMMM dd, yyyy")
try {
    Set-ADUser -Identity $terminatedUser -Description "$finalTerminationDate - Delete"
    Set-ADObject -Identity $user.DistinguishedName -Remove @{Proxyaddresses="$($user.smtp)"}
    Set-ADAccountPassword -Identity $terminatedUser -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "Bonnetts1398!" -Force)

    Read-Host "User $terminatedUser attributes changed successfully, press Enter to remove group membership"
} catch {
    Write-Error "Failed to change user $terminatedUser attributes. Please check the user name and try again."
    return
}