#after testing out the old one I realized that it had a lot of unnecessary steps
#this script is a lite version of the createUser.ps1 script that only uses the AD module
#no need for any files on the server, probaly just a long ass pipeline

#check for AD module
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Host "AD good to go, continuing..."
}
else {
    Write-Host 'AD not installed, you may be in the wrong server'
    break
}

#fn to titleize names
function FormatName {
    param (
        [string]$inputString
    )
    #trim it
    $inputString.Trim()
    #checking for double names like 'mary ann'
    if ($inputString -like "* *") {
        Write-Host "string contains spaces"
        $words = $inputString -split " "
        $formattedWords = $words | ForEach-Object { 
            $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() 
        }
        return $formattedWords.Trim() -join " "
    }
    #for normal, single word names
    else {
        $formattedWord = $inputString.Substring(0,1).ToUpper() + $inputString.Substring(1).ToLower()
        return $formattedWord
    }
}

$GivenName = "nIls"
$newGivenName = FormatName($GivenName)
$newGivenName