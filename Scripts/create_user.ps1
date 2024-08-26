#import AD module
$requiredModules = @('ActiveDirectory', 'powershell-yaml')

foreach ($module in $requiredModules) {
    if (Get-Module -ListAvailable -Name $requiredModules) {
        Write-Host "$module already installed on machine"
    } 
    else {
        Write-Host "$module not on machine, installing now"
        Install-Module -Name $module
    }
}

#in this section we import user data | I've used a YAML file for this example, but will make a form later
#this option allows the user to just type in the name of the file they want to use
'''
$name = Read-Host "Enter the name of the file to use"
$path = "C:\Users\Administrator\Documents\MACD YML\$name.yml"
Write-Host "Reading form file from $path..."
'''

$path = 'Scripts\john_doe.yaml'
Write-Host "Reading form file from $path..."

try {
    $yaml = ConvertFrom-Yaml (Get-Content -Raw -Path $path)
} catch {
    Write-Error "Failed to read the YAML file. Please check the file path and format."
    return
}

#in this section we create the user values and splat them for entry to the new-aduser cmdlet
$userParams = @{
    Name = $yaml.GivenName + " " + $yaml.Surname
    GivenName = $yaml.GivenName
    Surname = $yaml.Surname
    DisplayName = $yaml.givenName + " " + $yaml.Surname
    SamAccountName = $yaml.givenName[0] + $yaml.Surname
    UserPrincipalName = $yaml.UserPrincipalName
    EmailAddress = $yaml.EmailAddress
    Description = $yaml.jobTitle #in this example we'll display the job title of the user in their description field
    Office = $yaml.city #in this example we'll display the location of the user in their office field
    Department = $yaml.Department 
    Title = $yaml.jobTitle #real job title section
    Company = $yaml.company
    Manager = $yaml.manager
    #Path = $yaml.Path #OU path | leaving as default now but will add OU assignment later 
    Enabled = $false
}

#perform error checking
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