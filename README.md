Small example of how to use Windows Media Foundation API & D3D11 to decode h264 files on the gpu.	

Note: D3D11 VIDEO_SUPPORT flag was incorrect in the recent vendor D3D11.odin file. Make sure to pull & rebuild odin otherwise `D3D11.CreateDevice` will fail.
