import bpy
import os

# Get the directory of the current .blend file
blend_file_dir = os.path.dirname(bpy.data.filepath)

# Ensure the .blend file is saved
if not blend_file_dir:
    raise Exception("Please save your .blend file first.")
    
# Get the active scene
active_scene = bpy.context.scene

# Enable the mist pass in the view layer
active_scene.view_layers["ViewLayer"].use_pass_mist = True

# Set up the compositor nodes to output the mist pass
def setup_compositor_nodes(mist_output_path, diffuse_output_path, object_name):
    print(object_name)
    bpy.context.scene.use_nodes = True
    tree = bpy.context.scene.node_tree
    links = tree.links

    # Clear existing nodes
    for node in tree.nodes:
        tree.nodes.remove(node)

    # Create render layer node
    render_layers = tree.nodes.new(type='CompositorNodeRLayers')

    # Create file output node for combined image
    file_output_combined = tree.nodes.new(type='CompositorNodeOutputFile')
    file_output_combined.label = "Combined Output"
    file_output_combined.base_path = diffuse_output_path
    file_output_combined.file_slots[0].path = f"{object_name}_####"
    file_output_combined.format.file_format = 'PNG'
    file_output_combined.format.color_depth = '8'
    file_output_combined.format.color_mode = 'RGBA'

    # Create file output node for mist pass
    file_output_mist = tree.nodes.new(type='CompositorNodeOutputFile')
    file_output_mist.label = "Mist Output"
    file_output_mist.base_path = mist_output_path
    file_output_mist.file_slots[0].path = f"{object_name}_####"
    file_output_mist.format.file_format = 'PNG'
    file_output_mist.format.color_depth = '16'
    file_output_mist.format.color_mode = 'BW'

    # Link render layers to file outputs
    links.new(render_layers.outputs['Image'], file_output_combined.inputs[0])
    links.new(render_layers.outputs['Mist'], file_output_mist.inputs[0])

# Function to render a frame for a specific object
def render_frame(collection_name, object_name, frame):
    # Set the current frame
    bpy.context.scene.frame_set(frame)
    
    # Set up the output paths
    output_path = os.path.join(blend_file_dir, "resources/textures/objects/", collection_name)
    diffuse_output_path = os.path.join(output_path, "diffuse/")
    mist_output_path = os.path.join(output_path, "mist/")

    # Create the output directories if they don't exist
    os.makedirs(diffuse_output_path, exist_ok=True)
    os.makedirs(mist_output_path, exist_ok=True)
    
    # Update the file output paths in the compositor nodes
    setup_compositor_nodes(mist_output_path, diffuse_output_path, object_name)
    
    # Render the combined RGBA 8-bit image
    bpy.ops.render.render(write_still=True)

# Function to render all frames for a specific object
def render_all_frames_for_object(collection_name, object_name):
    # Define the frame range
    start_frame = bpy.context.scene.frame_start
    end_frame = bpy.context.scene.frame_end
        
    # Save the original visibility settings
    original_visibility = {}
    for collection in bpy.context.scene.collection.children:
        for o in collection.objects:
            original_visibility[o.name] = o.hide_render

    # Set only the current object to be renderable
    for collection in bpy.context.scene.collection.children:
        for o in collection.objects:
            o.hide_render = (o != obj)

    # Render each frame in the range
    for frame in range(start_frame, end_frame + 1):
        render_frame(collection_name, object_name, frame)
         
    # Restore original visibility settings
    for collection in active_scene.collection.children:
        for o in collection.objects:
            o.hide_render = original_visibility[o.name]
        
# Iterate through collections and objects in the active scene
for collection in bpy.context.scene.collection.children:
    for obj in collection.objects:
        render_all_frames_for_object(collection.name, obj.name)
        
print("hello!")
