Connect-ExchangeOnline

$userMailbox = "user@test.com"

$sharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox

$userAccessMailboxes = @()

#find all delegated access mailboxes
foreach ($sharedMailbox in $sharedMailboxes) {
    $permissions = Get-MailboxPermission -Identity $sharedMailbox.PrimarySmtpAddress | Where-Object { $_.User -like $userMailbox }

    if ($permissions.AccessRights -contains "FullAccess") {
        $userAccessMailboxes += $sharedMailbox.PrimarySmtpAddress
    }
}

#display list of mailboxes
if ($userAccessMailboxes.Count -gt 0) {
    Write-Host "The user $userMailbox has access to the following shared mailboxes:"
    $userAccessMailboxes | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "The user $userMailbox does not have access to any shared mailboxes."
}


foreach ($smb in $userAccessMailboxes) {
    #get permissions
    $permission = Get-MailboxPermission -Identity $smb -User $userMailbox
    
    if ($permission.AccessRights -contains "FullAccess") {
        #remove access
        Remove-MailboxPermission -Identity $smb -User $userMailbox -AccessRights FullAccess -InheritanceType All -Confirm:$false
        
        #add access back w/o automapping
        Add-MailboxPermission -Identity $smb -User $userMailbox -AccessRights FullAccess -AutoMapping:$false -InheritanceType All
        Write-Host "Automapping removed for $userMailbox on $smb."
    } else {
        Write-Host "$userMailbox does not have FullAccess permission for $smb."
    }
}

Disconnect-ExchangeOnline