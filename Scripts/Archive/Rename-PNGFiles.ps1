#Noesis Export Folder
$folderPath = 'D:\Utilities\Noesis\Exports\HuMa'
$race = 'HuMa'

$folders = Get-ChildItem -Path $folderPath -Directory -Recurse

foreach ($folder in $folders)
{
    $fbxFile = Get-ChildItem -Path "$($folder.FullName)\*.fbx"
    $pngFiles = Get-ChildItem -Path "$($folder.FullName)\*.png"
    
    $number = 1

    foreach ($pngFile in $pngFiles)
    {
        Rename-Item -Path "$($pngFile.FullName)" -NewName "T_$race_$($fbxFile.BaseName)_$number.png" -ErrorAction Continue
        $number++
    }
}