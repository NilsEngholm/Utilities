#after testing out the old one I realized that it had a lot of unnecessary steps
#this script is a lite version of the createUser.ps1 script that only uses the AD module
#no need for any files on the server, probaly just a long ass pipeline

#check for AD module
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Host "AD good to go, continuing..."
}
else {
    Write-Host 'AD not installed, you may be in the wrong server'
    #break
}

#get current domain
$domainPrefix = 'test'#$adDomain.DistinguishedName.Split(",")[0] -replace "DC=", ""
$topLevelDomain = 'com'#$adDomain.DistinguishedName.Split(",")[1] -replace "DC=", ""
$domain = $domainPrefix + "." + $topLevelDomain

#read username inputs
$GivenName = Read-Host 'Enter the given name of the user'
$Surname = Read-Host 'Enter the surname of the user'

#generate SAMAccountName (username)
function New-Username {
    param (
        [Parameter(Mandatory=$true)]
        [string]$GivenName,

        [Parameter(Mandatory=$true)]
        [string]$Surname
    )
    Write-Host "Choose your username format using the examples below, the name used for the example is John Doe:"
    $userNameFormat = Read-Host "1.JDoe`n2.JohnD`n3.John.Doe`n4.JohnDoe`n5.Other/manual entry"
    if ($userNameFormat -eq 1) {
        $SAMAccountname = $GivenName[0] + $Surname
    } elseif ($userNameFormat -eq 2) {
        $SAMAccountname = $GivenName + $Surname[0]
    } elseif ($userNameFormat -eq 3) {
        $SAMAccountname = $GivenName + "." + $Surname
    } elseif ($userNameFormat -eq 4) {
        $SAMAccountname = $GivenName + $Surname
    } elseif ($userNameFormat -eq 5) {
        $SAMAccountname = Read-Host 'Enter the username'
    } else {
        Write-Host "Invalid selection, please try again"
    }
    return $SAMAccountname
}

#run the function to generate the name
$SAMAccountname = New-Username -GivenName $GivenName -Surname $Surname

#confirm the username
$confirmation = Read-Host "Generated username $SAMAccountName, is this correct? [y/n]"
while($confirmation -ne "y")
{
    if ($confirmation -eq 'n') { Write-Host "Exiting script"; break }
    $confirmation = Read-Host "Ready? [y/n]"
}

#generate email and UPN using the username
$email = "$samaccountname@$domain"
$UPN = $email

#generate userParams
$userParams = @{
    SamAccountName    = $SAMAccountname
    GivenName         = $GivenName
    Surname           = $Surname
    DisplayName       = $GivenName + " " + $Surname
    EmailAddress      = $email
    UserPrincipalName = $UPN
    Path              = "OU=Test,OU=Test OU,DC=$domainPrefix,DC=$topLevelDomain"
}

$userParams