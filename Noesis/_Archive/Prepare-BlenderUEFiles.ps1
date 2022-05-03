# This script renames and copies the PNG files generated from the Export-NoesisFFXIModels.ps1 to a folder for Unreal Engine to import.
# It also creates a csv file to be used in a Blender process to automatically rename all the bones of the skeleton appropriately. And then it exports those
# fbx files to the same directly as the Unreal Engine import folder. 
#!! This script can only be run for once race at a time.

#Noesis Export Folder
$race = 'HuMa'
$folderPath = "D:\Utilities\Noesis\Exports\$race"

#Import folder paths and file names
$UEImportFolder = "D:\Utilities\UEImports\$race"
$BlenderImportPath = "D:\Utilities\BlenderImport"
$BlenderImportCSV = "$race`-Imports.csv"

#
#
#Starts Scripting Actions!
#
#

#Creates the folder and csv for blender. !Overwrites any existing csv file.
if (!(Test-Path $BlenderImportPath))
{
    New-Item $BlenderImportPath -ItemType Directory
}
New-Item -Path $BlenderImportPath -Name $BlenderImportCSV -ItemType File -Force


#Get's all the fbx and pngs in the folder path recursively. Then renames them and preps for UE Import and BlenderCSV file.
$folders = Get-ChildItem -Path $folderPath -Directory -Recurse

foreach ($folder in $folders)
{
    Get-Item "$($folder.FullName)\__flat_*.png" -ErrorAction SilentlyContinue | Remove-Item -ErrorAction SilentlyContinue
    
    $fbxFile = Get-ChildItem -Path "$($folder.FullName)\*.fbx"
    $pngFiles = Get-ChildItem -Path "$($folder.FullName)\*.png"
    
    $item = $fbxFile.BaseName -replace 'SK_([a-z]*)', '$1'
    $part = $folder.FullName -replace '[a-z0-9\\:\s]+\\([a-z0-9]+)\\[a-z0-9_\s]+$', '$1'

    $number = 1

    if (Test-Path -Path $fbxFile.FullName -ErrorAction SilentlyContinue)
    {
        Add-Content -Value "$($fbxFile.FullName),$UEImportFolder\$part\$($fbxFile.Name)" -Path "$BlenderImportPath\$BlenderImportCSV"
    }

    foreach ($pngFile in $pngFiles)
    {
        if (!(Test-Path "$UEImportFolder\$part" -ErrorAction SilentlyContinue))
        {
            New-Item -Path "$UEImportFolder\$part" -ItemType Directory
        }

        if ($pngFiles.count -ge 2)
        {
            Rename-Item -Path "$($pngFile.FullName)" -NewName "T_$item`_$number.png" -ErrorAction Continue
            Copy-Item -Path "$($folder.FullName)\T_$item`_$number.png" -Destination "$UEImportFolder\$part" -ErrorAction Continue
            $number++
        }
        else
        {
            Rename-Item -Path "$($pngFile.FullName)" -NewName "T_$item.png" -ErrorAction Continue
            Copy-Item -Path "$($folder.FullName)\T_$item.png" -Destination "$UEImportFolder\$part" -ErrorAction Continue
        }
    }
}