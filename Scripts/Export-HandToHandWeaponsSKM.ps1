<#
The script bulk exports the skeletal meshes for weapons for the races.
#>

# The weapons to export for the race. You should just need to update the 'race' to the right folder. 
$Weapons = Get-Content "D:\Utilities\AltanaView\List\PC\HumeM\Main.csv"
$WeaponsSub = Get-Content "D:\Utilities\AltanaView\List\PC\HumeM\Sub.csv"

#The FF11datset used to export the .fbx.
$DatSet = "D:\Utilities\Noesis\noesisv4472\ffxi\humemale.ff11datset"
$exportDir = "D:\Utilities\Noesis\Exports\HumeM\MainHand"

$NoesisExe = 'D:\Utilities\Noesis\noesisv4472\Noesis64.exe'
$NoesisArgs = '-noanims -notex -ff11bumpdir normals -ff11keepnames 3 -ff11noshiny -ff11hton 16 -ff11optimizegeo -ff11keepnames -fbxtexrelonly -fbxtexext .png -rotate 180 0 270 -scale 100'

$datRegex = '([\d]*\/[\d]*)[\s\S\d\D\w\W]*'
$itemNameRegex = '[\d\D\/]*,([\d\D\w\W\s\S]*)'
# The Regular expresions to find and replace the MainHand and SubHand .dats with the new one.
$datSetRegex = 'dat "MainHand" [\s\S\d\D\w\W]*dat"'
$datSetRegex_Sub = 'dat "SubHand" [\s\S\d\D\w\W]*dat"'

#Start of exporting of Meshes through Noesis!
if((Test-Path $NoesisExe) -eq $false)
{
    throw "Unable to find the Noesis Executable at $NoesisExe"
}

$skipEntry = $false
$subFolder
$datSub
foreach ($item in $Weapons)
{
    if ($item -match '@' -and $item -match 'Hand')
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

        foreach($value in $WeaponsSub)
        {
            if($value -match ",$itemName")
            {
                $datSub = $value -replace $datRegex, '$1'
            }
        }
        
        $itemName = $itemName -replace '\s'
        $itemName = $itemName -replace "'"

        (Get-Content $DatSet) -replace $datSetRegex, "dat `"MainHand`" `"ROM/$dat.DAT`"" | Set-Content $DatSet
        (Get-Content $DatSet) -replace $datSetRegex_Sub, "dat `"SubHand`" `"ROM/$datSub.DAT`"" | Set-Content $DatSet

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