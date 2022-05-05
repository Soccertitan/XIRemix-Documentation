# XIRemix-Documentation
Documentation and resources on how to Export/Import FFXI Assets specifically for the XIRemix Unreal project. While this guide focuses on the XIRemix Unreal project, a lot of these steps can be generalized and applied to other projects involving FFXI.

The uploaded files contain scripts and reference materials to successfully export and import FFXI assets in Noesis and Blender. When I get around to making the XIRemix Readme for Unreal it will include documentation specifically for supporting that project. 

I will also add screenshots to this file after the text is completed.

## 1. Required Tools and Software
In order to export/import files for the XIRemix project you will need the following. Always grab the latest version unless otherwise specified:
1. [Noesis](https://richwhitehouse.com/index.php?content=inc_projects.php) by Rich Whitehouse.
2. [Blender](https://www.blender.org/)
3. [AltanaView](https://github.com/mynameisgonz/AltanaView) by MyNameisGonz.
4. [Official FFXI Client](http://www.playonline.com/ff11us/download/media/install_win.html) from Steam or their official website.
5. [Unreal Engine 4.26](https://www.unrealengine.com/en-US/) from EpicGames version UE4.26.
6. [AshenbubsHD Textures](https://www.nexusmods.com/finalfantasy11/mods/1)

## 2. Noesis
Noesis is a tool developed by Rich Whitehouse for exporting all sorts of game files into various usuable formats.
### 2.1 How to use Noesis
From the repository download one of the FF11DataSetFiles to your computer. The file contains a list of parameters for which .dat files to display in the Noesis preview window. Anything with a ';' at the start of a line is considered a comment and won't be read by Noesis.

```
;search for dats using a path retrieved from a registry key
;setPathKey "HKEY_LOCAL_MACHINE" "SOFTWARE\WOW6432Node\PlayOnlineUS\InstallFolder" "0001"

;search for dats on a path relative to this file 
;setPathRel "./"

;search for dats on an absolute path
;setPathAbs "c:/whatever/ff11/"
;setPathAbs "C:\Program Files (x86)\PlayOnline\SquareEnix\FINAL FANTASY XI\"
setPathAbs "D:\FFXI\Ashita\plugins\DATs\AshenbubsHD-Prime\"
```

In this example, we are looking for DATs relative to the parent folder "D:\FFXI\Ashita\plugins\DATs\AshenbubsHD-Prime\". Each person will likely need to update this path as required or comment it out and use the path defined in the Registry.

```
dat "__skeleton" "ROM/27/82.dat"
dat "__animation" "ROM/32/13.dat"
;Sword, Axe + Club
dat "face" "ROM/27/87.dat"
```

This code is from the same file above. When updating the paths above, you may need to update the paths to the ROM for each item you want to view. Notice that the backslash and forward slash. They will change depending on how you're defining the root path.

When you try to open the file in Noesis and see nothing, double check your paths!

### 2.2 Prepare-FFXIModelFiles.ps1
A powershell script that was developed to export multiple textures from FFXI player characters. The script outputs files in three places in the 'Exports' sub folder; ".\UEImport", ".\Race", and "Race-BlenderImport.csv". 

The UEImports folder contains files that ready to be imported into Unreal Engine.
The Race (ie. HuMa) folder contains the fbx files that will be imported into Blender. Blender will take those .fbx files and prepare them to be used in Unreal Engine.
The Race-BlenderImport.csv file contains the file paths that blender will use to import and export the FBX files.

To use this script the following conditions must be met:
- Ensure the "FFXIDatSetTemplate.ff11datset" file is in the same directory as the script. The script uses this template to generate a ff11datset file for the specific race.
- A CSV file with the following headers 'part,name,datFilePath' is created. Each line is an fbx and texture to export from Noesis. A template is available in the script directory.

####2.2.1 How to Run Prepare-FFXIModelFiles.ps1
Open a powershell command prompt. Enter the path to the .ps1 file and the approriate values for each parameter. Pressing '-' and tab will autocomplete each required field. The Race parameter is special and can be tab cycled to pick the correct Race.
".\Prepare-FFXIModelFiles.ps1 -NoesisExe "D:\Path\Noesis.exe" -ffxiModelCSVFilePath "C:\CSVTemplate.csv" -DatRootFolder "C:\PathToDatRoot\FFXI" -Race HuMa"

### 2.3 Create-BlenderAnimationCSV
Running this scripts renames animation files appropriately and prepares a CSV file that is used in the Blender python script FFXI-BatchJob.py. 

#### 2.3.1 How to Run Create-BlenderAnimationCSV
Open a Powershell command prompt and type the correct path to the script along with the following parameters.
".\Create-BlenderAnimationCSV.ps1 -AnimationFolder D:\Path\AnimationFolder -Race HuMa -AnimationCategory Battle1"
Parameters:
- AnimationFolder (mandatory): Specify the folder path to the animations exported from Noesis.
- Race (mandatory): Inserts text to the file name. ie; A_HuMa_bb00.fbx
- AnimationCategory (Optional): Inserts text to the file name. ie; A_HuMa_Battle1_bb00.fbx

## 3. Blender
We will be using blender to import FBX files generated by Noesis and to create UnrealEngine ready skeleton, animations, and meshes. A lot of the bulk scripts were designed specifically to export a single mesh to use UnrealEngines SkeletalMesh merge to reduce the number of draw calls. As the FFXIRemix is desgined to be multiplayer experience with NPC and PC companions.

### 3.1 Blender Import/Export an FBX Manually
There will be manual Blender work when doing the following tasks.
- Creating the RaceBone-Rename.csv file for the blender scripts.

Before importing an FBX from Noesis, delete every object in the Blender scene. Then when going to import the FBX ensure "Ignore Leaf Bones" and "Automatic Bone Orientation" is checked.

![Blender_Import](https://user-images.githubusercontent.com/12266781/151233218-90d02938-543f-4483-b1fc-f6d5ab32479b.PNG)

When exporting the file to FBX, ensure that Leaf Bones are not added!

#### 3.1.1 Creating the Bone-Rename.csv File
Use the HuMa-BoneRename.csv file as a template for creating a new .csv file for a different race or monster. You will need to manually go through each bone from the model and note the bone name (bone0020) and your rename (leg_r) in the csv.

#### 3.1.2 Preparing the Animations
This section is being revamped with new Noesis multifbx options.

### 3.2 Blender Scripts
There are two primary scripts written in python for bulk exporting for Unreal and renaming bones. Both these scripts can only be used within Blender!
- Rename-Bones.py
- FFXI-BatchJob.py

#### 3.2.1 Rename-Bones.py
Rename-Bones.py is a script that simply renames all the bones of the imported Skeleton. Take note of the race and CSV file. The race will rename the rig to that value. For meshes to be compatible with eachother in Unreal the Rig name must match as well as the bone name structure. Take note of the double backslash in the CSV file name. Without them the script will not run.
```
#Change these variables to the correct race!
race = "HuMa"
BoneRenameCSV = 'C:\\Users\\trist\\OneDrive\\Documents\\XIRemix_Resources\\Blender\\Characters\\HuMa_BoneRename.csv'
```
After you successfully run the script there seems to be a bug where the Bones are no longer attached to the mesh. Just save your work and close/reopen the .blender file and it will be back to normal.

#### 3.2.2 FFXI-BatchJob.py
The FFXI-BatchJob.py script is the primary one for importing fbx files, renaming the bones and rig appropriately, and exporting the fbx file to the UnrealEngine Import folder. The import.csv file is generated by the powershell script in the Noesis section. Before running the script make sure the Blender scene is completey empty!
```
#Change these Variables based on imports
#Double \\ for proper file paths in Python.
race = "HuMa"
boneRenameCSV = 'C:\\Users\\trist\\OneDrive\\Documents\\XIRemix_Resources\\Blender\\HuMa_BoneRename.csv'
importListCSV = 'C:\\Users\\trist\\OneDrive\\Documents\\XIRemix_Resources\\Blender\\HuMa-Imports.csv'
```
This script should only be used when you want to export a single mesh for the Unreal SkeletalMesh merge function.

## 4. AltanaView
Is amazing software for finding the .Dat files for anyting FFXI related. To use this, FFXI must be installed. Whenever you click on an item in the viewer, it shows you the file path to the DAT below, and will update to show the DAT file on the most recent item you selected. For example, changing a body from one type to another will show the new body's DAT file below.

AltanaView is pretty straightforward to use. I use it for when building the bulk import CSV file or looking for animation DATs.

## 5. AshenbubsHD Textures
After downloading the textures, you can copy the DATs from FFXI to the HD textures folder (choosing NOT to overright). When working with UnrealEngine and importing the meshes, we want the 4k versions of these textures exported from Noesis. That's what all reference FFXIDataSetFiles are doing. Taking the skeletons and animations from FFXI and combining with the 4k Textures.
