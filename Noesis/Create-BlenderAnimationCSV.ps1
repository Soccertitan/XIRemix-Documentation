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

    [Parameter(Mandatory=$true)]
    [string]$Race,

    [Parameter(Mandatory=$false)]
    [string]$AnimationCategory
)

$ExportPath = "$PSScriptRoot\_Export\$Race`-BlenderAnimImport.csv"
$UEImportPath = "$PSScriptRoot\_Export\UEImport"

$regex = "[a-zA-Z0-9\.]*\s\-\s([a-zA-Z0-9]*\.fbx)"

if(!(Test-Path $AnimationFolder))
{
    throw "Path <$AnimationFolder> does not exist."
}

if((Test-Path "$PSScriptRoot\_Export") -eq $false)
{
    New-Item -Path "$PSScriptRoot\_Export" -ItemType Directory -ErrorAction Stop
}

#The start of the renaming of files and creating the Blender csv file.

$files = Get-ChildItem -Path "$AnimationFolder\*.fbx"

if($AnimationCategory.Length -ge 1)
{
    $AnimationCategory = "_$AnimationCategory"
}

foreach ($file in $files)
{
    if($file.Name -match $regex)
    {
        $fileName = $file.Name -replace $regex, "A_$Race$AnimationCategory`_`$1"
        Rename-Item -Path $file -NewName $fileName -ErrorAction Continue
    
        if(Test-Path -Path "$AnimationFolder\$fileName")
        {
            Add-Content -Value "$AnimationFolder\$fileName,$UEImportPath\$fileName" -Path $ExportPath
        }
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
