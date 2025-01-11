function gitGuiNew {
    $gitPsGui.Controls.Clear()
    $gitPsGui.Height = $screenSizeHeight + 55

    $branchNameLabel = New-Object System.Windows.Forms.Label
    $branchNameLabel.Text = 'branch name'
    $branchNameLabel.AutoSize = $true
    $branchNameLabel.Location = New-Object System.Drawing.Point((($screenSizeWidth - 150) / 2), 10)

    $branchNameInput = New-Object System.Windows.Forms.TextBox
    $branchNameInput.Width = 150
    $branchNameInput.Location = New-Object System.Drawing.Point((($screenSizeWidth - 150) / 2), 30)

    $dirLabel = New-Object System.Windows.Forms.Label
    $dirLabel.Text = 'folder location'
    $dirLabel.AutoSize = $true
    $dirLabel.Location = New-Object System.Drawing.Point((($screenSizeWidth - 150) / 2), 60)

    $dirInput = New-Object System.Windows.Forms.TextBox
    $dirInput.Width = 150
    $dirInput.Location = New-Object System.Drawing.Point((($screenSizeWidth - 150) / 2), 80)

    $repoLabel = New-Object System.Windows.Forms.Label
    $repoLabel.Text = 'repo url location'
    $repoLabel.AutoSize = $true
    $repoLabel.Location = New-Object System.Drawing.Point((($screenSizeWidth - 150) / 2), 110)

    $repoInput = New-Object System.Windows.Forms.TextBox
    $repoInput.Width = 150
    $repoInput.Location = New-Object System.Drawing.Point((($screenSizeWidth - 150) / 2), 130)

    $submit = New-Object System.Windows.Forms.Button
    $submit.Text = 'Submit'
    $submit.AutoSize = $true
    $submit.Width = 50
    $submit.Location = New-Object System.Drawing.Point((($screenSizeWidth + 30) / 2), 160)
    $submit.Add_Click({gitWriteScript -branchValue $branchNameInput.Text -repoValue $repoInput.Text -dirValue $dirInput.Text}.GetNewClosure())

    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = 'Cancel'
    $cancel.AutoSize = $true
    $cancel.Width = 50
    $cancel.Location = New-Object System.Drawing.Point((($screenSizeWidth - 140) / 2), 160)
    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

    $gitPsGui.Controls.AddRange(@($repoLabel, $repoInput, $dirLabel, $dirInput, $branchNameLabel, $branchNameInput, $submit, $cancel))
}

function gitWriteScript{
    param(
        [string]$branchValue,
        [string]$repoValue,
        [string]$dirValue
    )
    $gitFileName = "git-$branchValue.txt"
    $hashTable = @{
        dir = $dirValue
        gitUrl = $repoValue
        branchName = $branchValue
    }
    $writeFile = foreach ($i in $hashTable.GetEnumerator())
    {
        Write-Output "$($i.Key)=$($i.Value)"
    }
    $writeFile > $gitFileName
}

function gitGuiLoad {
    $gitPsGui.Controls.Clear()

    $repoName = New-Object -TypeName System.Collections.ArrayList
    $repoName.AddRange(@(Get-ChildItem git-* -Name))

    $optionBox = New-Object System.Windows.Forms.ComboBox
    $optionBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $optionBox.Items.AddRange($repoName)
    $optionBox.Width = 200
    $optionBox.Location = New-Object System.Drawing.Point((($screenSizeWidth - 200) / 2), 30)

    $pull = New-Object System.Windows.Forms.Button
    $pull.Text = 'pull'
    $pull.AutoSize = $true
    $pull.Width = 50
    $pull.Location = New-Object System.Drawing.Point((($screenSizeWidth + 80) / 2), 70)
    $pull.Add_Click({gitReadTxt -file $optionBox.Text -option 'pull'}.GetNewClosure())

    $push = New-Object System.Windows.Forms.Button
    $push.Text = 'push'
    $push.AutoSize = $true
    $push.Width = 50
    $push.Location = New-Object System.Drawing.Point((($screenSizeWidth + 80) / 2), 110)
    $push.Add_Click({gitReadTxt -file $optionBox.Text -option 'push'}.GetNewClosure())

    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = 'Cancel'
    $cancel.AutoSize = $true
    $cancel.Width = 50
    $cancel.Location = New-Object System.Drawing.Point((($screenSizeWidth - 190) / 2), 110)
    $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

    $gitPsGui.Controls.AddRange(@($optionBox, $push, $pull, $cancel))
}

function gitReadTxt {
    param (
        [string]$file,
        [string]$option
    )
    if($file){
        $hashValues = @{}
        Get-Content $file | ForEach-Object {
            $keys = $_ -split "="
            $hashValues += @{$keys[0]=$keys[1]}
        }

        if($option -eq 'push'){
            gitPush -dir $hashValues.dir -url $hashValues.gitUrl -branch $hashValues.branchName
        }
        else
        {
            gitPull -dir $hashValues.dir -url $hashValues.gitUrl -branch $hashValues.branchName
        }
    }
    else
    {
        gitGuiLoad
    }
}

function gitPush {
    param (
        [string]$dir,
        [string]$url,
        [string]$branch
    )

    $gitPsGui.Controls.Clear()

    $messageLabel = New-Object System.Windows.Forms.Label
    $messageLabel.Text = 'Message'
    $messageLabel.AutoSize = $true
    $messageLabel.Location = New-Object System.Drawing.Point((($screenSizeWidth - 50) / 2), 10)

    $message = New-Object System.Windows.Forms.TextBox
    $message.Width = 200
    $message.Location = New-Object System.Drawing.Point((($screenSizeWidth - 200) / 2), 40)

    $submit = New-Object System.Windows.Forms.Button
    $submit.Text = 'Submit'
    $submit.AutoSize = $true
    $submit.Width = 50
    $submit.Location = New-Object System.Drawing.Point((($screenSizeWidth - 50) / 2), 80)
    $submit.Add_Click({gitPushScript -dir $dir -url $url -branch $branch -Message $message.Text}.GetNewClosure())

    $gitPsGui.Controls.AddRange(@($messageLabel, $message, $submit))
}

function gitPushScript {
    param (
        [string]$dir,
        [string]$url,
        [string]$branch,
        [string]$Message
    )
    Set-Location $dir
    git add .
    git status
    $gcommit = "git commit -m '$($Message)'"
    Invoke-Expression $gcommit
    git push $url $branch
    git fetch -p
    Pause
}

function gitPull {
    param (
        [string]$dir,
        [string]$url,
        [string]$branch
    )
    $gitPsGui.Controls.Clear()

    $status = New-Object System.Windows.Forms.Label
    $status.Text = 'Updating'
    $status.AutoSize = $true
    $status.Location = New-Object System.Drawing.Point((($screenSizeWidth - 50) / 2), 70)

    Set-Location $dir
    # git pull $url $branch

    $gitPsGui.Controls.AddRange(@($status))
}

function gitGuiSetup {
    $setup.ForeColor = 'blue'
}

# Init PowerShell Gui
Add-Type -AssemblyName System.Windows.Forms

# Create a new form
$gitPsGui = New-Object system.Windows.Forms.Form

# Define the size, title and background color
$screenSizeWidth = 300
$screenSizeHeight = 180
$gitPsGui.ClientSize = "$screenSizeWidth,$screenSizeHeight"
$gitPsGui.text = "Git Script - PowerShell GUI"
$gitPsGui.BackColor = "White"
$gitPsGui.FormBorderStyle = 'FixedDialog'

$mainMenuText = New-Object System.Windows.Forms.Label
$mainMenuText.Text = "What would you like to do?"
$mainMenuText.AutoSize = $true
$mainMenuText.Location = New-Object System.Drawing.Point((($screenSizeWidth - 150) / 2), 10)

$new = New-Object System.Windows.Forms.Button
$new.Text = "New"
$new.AutoSize = $true
$new.Width = 50
$new.Location = New-Object System.Drawing.Point((($screenSizeWidth - 50) / 2), 50)
$new.Add_Click({gitGuiNew})

$load = New-Object System.Windows.Forms.Button
$load.Text = "Load"
$load.AutoSize = $true
$load.Width = 50
$load.Location = New-Object System.Drawing.Point((($screenSizeWidth - 50) / 2), 85)
$load.Add_Click({gitGuiLoad})

$setup = New-Object System.Windows.Forms.Button
$setup.Text = "Setup"
$setup.AutoSize = $true
$setup.Width = 50
$setup.Location = New-Object System.Drawing.Point((($screenSizeWidth - 50) / 2), 120)
$setup.Add_Click({gitGuiSetup})

$gitPsGui.Controls.AddRange(@($mainMenuText, $new, $load, $setup))

# Display the form
[void]$gitPsGui.ShowDialog()