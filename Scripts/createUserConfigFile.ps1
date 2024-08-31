function Get-ADUserForm {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # init form object
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Active Directory User Information"
    $form.Size = New-Object System.Drawing.Size(400, 400)
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

    # submit button
    $submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"
    $submitButton.Location = New-Object System.Drawing.Point(260, 310)
    $submitButton.Size = New-Object System.Drawing.Size(100, 30)
    $form.Controls.Add($submitButton)

    # labels and text boxes
    $labels = @("First Name:", "Last Name:", "Phone:", "Location:", "Job Title:", "Manager:", "Division:")
    $textBoxes = @()
    $yPos = 45

    foreach ($labelText in $labels) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $labelText
        $label.Location = New-Object System.Drawing.Point(10, $yPos)
        $form.Controls.Add($label)

        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Location = New-Object System.Drawing.Point(120, $yPos)
        $textBox.Size = New-Object System.Drawing.Size(225, 20)
        $form.Controls.Add($textBox)
        $textBoxes += $textBox

        $yPos += 40
    }

    # form init
    $form.Tag = $null

    # submit button click event | return the form data
    $submitButton.Add_Click({
        # create hashtable using the text box values
        $formData = @{
            'GivenName'  = $textBoxes[0].Text
            'Surname'    = $textBoxes[1].Text
            'Phone'      = $textBoxes[2].Text
            'Location'   = $textBoxes[3].Text
            'JobTitle'   = $textBoxes[4].Text
            'Manager'    = $textBoxes[5].Text
            'Division'   = $textBoxes[6].Text
        }
        $form.Tag = $formData
        $form.Close()
    })

    # initiate the form | the pipeline should stop the function from returning cancel >> https://stackoverflow.com/questions/43211375/prevent-a-form-closing-with-form-close-returning-cancel
    $Form.ShowDialog() | Out-Null

    # return the form data
    if ($null -eq $form.Tag) {
        Write-Host "Form submission was canceled."
        return $null
    } else {
        return $form.Tag
    }
}

# get the form data | export the form data to a yaml file 
# right now the idea is to create the file locally and then upload it to the server and run the create_user.ps1 script
$formData = Get-ADUserForm
$filename = ($formData.GivenName+$formData.Surname).ToLower()
$formData | ConvertTo-Yaml | Out-File -FilePath "Scripts\Config Templates\$filename.yaml"