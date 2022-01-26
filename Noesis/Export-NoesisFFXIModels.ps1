#Exports a single skeletal mesh for the specified part in the CSV File.
#---Update the variables before the comment "Start of Script Functions---

#Noesis Install Path
$NoesisEXE = "D:\Utilities\Noesis\noesisv4464\Noesis.exe"

#File to open and export *Modified by the CSV file
$ffxiDataSet = 'C:\Users\trist\OneDrive\Documents\XIRemix_Resources\Noesis\HuMa_Set.ff11datset'
$exportLocation = 'D:\Utilities\Noesis\Exports'

#Dats that enable and disable lines in the DataSet. Disables export of all meshes except the one specified in the CSV file row.
$PartsToCheck = 'face', 'head', 'body', 'hands', 'legs', 'feet', 'weapon'

#Base folder for exports.
$race = 'HuMa'

#List of all the Meshes to export. 
#Part = The skeletal mesh to export (head, face, body, waist, etc.); 
#Name = Name the mesh for subfolder (ie. LeatherVest, WarriorBelt, etc.) * NO SPACES
#DatFilePath = Relative path to the dat file
$csvFilePath = 'C:\Users\trist\OneDrive\Documents\XIRemix_Resources\Noesis\FFXIModelsToExport.csv'

#Creates smooth groups and exports textures in tga format.
$commandArguments = '-rotate 180 -0 -90 -scale 90 -fbxsmoothgroups -fbxtexrelonly -fbxtexext .tga'


#
#
#
#Start of Script functions!!
$csvMeshes = Import-Csv -Path $csvFilePath -Delimiter ','

foreach ($mesh in $csvMeshes)
{
    #Prepares the  $ffxiDataSet for Noesis Export
    foreach ($part in $PartsToCheck)
    {
        if($part -eq $mesh.part)
        {
            $dat = $mesh.datFilePath
            $regex = ";{0,1}dat `"$part`" `"[a-zA-Z0-9\/._\\]*\.dat`""
            (Get-Content $ffxiDataSet) -replace $regex, "dat `"$part`" `"$dat`"" | Set-Content $ffxiDataSet
        } 
        else
        {
            $regex = ";{0,1}(dat `"$part`" `"[a-zA-Z0-9\/._\\]*.dat`")"
            (Get-Content $ffxiDataSet) -replace $regex, ';$1' | Set-Content $ffxiDataSet
        }
    }

    #Creates SubFolder
    if (!(Test-Path -Path $exportLocation\$race\$($mesh.part)\$($mesh.name)))
    {
        New-Item -Path $exportLocation\$race\$($mesh.part)\$($mesh.name) -ItemType Directory
    }

    #Runs Noesis.EXE
    Start-Process -FilePath $NoesisEXE -ArgumentList "?cmode $ffxiDataSet $exportLocation\$race\$($mesh.part)\$($mesh.name)\SK_$race`_$($mesh.name).fbx $commandArguments" -Wait
    Start-Sleep -Seconds 1
}