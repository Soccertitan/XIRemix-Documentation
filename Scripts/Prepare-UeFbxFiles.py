import sys
import argparse
import bpy
import csv
 
if '--' in sys.argv:
    argv = sys.argv[sys.argv.index('--') + 1:]
    parser = argparse.ArgumentParser()
    parser.add_argument('-BoneCSV', '--BoneCSV', dest='BoneCSV', metavar='FILE')
    parser.add_argument('-ImportCSV', '--ImportCSV', dest='ImportCSV', metavar='FILE')
    parser.add_argument('-RigName', '--RigName', dest='RigName')
    parser.add_argument('-Animation', '--Animation', dest='Animation')
    args = parser.parse_known_args(argv)[0]
    # print parameters
    print('BoneCSV: ', args.BoneCSV)
    print('ImportCSV: ', args.ImportCSV)
    print('RigName:', args.RigName)
    print('Animation:', args.Animation)
    
    #Deletes the default scene.
    context = bpy.context
    scene = context.scene

    for c in scene.collection.children:
        scene.collection.children.unlink(c)

    from csv import reader
    with open(args.ImportCSV, 'r') as import_obj:
        importList = csv.reader(import_obj, delimiter=',')
        for importItem in importList:
            if args.Animation == '1':
                bpy.ops.import_scene.fbx(filepath=importItem[0],ignore_leaf_bones=True,automatic_bone_orientation=True,use_image_search=False,use_anim=True)
            else:
                bpy.ops.import_scene.fbx(filepath=importItem[0],ignore_leaf_bones=True,automatic_bone_orientation=True,use_image_search=False,use_anim=False)

            #Used for the rename of bones
            context = bpy.context
            obj = context.object
            
            #Imports the Bone Rename CSV and changes all the bone names.
            with open(args.BoneCSV, 'r') as read_obj:
                bones = csv.reader(read_obj, delimiter=',')
                for bone in bones:
                    ob = obj.pose.bones.get(bone[0])
                    if ob != None:
                        ob.name = bone[1]
                    else:
                        print("My object does not exist.")
                        
            #Renames the imported rig to the race specified.
            rig = bpy.data.objects.get("bone0000")
            rig.name = args.RigName
            
            #Exports The scene as an fbx file according to the file path specified in the 2nd slot.
            if args.Animation == '1':
                bpy.ops.export_scene.fbx(filepath=importItem[1],add_leaf_bones=False,bake_anim=True,bake_anim_use_all_bones=True,bake_anim_use_nla_strips=False,bake_anim_use_all_actions=False,bake_anim_force_startend_keying=False)
            else:
                bpy.ops.export_scene.fbx(filepath=importItem[1],add_leaf_bones=False,bake_anim=False)
            
            #Removes the children from the scene and prepares for next import
            for child in rig.children:
                bpy.data.objects.remove(child, do_unlink=True)
        
            bpy.data.objects.remove(rig, do_unlink=True)