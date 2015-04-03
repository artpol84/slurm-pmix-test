To run autogen.sh for SLURM one needs the following macroses available on the machine:
AM_PATH_GLIB_2_0 and AM_PATH_GTK_2_0
This macroses are included in libglib2.0-dev and libgtk2.0-dev packages correspondingly.
Those packages occupate 200MB of space and are not needed on the frontend and compute
nodes.
The current approach is to have two separate images:
artpol/compile_platform   latest              f6e007ab0d03        8 minutes ago        341.3 MB
artpol/devel_platform     latest              1b458cdb0ae0        About a minute ago   535.4 MB

Where compile_platform is used as base for devel_platform. devel_platform has mentioned packages
installed. But we use it only to "autogen" SLURM sources.

compile_platform is later used as the container to compile all needed packages and as base
for the frontend and compute node images.
