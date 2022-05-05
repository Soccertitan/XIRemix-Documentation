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
From the repository download one of the FF11DatSetFiles to your computer. The file contains a list of parameters for which .dat files to display in the Noesis preview window. Anything with a ';' at the start of a line is considered a comment and won't be read by Noesis.

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

#### 2.2.1 How to Run Prepare-FFXIModelFiles.ps1
Open a powershell command prompt. Enter the path to the .ps1 file and the approriate values for each parameter. Pressing '-' and tab will autocomplete each required field. The Race parameter is special and can be tab cycled to pick the correct Race.
".\Prepare-FFXIModelFiles.ps1 -NoesisExe "D:\Path\Noesis.exe" -ffxiModelCSVFilePath "C:\CSVTemplate.csv" -DatRootFolder "C:\PathToDatRoot\FFXI" -Race HuMa"

### 2.3 Exporting Animations
To export multiple animations for use in Unreal Engine. Follow the steps outlined below.
1. Prepare a ff11datset file with the models skeleton and animation. Example is a Hume Male. No mesh data is required.

![image](https://user-images.githubusercontent.com/12266781/167032693-d0f3cf8d-84e9-4b9d-8afb-0aad26ee0ed1.png)

2. Open the file in Noesis and set the following options.
Animation Output: noefbxmulti
Advanced Options: -rotate 180 -0 -90 -scale 90 -fbxsmoothgroups -fbxtexrelonly -fbxtexext .tga

![image](https://user-images.githubusercontent.com/12266781/167033045-0a43fcf8-c8ed-4216-bbc0-8c8cfa7c64ca.png)

3. Run the Create-BlenderAnimationCSV.ps1
4. Run the Prepare-UeFbxFiles.py as specified in 3.2.2 with the Animation parameter.
5. Now the files are ready to be imported into UE.

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

#### 3.1.1 Creating the Bone-Rename.csv File
Use the HuMa-BoneRename.csv file as a template for creating a new .csv file for a different race or monster. You will need to manually go through each bone from the model and note the bone name (bone0020) and your rename (leg_r) in the csv.

#### 3.1.2 Mesh Export Settings
Add Leaf Bones = False
Bake Animation = False

![image](https://user-images.githubusercontent.com/12266781/167031888-9c0a671a-c135-471d-abf2-c6d60444efa8.png)

#### 3.1.3 Animation Export Settings
The settings need to be set as follows:
Add Leaf Bones = False
Bake Animation = True
Key All Bones = True (specific for UE)
NLA Stiprs = False
All Actions = False
Force Start/End Keying = False

![image](https://user-images.githubusercontent.com/12266781/167031448-a7fd897d-06f1-4e79-a78a-67f897b87421.png)

### 3.2 Blender Scripts
There are two primary scripts written in python for bulk exporting for Unreal and renaming bones. Both these scripts can only be used within Blender!
- Rename-Bones.py
- Prepare-UeFbxFiles.py

#### 3.2.1 Rename-Bones.py
Rename-Bones.py is a script that simply renames all the bones of the imported Skeleton. Take note of the race and CSV file. The race will rename the rig to that value. For meshes to be compatible with eachother in Unreal the Rig name must match as well as the bone name structure. Take note of the double backslash in the CSV file name. Without them the script will not run.
```
#Change these variables to the correct race!
race = "HuMa"
BoneRenameCSV = 'C:\\Users\\trist\\OneDrive\\Documents\\XIRemix_Resources\\Blender\\Characters\\HuMa_BoneRename.csv'
```
After you successfully run the script there seems to be a bug where the Bones are no longer attached to the mesh. Just save your work and close/reopen the .blender file and it will be back to normal.

#### 3.2.2 Prepare-UeFbxFiles.py
The script takes the files that were exported from Noesis. Imports them into Blender to rename the bones and Rig as specified. Then exports those files specified in the ImportCSV parameter. To use the script open the command prompt and enter the following:
![image](https://user-images.githubusercontent.com/12266781/167030596-9e78cc63-c9bf-4b9a-950c-4f4fbad3a57e.png)

- The -- after the python script allows the script to take parameters.
- BoneCSV; the path to the CSV file to rename the bones appropriately.
- ImportCSV; the file generated by the powershell script. It's a CSV of files to import (first column) and export location (second column).
- RigName; What the name of the Rig should be.
- Animation; An optional parameter. Enter in the number '1' to enable animation import/export mode. This ensure the proper switches are used when exporting the FBX files from Blender.

## 4. AltanaView
Is amazing software for finding the .Dat files for anyting FFXI related. To use this, FFXI must be installed. Whenever you click on an item in the viewer, it shows you the file path to the DAT below, and will update to show the DAT file on the most recent item you selected. For example, changing a body from one type to another will show the new body's DAT file below.

AltanaView is pretty straightforward to use. I use it for when building the bulk import CSV file or looking for animation DATs.

## 5. AshenbubsHD Textures
After downloading the textures, you can copy the DATs from FFXI to the HD textures folder (choosing NOT to overright). When working with UnrealEngine and importing the meshes, we want the 4k versions of these textures exported from Noesis. That's what all reference FFXIDatSetFiles are doing. Taking the skeletons and animations from FFXI and combining with the 4k Textures.
