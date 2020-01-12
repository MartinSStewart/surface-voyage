import bpy
import os

# export to blend file location
basedir = os.path.dirname(bpy.data.filepath)

if not basedir:
    raise Exception("Blend file is not saved")

fn = os.path.join(basedir, "world.obj")

bpy.ops.export_scene.obj(filepath=fn, use_triangles=True)

os.remove(os.path.join(basedir, "world.mtl"))

with open(fn, 'r') as file:
    data = file.read()
    
    elmCode = "module ObjData exposing (objData)\n\n\nobjData = \"\"\"" + data + "\"\"\"\n"
    elmFileName = os.path.join(basedir, "src", "ObjData.elm")
    with open(elmFileName, 'w') as elmFile:
        elmFile.write(elmCode)
    


os.remove(fn)
