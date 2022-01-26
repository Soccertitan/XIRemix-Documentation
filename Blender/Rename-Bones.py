import bpy, csv

#Change these variables to the correct race!
race = "HuMa"
BoneRenameCSV = 'C:\\Users\\trist\\OneDrive\\Documents\\XIRemix_Resources\\Blender\\Characters\\HuMa_BoneRename.csv'

#Renames the imported rig to the race specified.
rig = bpy.data.objects.get("bone0000")
rig.name = race

context = bpy.context
obj = context.object

#Make sure to use double \\ for file paths. Otherwise the script will not work.
from csv import reader
with open(BoneRenameCSV, 'r') as read_obj:
    reader = csv.reader(read_obj, delimiter=',')
    for row in reader:
        ob = obj.pose.bones.get(row[0])
        if ob != None:
            print("My object exists and I can operate upon it.")
            ob.name = row[1]
        else:
            print("My object does not exist.")