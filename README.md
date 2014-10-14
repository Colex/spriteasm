SpriteASM Unpacker
==================

A image unpacker written in Assembly for unpacking sprite-compiled files (as used by games like Tibia) into viewable BMP images.

**Note:** This application was written in 2009~2010, so it might not support changes in the **.spr** format that might have happened.

The code has been commented thoroughly for better understanding of each step. *Jump points should also be self-explanatory*
Functions and jump points are underscored, but functions begin with an underscore.

-----------------
*Rough explanation of the structure:*

|**\_main:_385_**<br>
| open sprites file<br>
| create output directory<br>
--->|**\_read\_sprites(file_pointer):_145_**<br>
---- |Read header<br>
---- |loop: read sprites (read pixels/calculate position)<br>
---------> **\_create\_empty_sprite(sprite_index):_61_**<br>
---- | Write to file

------------------

For some information regarding x86 Asm instruction set, visit the following page:
http://www.hep.wisc.edu/~pinghc/x86AssmTutorial.htm
