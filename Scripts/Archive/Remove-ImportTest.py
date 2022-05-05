import bpy, csv
context = bpy.context
obj = context.object
race = "rig-humemale"

#Make sure to use double \\ for file paths. Otherwise the script will not work.
rig = bpy.data.objects.get(race)

#bpy.data.objects.remove(rig, do_unlink=True)
for child in rig.children:
    bpy.data.objects.remove(child, do_unlink=True)
    
bpy.data.objects.remove(rig, do_unlink=True)