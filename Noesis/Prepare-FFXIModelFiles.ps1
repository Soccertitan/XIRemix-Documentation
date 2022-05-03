<#
    This script is the almagamation of Export-NoesisFFXIModles.ps1 and Prepare-BlenderUEFiles.ps1.

    The purpose of the script is to do all the steps required to export Noesis FFXI models and textures. Rename them appropriately and dump them into predetermined folders.
    A user of this script shouldn't need to change anything. Run the file and supply the argurments.

    A template for the $ffxiModelCSV file will be available in the same directory.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$NoesisExe,

    [Parameter(Mandatory=$true)]
    [string]$ffxiModelCSVFilePath,

    [Parameter(Mandatory=$true)]
    [string]$DatRootFolder,

    [Parameter(Mandatory=$true)]
    [ValidateSet('HuMa', 'HuFe', 'ElMa', 'ElFe', 'Taru', 'Galka', 'Mithra')]
    $Race
)

#Dats that enable and disable lines in the DataSet. Disables export of all meshes except the one specified in the CSV file row.
$PartsToCheck = 'face', 'head', 'body', 'hands', 'legs', 'feet', 'weapon'

#Creates smooth groups and exports textures in tga format.
$commandArguments = '-rotate 180 -0 -90 -scale 90 -fbxsmoothgroups -fbxtexrelonly -fbxtexext .tga'

$ExportPath = "$PSScriptRoot\_Export\$Race"
$UEImportPath = "$PSScriptRoot\_Export\UEImport"
$BlenderImportCSV = "$Race`-BlenderImport.csv"
$FF11DatSetTemplate = "$PSScriptRoot\FFXIDatSetTemplate.ff11datset"
$FF11DatSetReference = "$PSScriptRoot\$Race\$Race`_BulkSet.ff11datset"

#The skeleton DAT files for each playable character.
[string]$SkeletonDAT
Switch($Race)
{
    'HuMa' {$SkeletonDAT = "ROM\27\82.dat"}
    'HuFe' {$SkeletonDAT = "ROM\32\58.dat"}
    'ElMa' {$SkeletonDAT = "ROM\37\31.dat"}
    'ElFe' {$SkeletonDAT = "ROM\42\4.dat"}
    'Taru' {$SkeletonDAT = "ROM\46\93.dat"}
    'Galka' {$SkeletonDAT = "ROM\56\59.dat"}
    'Mithra' {$SkeletonDAT = "ROM\51\89.dat"}
}

Write-Output "The script has started. Sit back grab a coffee and wait for it to finish."

if((Test-Path $DatRootFolder\$SkeletonDat) -eq $false)
{
    throw "Unable to find $Race's skeleton DAT. Please check the path $DatRootFolder\$SkeletonDat"
}

if((Test-Path $FF11DatSetTemplate) -eq $false)
{
    throw "Unable to find the template $FF11DatSetTemplate"
}

if((Test-Path "$PSScriptRoot\$Race") -eq $false)
{
    New-Item -Path "$PSScriptRoot\$Race" -ItemType Directory -ErrorAction Stop
}

#Sets the path to search for DAT files.
$regex = ";{0,1}setPathAbs `"[a-zA-Z0-9:\\\-_\.\/]*`""
(Get-Content $FF11DatSetTemplate) -replace $regex, "setPathAbs `"$DatRootFolder`"" | Out-File -FilePath $FF11DatSetReference -ErrorAction Stop -Force

#Sets the correct skeleton Dat for the character.
$regex = ";{0,1}dat `"__skeleton`" `"[a-zA-Z0-9:\\\-_\.\/]*`""
(Get-Content $FF11DatSetReference) -replace $regex, "dat `"__skeleton`" `"$SkeletonDAT`"" | Set-Content $FF11DatSetReference -ErrorAction Stop


#Start of exporting of Meshes through Noesis!
if((Test-Path $NoesisExe) -eq $false)
{
    throw "Unable to find the Noesis Executable at $NoesisExe"
}

if((Test-Path $ffxiModelCSVFilePath) -eq $false)
{
    throw "Unable to find the reference FFXI Model CSV File $ffxiModelCSVFilePath"
}

$csvMeshes = Import-Csv -Path $ffxiModelCSVFilePath -Delimiter ','

foreach ($mesh in $csvMeshes)
{
    #Prepares the  $ffxiDataSet for Noesis Export
    $partReference

    foreach ($part in $PartsToCheck)
    {
        if($part -eq $mesh.part)
        {
            $partReference = $part
            $dat = $mesh.datFilePath
            $regex = ";{0,1}dat `"$part`" `"[a-zA-Z0-9\/._\\]*\.dat`""
            (Get-Content $FF11DatSetReference) -replace $regex, "dat `"$part`" `"$dat`"" | Set-Content $FF11DatSetReference
        } 
        else
        {
            $regex = ";{0,1}(dat `"$part`" `"[a-zA-Z0-9\/._\\]*.dat`")"
            (Get-Content $FF11DatSetReference) -replace $regex, ';$1' | Set-Content $FF11DatSetReference
        }
    }

    #Creates SubFolder
    if (!(Test-Path -Path $ExportPath\$($mesh.part)\$($mesh.name)))
    {
        New-Item -Path $ExportPath\$($mesh.part)\$($mesh.name) -ItemType Directory
    }

    $fbxFile = "$ExportPath\$($mesh.part)\$($mesh.name)\SK_$Race`_$($mesh.name).fbx"

    #Runs Noesis.EXE
    Start-Process -FilePath $NoesisExe -ArgumentList "?cmode $FF11DatSetReference $fbxFile $commandArguments" -Wait
    Start-Sleep -Seconds 1

    <#
    Prepares the files to be imported into Blender and Unreal Engine.
    #>
    Get-Item -Path "$ExportPath\$($mesh.part)\$($mesh.name)\__flat_*.png" -ErrorAction SilentlyContinue | Remove-Item -ErrorAction SilentlyContinue

    $pngFiles = Get-ChildItem -Path "$ExportPath\$($mesh.part)\$($mesh.name)\*.png"
    $itemName = "$Race`_$($mesh.name)"
    $number = 1

    if (Test-Path -Path $fbxFile -ErrorAction SilentlyContinue)
    {
        Add-Content -Value "$fbxFile,$UEImportPath\$partReference\SK_$Race`_$($mesh.name).fbx" -Path "$PSScriptRoot\_Export\$BlenderImportCSV"
    }

    #Renames the png files.
    foreach ($pngFile in $pngFiles)
    {
        if (!(Test-Path "$UEImportPath\$partReference" -ErrorAction SilentlyContinue))
        {
            New-Item -Path "$UEImportPath\$partReference" -ItemType Directory
        }

        if ($pngFiles.count -ge 2)
        {
            #Rename-Item -Path "$($pngFile.FullName)" -NewName "T_$itemName`_$number.png" -ErrorAction Continue
            Copy-Item -Path $pngFile.FullName -Destination "$UEImportPath\$partReference\T_$itemName`_$number.png" -ErrorAction Continue
            $number++
        }
        else
        {
            #Rename-Item -Path "$($pngFile.FullName)" -NewName "T_$item.png" -ErrorAction Continue
            Copy-Item -Path $pngFile.FullName -Destination "$UEImportPath\$partReference\T_$itemName.png" -ErrorAction Continue
        }
    }
}

Write-Output "Script completed successfully!"