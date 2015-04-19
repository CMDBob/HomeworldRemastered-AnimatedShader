# HomeworldRemastered-AnimatedShader

This is a new shader for Homeworld Remastered Collection, based upon the inbuilt ship shader.

This shader allows for "flipbook" animation, and scrolling/rotation animation, while still supporting shadows, normal mapping, and the other features that the stock ship shader supports.

#Usage

To use the shader, place the shader folder into your mod folder. If you already have custom shaders, merge the mod_alias, mod_programs, and mod_surfaces  files into your existing ones. Then, in your ship, use shipAnim as the shader. To control the shader, add a HOLD_PARAMS node to the ROOT_LOD[0] node, then add a node to the HOLD_PARAMS node, called MAT[<materialname>]_PARAM[animParams]_Type[RGBA]_Data[<parameters>].

Replace <materialname> with what your material is called, and replace <parameters> with what parameters you want.

For a flip book style animation, the parameters are: x_frames,y_frames,fps,0.

x_frames and y_frames are the dimensions of the flipbook texture in terms of how many "tiles" it has, and fps is how fast you want the animation to run.

For a scrolling and rotating texture, the parameters are: x_scroll,y_scroll,rotation_speed,1.

x_scroll and y_scroll are how fast the texture scrolls and rotation_speed is how fast it rotates.

#Thanks and Other Information

Thanks go to Sastrei and BitVenom on the Gearbox forums for their help.

The vast majority of the shader is Gearbox code, and belongs Gearbox.