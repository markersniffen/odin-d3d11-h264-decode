Minimal reference program that shows how to use Windows Media Foundation API & D3D11 to decode h264 files on the gpu. Based on the D3D11 example from the odin-lang/examples.

Note: The VIDEO_SUPPORT flag was incorrect in the recent vendor D3D11.odin file. Make sure to pull from the Odin repo otherwise `D3D11.CreateDevice` will fail.
