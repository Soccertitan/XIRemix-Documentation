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

### 2.2 Bulk Exporting
There are three powershell scripts that have been developed for bulk exporting from Noesis and preparing the files for import into Blender. I will likely update these to require less manual changes to variables and combine into one single mega script.

#### 2.2.1 Export-NoesisFFXIModles.ps1
This script does a lot of the heavy lifting of taking a template FFXIDataSetFile and modifying it as required for each indivdual skeletal mesh you want to export. I create a template FF11DataSetFile (HuMa_Set.FF11DataSetFile) for the script to update for each Skeletal Mesh. You will need to update the variables in the script. The main ones to note are:
```
#Noesis Install Path
$NoesisEXE = "D:\Utilities\Noesis\noesisv4464\Noesis.exe"

#File to open and export *Modified by the CSV file
$ffxiDataSet = 'C:\Users\trist\OneDrive\Documents\XIRemix_Resources\Noesis\HuMa_Set.ff11datset'
$exportLocation = 'D:\Utilities\Noesis\Exports'

#Base folder for exports.
$race = 'HuMa'

#List of all the Meshes to export. 
$csvFilePath = 'C:\Users\trist\OneDrive\Documents\XIRemix_Resources\Noesis\FFXIModelsToExport.csv'
```
For the FFXIModlesToExport.csv open the file to see how you should add items to the file. If you're unsure of which item is which Dat file, jump to the AltanaView section. Ensure you don't include animation data when doing bulk exports!

#### 2.2.2 Rename-PNGFiles.ps1 [Depreciated]
This script renames the png files that were exported from the Export-NOesisFFXiModles.ps1 script to match the name of each the item that was exported. Just update the export path to match the previous script with the same race.

#### 2.2.3 Prepare-BlenderUEFiles.ps1
This script replaces Rename-PNGFiles.ps1 as the rename functionality was built into this script. In addition this script prepares the textures and FBX files for UE and Blender respectively. 

```
#Copies the Textures to the UEImports folder for easy imports into UnrealEngine.
$UEImportFolder = "D:\Utilities\UEImports\$race"

#Copies the FBX files to this folder for easy import into Blender
$BlenderImportPath = "D:\Utilities\BlenderImport"

# The csv files is created in the script that a Blender python script will use to run through to update bone names.
$BlenderImportCSV = "$race`-Imports.csv"
```

## 3. Blender
We will be using blender to import FBX files generated by Noesis and to create UnrealEngine ready skeleton, animations, and meshes. A lot of the bulk scripts were designed specifically to export a single mesh to use UnrealEngines SkeletalMesh merge to reduce the number of draw calls. As the FFXIRemix is desgined to be multiplayer experience with NPC and PC companions.

### 3.1 Blender Import/Export an FBX Manually
There will be manual Blender work when doing the following tasks.
- Creating the RaceBone-Rename.csv file for the blender scripts.
- Categorizing and breaking out the animations.

Before importing an FBX from Noesis, delete every object in the Blender scene. Then when going to import the FBX ensure "Ignore Leaf Bones" and "Automatic Bone Orientation" is checked.

![Blender_Import](https://user-images.githubusercontent.com/12266781/151233218-90d02938-543f-4483-b1fc-f6d5ab32479b.PNG)

When exporting the file to FBX, ensure that Leaf Bones are not added!

#### 3.1.1 Creating the Bone-Rename.csv File
Use the HuMa-BoneRename.csv file as a template for creating a new .csv file for a different race or monster. You will need to manually go through each bone from the model and note the bone name (bone0020) and your rename (leg_r) in the csv.

#### 3.1.2 Preparing the Animations
Working with animations in Blender from FFXI can be very tricky! I don't know if this is the best way but it works for me. When you have the animations imported into Blender follow these steps to duplicate the animation for each action you want to create. To make it easy to go back and fix an animation or redo it, make a text file (HuMa_Battle8_AFR.txt) to document which frames from the master animation translates to different animations. Before you start making the individual animations, I strongly recommend documenting when animations start and end in the master animation. This will make it much much easier when working on individual animations or going back and fixing them.

1. Right click on your base animation in the scene collection and select "Make Single User"
   
   ![Blender_anim1](https://user-images.githubusercontent.com/12266781/151234995-b12d0634-56ea-451d-943c-376778bbf2d1.PNG)

2. With that duplicated animation, modify it as you see fit. When you're done and happy with the end result click on the shield icon to ensure the animation is saved when you save and close your project! Ensure to rename the animation appropriately (eg. Atk_Unarmed_1_UB). Look at the HuMa_AFR.txt examples for a reference on the proper naming convention. * I should make a style guide...

   ![Blender_anim2](https://user-images.githubusercontent.com/12266781/151235456-4a5dafb9-2bfa-4001-8f63-73ddc539ce2e.PNG)

3. Repeat step 1 for each animation you want to create.
4. Uncheck "NLA Strips" and export the animations. If only needing to export one uncheck "All Actions".

   ![Blender_anim3](https://user-images.githubusercontent.com/12266781/151236638-6edc67b0-270f-4bee-846a-08f396ef0ef0.PNG)


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
The FFXI-BatchJob.py script is the primary one for importing fbx files, renaming the bones and rig appropriately, and exporting the fbx file to the UnrealEngine Import folder. The HuMa-Imports.csv file is generated by the powershell script Prepare-BlenderUEFiles.ps1. Before running the script make sure the Blender scene is completey empty!
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
