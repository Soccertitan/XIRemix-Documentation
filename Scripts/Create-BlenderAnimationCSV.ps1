<#
    This script is used to rename and prepare animation files to be imported into UE.
    1. Export the animations from Noesis manually using the noefbxmulti option in Animation Output.
    2. Run this script and provide the requested parameters.
    3. Open blender and specify in the bulk import/export script the csv file generated from here. And the specific bone rename csv file.
    4. Import into UE.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$AnimationFolder,

    [Parameter(Mandatory=$false)]
    [string]$AnimationCategory
)

$ExportPath = "$PSScriptRoot\Export\$AnimationCategory`-BlenderAnimImport.csv"
$UEImportPath = "$PSScriptRoot\Export\UEImport"

$regex = "[a-zA-Z0-9\.]*\s\-\s([a-zA-Z0-9]*\.fbx)"
$regex_UB = "[a-zA-Z0-9\.]*\s\-\s([a-zA-Z0-9]*)1\.fbx"
$regex_LB = "[a-zA-Z0-9\.]*\s\-\s([a-zA-Z0-9]*)0\.fbx"

if(!(Test-Path $AnimationFolder))
{
    throw "Path <$AnimationFolder> does not exist."
}

if((Test-Path "$PSScriptRoot\Export") -eq $false)
{
    New-Item -Path "$PSScriptRoot\Export" -ItemType Directory -ErrorAction Stop
}

if((Test-Path $UEImportPath) -eq $false)
{
    New-Item -Path $UEImportPath -ItemType Directory -ErrorAction Stop
}

if ((Test-Path -Path "$UEImportPath\$AnimationCategory") -eq $false)
{
    New-Item -Path "$UEImportPath\$AnimationCategory" -ItemType Directory -ErrorAction Stop
}

#The start of the renaming of files and creating the Blender csv file.

$files = Get-ChildItem -Path "$AnimationFolder\*.fbx"

Clear-Content -Path $ExportPath -ErrorAction SilentlyContinue

foreach ($file in $files)
{
    if($file.Name -match $regex)
    {
        $fileName = $file.Name -replace $regex, "A_`$1"
        if($file.Name -match $regex_UB)
        {
            $fileName = $file.Name -replace $regex_UB, "A_`$1_UB.fbx"
        }else
        {
           $fileName = $file.Name -replace $regex_LB, "A_`$1_LB.fbx"
        }
    
        Add-Content -Value "$($file.Fullname),$UEImportPath\$AnimationCategory\$fileName" -Path $ExportPath
    }
}

if(Test-Path "$ExportPath")
{
    Write-Output "`nScript completed! $Exportpath file is ready to be used in Blender."
}
else
{
    Write-Output "`nScript Completed! No file was generated as no .fbx files existed"
}
