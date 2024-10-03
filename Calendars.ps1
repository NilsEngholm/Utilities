# Import the Exchange Online Management module
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline

# Get all mailboxes in the organization
$mailboxes = Get-Mailbox -ResultSize Unlimited

# Loop through each mailbox
foreach ($mailbox in $mailboxes) {
    # Retrieve folder statistics for each mailbox (including calendar folder)
    $folderStats = Get-MailboxFolderStatistics -Identity $mailbox.UserPrincipalName
        
    # Filter for the Calendar folder
    $calendarFolder = $folderStats | Where-Object { $_.FolderType -eq "Calendar" }

    # Output calendar folder details
    Write-Host "Mailbox: $($mailbox.UserPrincipalName)"
    Write-Host "Calendar Path: $($calendarFolder.FolderPath)"
    Write-Host "Calendar Folder Size: $($calendarFolder.FolderSize)"
    Write-Host "Calendar Item Count: $($calendarFolder.ItemsInFolder)" 
    Write-Host "-------------------------------"
}

$mailboxUser = "user@domain.com"           # The mailbox that contains the calendar
$targetUser = "editor@domain.com"           # The user you want to grant permissions to
$folderId = "AQMkADAwAT..."                 # The folder ID of the calendar

# Retrieve the folder statistics to find the folder path from the folder ID
$folderStats = Get-MailboxFolderStatistics -Identity $mailboxUser | Where-Object { $_.FolderId -eq $folderId }

if ($folderStats) {
    $calendarPath = $folderStats.FolderPath

    # Add editor permissions to the specified folder (calendar)
    Add-MailboxFolderPermission -Identity "$mailboxUser:$calendarPath" -User $targetUser -AccessRights Editor

    Write-Host "Editor permissions have been added for $targetUser on calendar: $calendarPath"
} else {
    Write-Warning "No folder found with the specified Folder ID: $folderId"
}