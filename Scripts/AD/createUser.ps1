#set-executionpolicy remotesigned -Scope CurrentUser
#import AD module
$requiredModules = @('ActiveDirectory', 'powershell-yaml', 'get-culture')

foreach ($module in $requiredModules) {
    if (Get-Module -ListAvailable -Name $requiredModules) {
        Write-Host "$module already installed on machine"
    } 
    else {
        Write-Host "$module not on machine, installing now"
        Install-Module -Name $module
    }
}

#import culture info module for title casing
$textInfo = (get-culture).TextInfo

#verify domain info 
$adDomain = Get-ADDomain
$domainPrefix = $adDomain.DistinguishedName.Split(",")[0] -replace "DC=", ""
$topLevelDomain = $adDomain.DistinguishedName.Split(",")[1] -replace "DC=", ""
$domain = $domainPrefix + "." + $topLevelDomain
Read-Host "Current AD domain: @$domain | Press enter to continue"

#in this section we import user data | I've used a YAML file for this example, but will make a form later
#this option allows the user to just type in the name of the file they want to use

$name = Read-Host "Enter the name of the file to use"
$path = "Scripts\\Config Templates\\$name.yaml"
Write-Host "Reading form file from $path"

try {
    $yaml = ConvertFrom-Yaml (Get-Content -Raw -Path $path)
} catch {
    Write-Error "Failed to read the config file. Please check the file path and format."
    return
}

#in this section we create the user values and splat them for entry to the new-aduser cmdlet | I've used the textinfo class to make the names title case but it's not necessary
#this does not inculde the password, UPN, and group assignments | we will set that later
$userParams = @{
    Name = $textinfo.ToTitleCase($yaml.GivenName + " " + $yaml.Surname)
    GivenName = $textinfo.ToTitleCase($yaml.GivenName)
    Surname = $textinfo.ToTitleCase($yaml.Surname)
    SamAccountName = ($yaml.GivenName[0] + $yaml.Surname).ToLower()
    DisplayName = $textInfo.ToTitleCase(($yaml.givenName + " " + $yaml.Surname))
    EmailAddress = (($yaml.GivenName[0] + $yaml.Surname) + "@$domain").ToLower()
    Description = $textinfo.ToTitleCase($yaml.jobTitle) #in this example we'll display the job title of the user in their description field
    Office = $textinfo.ToTitleCase($yaml.city) #in this example we'll display the location of the user in their office field
    OfficePhone = $yaml.phone
    Department = $textinfo.ToTitleCase($yaml.Department) 
    Title = $textinfo.ToTitleCase($yaml.jobTitle) #real job title section
    Company = $textinfo.ToTitleCase($yaml.company)
    Manager = $yaml.manager #not title cased as this will use the samaccountname of the manager
    Path = "OU=SBS Users,OU=,DC=$domainPrefix,DC=$topLevelDomain"
    Enabled = $false #this is set to false by default, the user will be enabled later
}

$userParams

#add the UPN to the userParams | in this case we're using the email address as the UPN | this can be changed to a different format as needed
$userParams.UserPrincipalName = $userParams.EmailAddress
$userParams.UserPrincipalName
#perform duplicate check using samaccountname
Write-Host "Checking if user $($userParams.SamAccountName) already exists..."
try {
    Get-ADUser -Identity $userParams.SamAccountName
    $UserExists = $true
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException] {
    $UserExists = $false
}
if ($UserExists -eq $true) {
    Write-Warning "User $($userParams.SamAccountName) already exists. Please check that you are using the correct information."
    return
} else {
    Read-Host "User account check done. Press Enter to continue"
}

#in this section we create the user
try {
    New-ADUser @userParams
} catch {
    Write-Error "Failed to create user $($userParams.SamAccountName). Please check the information provided."
    return
}

Write-Host "User $($userParams.SamAccountName) created successfully."

#copy group membership from another user
$newUser = Get-ADUser -Identity $userParams.SamAccountName
$sourceUser = $yaml.copiedUser
if ($sourceUser) {
    $sourceUserMemberOf = Get-ADUser -Identity $sourceUser -Properties MemberOf | Select-Object -ExpandProperty MemberOf
    foreach ($group in $sourceUserMemberOf) {
        Read-Host "Adding user to $group..."
        Add-ADGroupMember -Identity $group -Members $newUser
        Write-Host "User $($userParams.SamAccountName) added successfully to $group."
    }
} else {
    Write-Warning "Source user not found. Group membership not copied, check spelling?"
}

#add proxy address
Read-Host "Press Enter to continue with proxy address addition"
#add proxy address
try {
    $proxyAddress = "SMTP:$($userParams.UserPrincipalName)"
    Set-ADUser $newUser -Add @{proxyAddresses = $proxyAddress}
    Write-Host "Proxy address $proxyAddress added successfully to $($userParams.SamAccountName)."
} catch {
    Write-Error "Failed to add the proxy address. Please check the user details and your permissions."
}