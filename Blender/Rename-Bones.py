import bpy, csv

#Change these variables to the correct race!
race = "HuMa"
boneRenameCSV = 'C:\\Users\\trist\\OneDrive\\Documents\\GitHub\\XIRemix-Documentation\\Blender\\Characters\\HuMa\\HuMa_BoneRename.csv'
            
#Used for the rename of bones
context = bpy.context
obj = context.object
        
#Imports the Bone Rename CSV and changes all the bone names.
with open(boneRenameCSV, 'r') as read_obj:
    bones = csv.reader(read_obj, delimiter=',')
    for bone in bones:
        ob = obj.pose.bones.get(bone[0])
        if ob != None:
            ob.name = bone[1]
        else:
            print("My object does not exist.")
            
#Renames the imported rig to the race specified.
rig = bpy.data.objects.get("bone0000")
rig.name = race