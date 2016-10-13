function GenerateForm { 

#region Import the Assemblies 
[reflection.assembly]::loadwithpartialname(“System.Windows.Forms”) | Out-Null 
[reflection.assembly]::loadwithpartialname(“System.Drawing”) | Out-Null 
#endregion

#region Generated Form Objects 
$ToolBoxForm = New-Object System.Windows.Forms.Form 
$ValidateInstall = New-Object System.Windows.Forms.Button 
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState 
#endregion Generated Form Objects

#———————————————- 
#Generated Event Script Blocks 
#———————————————- 
#Provide Custom Code for events specified in PrimalForms. 
$handler_ValidateInstall_Click= 
{ 
#TODO: Place custom script here

}

$OnLoadForm_StateCorrection= 
{#Correct the initial state of the form to prevent the .Net maximized form issue 
$ToolBoxForm.WindowState = $InitialFormWindowState 
}

#———————————————- 
#region Generated Form Code 
$ToolBoxForm.Text = “OutSystems ToolBox - Experts Team" 
$ToolBoxForm.Name = “Tool Box” 
$ToolBoxForm.DataBindings.DefaultDataSourceUpdateMode = 0 
$System_Drawing_Size = New-Object System.Drawing.Size 
$System_Drawing_Size.Width = 365 
$System_Drawing_Size.Height = 55 
$ToolBoxForm.ClientSize = $System_Drawing_Size

$ValidateInstall.TabIndex = 0 
$ValidateInstall.Name = “ValidateInstall” 
$System_Drawing_Size = New-Object System.Drawing.Size 
$System_Drawing_Size.Width = 240 
$System_Drawing_Size.Height = 23 
$ValidateInstall.Size = $System_Drawing_Size 
$ValidateInstall.UseVisualStyleBackColor = $True

$ValidateInstall.Text = “Validate Installation Pre-Requirements”

$System_Drawing_Point = New-Object System.Drawing.Point 
$System_Drawing_Point.X = 13 
$System_Drawing_Point.Y = 13 
$ValidateInstall.Location = $System_Drawing_Point 
$ValidateInstall.DataBindings.DefaultDataSourceUpdateMode = 0 
$ValidateInstall.add_Click($handler_ValidateInstall_Click)

$ToolBoxForm.Controls.Add($ValidateInstall)

#endregion Generated Form Code

#Save the initial state of the form 
$InitialFormWindowState = $ToolBoxForm.WindowState 
#Init the OnLoad event to correct the initial state of the form 
$ToolBoxForm.add_Load($OnLoadForm_StateCorrection) 
#Show the Form 
$ToolBoxForm.ShowDialog()| Out-Null

} #End Function

#Call the Function 
GenerateForm 
