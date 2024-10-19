#after testing out the old one I realized that it had a lot of unnecessary steps
#this script is a lite version of the createUser.ps1 script that only uses the AD module
#no need for any files on the server, probably just a long ahh pipeline

'''
#check for AD module
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Host "AD good to go, continuing..."
}
else {
    Write-Host ''AD not installed, you may be in the wrong server''
    break
}
'''
#fn to titleize names
Function Format-Name {
    param (
        [string]$name
    )

    # Trim spaces, convert to lowercase, and then capitalize the first letter
    $trimmedName = $name.Trim()
    if ($trimmedName.Length -gt 0) {
        $formattedName = $trimmedName.Substring(0, 1).ToUpper() + $trimmedName.Substring(1).ToLower()
        return $formattedName
    } else {
        return $null
    }
}

#change domain to match DC domain
$domain = 'example.com'

#############################
### Get user info section ###
#############################

#enter user first & last name
$givenName = Read-Host "Enter the new users first/given name"
$givenName = Format-Name -name $givenName
$surname = Read-Host "Enter the new users last name/surname"
$surname = Format-Name -name $surname

#enter job title | in this case we'll throw the job title in the description as well
$jobTitle = Read-Host "Enter the user's job title"

#location
$location = Read-Host "Enter the user's location"

#phone number
$phone = Read-Host "Enter the user's phone number"

#manager
$manager = Read-Host "Enter the name or username of the new user's manager"

#identify the account we're copying
$copiedUser = Read-Host "Enter the name or username of the user we're copying permissions/info from"

#division
$department = Read-Host = "Enter the division/department of the user" 

###################################
### End of user info entry zone ###
###################################

###########################################
### Generate values using provided info ###
###########################################

#generate SAMAccountName, email, UPN
$SAMAccountName = ($givenName[0] + $surname).ToLower()

$email = ("$SAMAccountName@$domain").ToLower()

$UPN = $email

#######################################
### End of value generation section ###
#######################################

