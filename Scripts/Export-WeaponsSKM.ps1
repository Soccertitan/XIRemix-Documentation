<#
The script bulk exports the skeletal meshes for weapons for the races.
#>

# Use the CSV file that contains the weapons of choice. 
$Weapons = Get-Content "D:\Utilities\AltanaView\List\PC\HumeF\Sub.csv"
# The ff11datset that Noesis uses to export the .fbx.
$DatSet = "D:\Utilities\Noesis\noesisv4472\ffxi\humefemale.ff11datset"
$exportDir = "D:\Utilities\Noesis\Exports\HumeF\SubHand"

$NoesisExe = 'D:\Utilities\Noesis\noesisv4472\Noesis64.exe'
$NoesisArgs = '-noanims -notex -ff11bumpdir normals -ff11keepnames 3 -ff11noshiny -ff11hton 16 -ff11optimizegeo -ff11keepnames -fbxtexrelonly -fbxtexext .png -rotate 180 0 270 -scale 100'

$datRegex = '([\d]*\/[\d]*)[\s\S\d\D\w\W]*'
$itemNameRegex = '[\d\D\/]*,([\d\D\w\W\s\S]*)'
#The regex used to find and replace the appropriate weapon dat file.
$datSetRegex = 'dat "MainHand" [\s\S\d\D\w\W]*dat"'

#Start of exporting of Meshes through Noesis!
if((Test-Path $NoesisExe) -eq $false)
{
    throw "Unable to find the Noesis Executable at $NoesisExe"
}

$skipEntry = $false
$subFolder
foreach ($item in $Weapons)
{
    if ($item -match '@' -and $item -inotmatch 'Hand')
    {
        $skipEntry = $false
        $subFolder = $item -replace '.([\d\D\w\W\s\S]*)', '$1'
        continue
    }
    elseif ($item -match '@')
    {
        $skipEntry = $true
        continue
    }

    if (!$skipEntry -and $item -match '\d')
    {
        #Update the ff11datset file for noesis.
        $dat = $item -replace $datRegex, '$1'
        $itemName = $item -replace $itemNameRegex, '$1'
        $itemName = $itemName -replace '\s'
        $itemName = $itemName -replace "'"

        (Get-Content $DatSet) -replace $datSetRegex, "dat `"MainHand`" `"ROM/$dat.DAT`"" | Set-Content $DatSet

        if (!(Test-Path -Path "$exportDir\$subFolder"))
        {
            New-Item -Path "$exportDir\$subFolder" -ItemType Directory
        }
        $fbxFile = "$exportDir\$subFolder\SKM_$itemName.fbx"

        #Runs Noesis.EXE
        Start-Process -FilePath $NoesisExe -ArgumentList "?cmode $DatSet $fbxFile $NoesisArgs" -Wait
        Start-Sleep -Seconds 1
    }
}