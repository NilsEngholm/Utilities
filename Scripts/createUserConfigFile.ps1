function Get-ADUserForm {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # init form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Active Directory User Information"
    $form.Size = New-Object System.Drawing.Size(450, 500)
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

    # init TabControl
    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Size = New-Object System.Drawing.Size(420, 350)
    $tabControl.Location = New-Object System.Drawing.Point(10, 10)

    # create pages
    $tabPage1 = New-Object System.Windows.Forms.TabPage
    $tabPage1.Text = "Basic Information"

    $tabPage2 = New-Object System.Windows.Forms.TabPage
    $tabPage2.Text = "Copy User/Manager Info"

    # add pages using TabPages.Add method
    $tabControl.TabPages.Add($tabPage1)
    $tabControl.TabPages.Add($tabPage2)
    $form.Controls.Add($tabControl)

    # submit button
    $submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"
    $submitButton.Location = New-Object System.Drawing.Point(300, 400)
    $submitButton.Size = New-Object System.Drawing.Size(100, 30)
    $form.Controls.Add($submitButton)

    # labels and text boxes for Basic Information (First Tab)
    $labelsPage1 = @("First Name:", "Last Name:", "Phone:", "Location:", "Job Title:", "Department:")
    $textBoxesPage1 = @()
    $yPos = 20

    foreach ($labelText in $labelsPage1) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $labelText
        $label.Location = New-Object System.Drawing.Point(10, $yPos)
        $tabPage1.Controls.Add($label)

        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Location = New-Object System.Drawing.Point(120, $yPos)
        $textBox.Size = New-Object System.Drawing.Size(225, 20)
        $tabPage1.Controls.Add($textBox)
        $textBoxesPage1 += $textBox

        $yPos += 40
    }

    # labels and text boxes for copy info (Second Tab)
    $labelsPage2 = @("Copied User:", "Manager:")
    $textBoxesPage2 = @()
    $yPos = 20

    foreach ($labelText in $labelsPage2) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $labelText
        $label.Location = New-Object System.Drawing.Point(10, $yPos)
        $tabPage2.Controls.Add($label)

        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Location = New-Object System.Drawing.Point(120, $yPos)
        $textBox.Size = New-Object System.Drawing.Size(225, 20)
        $tabPage2.Controls.Add($textBox)
        $textBoxesPage2 += $textBox

        $yPos += 40
    }

    # submit button click event
    $submitButton.Add_Click({
        # create hashtable
        $formData = @{
            'GivenName'      = $textBoxesPage1[0].Text
            'Surname'        = $textBoxesPage1[1].Text
            'Phone'          = $textBoxesPage1[2].Text
            'Location'       = $textBoxesPage1[3].Text
            'JobTitle'       = $textBoxesPage1[4].Text
            'Department'        = $textBoxesPage1[5].Text
            'Copied User'     = $textBoxesPage2[0].Text
            'Manager'     = $textBoxesPage2[1].Text
#            'Email'          = $textBoxesPage2[2].Text
#            'OfficeLocation' = $textBoxesPage2[3].Text
#            'WorkPhone'      = $textBoxesPage2[4].Text
        }
        $form.Tag = $formData
        $form.Close()
    })

    # show form
    $Form.ShowDialog() | Out-Null

    # reutrn form data
    if ($null -eq $form.Tag) {
        Write-Host "Form submission was canceled."
        return $null
    } else {
        return $form.Tag
    }
}

# output form data to config file | using YAML because it's my current favorite
$formData = Get-ADUserForm
if ($null -ne $formData) {
    $filename = ($formData.GivenName + $formData.Surname).ToLower()
    $formData | ConvertTo-Yaml | Out-File -FilePath "Scripts\Config Templates\$filename.yaml"
}