package decode

import "core:fmt"
import "core:time"

import D3D11 "vendor:directx/d3d11"
import DXGI "vendor:directx/dxgi"
import D3D "vendor:directx/d3d_compiler"
import SDL "vendor:sdl2"
import glm "core:math/linalg/glsl"
import win32 "core:sys/windows"


VIDEO_WIDTH  :: 1920
VIDEO_HEIGHT :: 1080
VIDEO_PATH :: "big_buck_bunny.mp4"

main :: proc() {
	SDL.Init({.VIDEO})
	defer SDL.Quit()

	SDL.SetHintWithPriority(SDL.HINT_RENDER_DRIVER, "direct3d11", .OVERRIDE)
	window := SDL.CreateWindow("GPU Accelerated h264 decode with D3D11 in Odin",
		SDL.WINDOWPOS_CENTERED, SDL.WINDOWPOS_CENTERED,
		VIDEO_WIDTH, VIDEO_HEIGHT,
		{.ALLOW_HIGHDPI, .HIDDEN, .RESIZABLE},
	)
	defer SDL.DestroyWindow(window)

	window_system_info: SDL.SysWMinfo
	SDL.GetVersion(&window_system_info.version)
	SDL.GetWindowWMInfo(window, &window_system_info)
	assert(window_system_info.subsystem == .WINDOWS)

	native_window := DXGI.HWND(window_system_info.info.win.window)

	feature_levels := [?]D3D11.FEATURE_LEVEL{._11_0}

	base_device: ^D3D11.IDevice
	base_device_context: ^D3D11.IDeviceContext

	// NOTE: .VIDEO_SUPPORT flag was incorrect in the recent vendor D3D11.odin file. Make sure to pull>rebuild odin otherwise this call will fail.
	D3D11.CreateDevice(nil, .HARDWARE, nil,{.VIDEO_SUPPORT},&feature_levels[0],len(feature_levels),D3D11.SDK_VERSION, &base_device,nil, &base_device_context)

	device: ^D3D11.IDevice
	base_device->QueryInterface(D3D11.IDevice_UUID, (^rawptr)(&device))

	device_context: ^D3D11.IDeviceContext
	base_device_context->QueryInterface(D3D11.IDeviceContext_UUID, (^rawptr)(&device_context))

	dxgi_device: ^DXGI.IDevice
	device->QueryInterface(DXGI.IDevice_UUID, (^rawptr)(&dxgi_device))

	dxgi_adapter: ^DXGI.IAdapter
	dxgi_device->GetAdapter(&dxgi_adapter)

	dxgi_factory: ^DXGI.IFactory2
	dxgi_adapter->GetParent(DXGI.IFactory2_UUID, (^rawptr)(&dxgi_factory))

	///////////////////////////////////////////////////////////////////////////////////////////////

	swapchain_desc := DXGI.SWAP_CHAIN_DESC1{
		Width  = 0,
		Height = 0,
		Format = .B8G8R8A8_UNORM,
		Stereo = false,
		SampleDesc = {
			Count   = 1,
			Quality = 0,
		},
		BufferUsage = {.RENDER_TARGET_OUTPUT},
		BufferCount = 2,
		Scaling     = .STRETCH,
		SwapEffect  = .DISCARD,
		AlphaMode   = .UNSPECIFIED,
		Flags       = {},
	}

	swapchain: ^DXGI.ISwapChain1
	dxgi_factory->CreateSwapChainForHwnd(device, native_window, &swapchain_desc, nil, nil, &swapchain)

	framebuffer: ^D3D11.ITexture2D
	swapchain->GetBuffer(0, D3D11.ITexture2D_UUID, (^rawptr)(&framebuffer))

	framebuffer_view: ^D3D11.IRenderTargetView
	device->CreateRenderTargetView(framebuffer, nil, &framebuffer_view)

	///////////////////////////////////////////////////////////////////////////////////////////////

	vs_blob: ^D3D11.IBlob
	D3D.Compile(raw_data(shaders_hlsl), len(shaders_hlsl), "shaders.hlsl", nil, nil, "vs_main", "vs_5_0", 0, 0, &vs_blob, nil)
	assert(vs_blob != nil)

	vertex_shader: ^D3D11.IVertexShader
	device->CreateVertexShader(vs_blob->GetBufferPointer(), vs_blob->GetBufferSize(), nil, &vertex_shader)

	ps_blob: ^D3D11.IBlob
	D3D.Compile(raw_data(shaders_hlsl), len(shaders_hlsl), "shaders.hlsl", nil, nil, "ps_main", "ps_5_0", 0, 0, &ps_blob, nil)

	pixel_shader: ^D3D11.IPixelShader
	device->CreatePixelShader(ps_blob->GetBufferPointer(), ps_blob->GetBufferSize(), nil, &pixel_shader)

	///////////////////////////////////////////////////////////////////////////////////////////////

	sampler_desc := D3D11.SAMPLER_DESC{
		Filter         = .MIN_MAG_MIP_POINT,
		AddressU       = .WRAP,
		AddressV       = .WRAP,
		AddressW       = .WRAP,
		ComparisonFunc = .NEVER,
	}
	sampler_state: ^D3D11.ISamplerState
	device->CreateSamplerState(&sampler_desc, &sampler_state)

	///////////////////////////////////////////////////////////////////////////////////////////////

	// Format = DXGI_FORMAT_B8G8R8X8_UNORM // DXGI_FORMAT_NV12 // DXGI_FORMAT_P010
	// Usage = D3D11_USAGE_DEFAULT
	// BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE

	texture_desc := D3D11.TEXTURE2D_DESC{
		Width      = VIDEO_WIDTH,
		Height     = VIDEO_HEIGHT,
		MipLevels  = 1,
		ArraySize  = 1,
		Format     = .B8G8R8X8_UNORM,
		SampleDesc = {Count = 1},
		Usage      = .DYNAMIC,
		BindFlags  = {.SHADER_RESOURCE},
		CPUAccessFlags = {.WRITE},
	}

	texture: ^D3D11.ITexture2D
	device->CreateTexture2D(&texture_desc, nil, &texture)

	texture_view: ^D3D11.IShaderResourceView
	device->CreateShaderResourceView(texture, nil, &texture_view)

	///////////////////////////////////////////////////////////////////////////////////////////////

	// initialize decoding stuff
	win32.CoInitializeEx(nil, {})
	MFStartup(MF_VERSION, MFSTARTUP_NOSOCKET)

	multithread: ^IMultithread
	device->QueryInterface(IMultithread_UUID, (^rawptr)(&multithread))
	multithread->SetMultithreadProtected(true)
	result := multithread->Release()

	// start DXGI Device Manager
	token: UINT
  manager:^IMFDXGIDeviceManager
  MFCreateDXGIDeviceManager(&token, &manager)
  manager->ResetDevice((^IUnknown)(device), token)

  attributes:^IMFAttributes
	MFCreateAttributes(&attributes, 3)
	attributes->SetUINT32(MF_LOW_LATENCY^, 1)
  attributes->SetUINT32(MF_SOURCE_READER_ENABLE_ADVANCED_VIDEO_PROCESSING^, 1)
  attributes->SetUINT32(MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS^, 1)
  attributes->SetUnknown(MF_SOURCE_READER_D3D_MANAGER^, manager)
  assert(bool(manager->Release()))

	reader: ^IMFSourceReader
  hresult := MFCreateSourceReaderFromURL(win32.utf8_to_wstring(VIDEO_PATH), attributes, &reader)
 	assert(bool(attributes->Release()))

 	if hresult != 0 {
 		fmt.println("Failed to create source reader from PATH")
 		return
 	}

	duration_prop: PROPVARIANT
	reader->GetPresentationAttribute(MF_SOURCE_READER_MEDIASOURCE, MF_PD_DURATION^, &duration_prop)
	reader->SetStreamSelection(MF_SOURCE_READER_ALL_STREAMS, false)
	reader->SetStreamSelection(MF_SOURCE_READER_FIRST_VIDEO_STREAM, true)

	media_type: ^IMFMediaType;
	reader->GetNativeMediaType(MF_SOURCE_READER_FIRST_VIDEO_STREAM, 0, &media_type)

	framerate: u64
	media_type->GetUINT64(MF_MT_FRAME_RATE^, &framerate)

	frame_size: u64
	media_type->GetUINT64(MF_MT_FRAME_SIZE^, &frame_size)
	
	pixel_aspect: u64
	media_type->GetUINT64(MF_MT_PIXEL_ASPECT_RATIO^, &pixel_aspect)

	duration: LONGLONG
	PropVariantToInt64(&duration_prop, &duration)

	width  := (DWORD)(frame_size >> 32)
	height := (DWORD)(frame_size)

	FrameRateNum := (DWORD)(framerate >> 32)
	FrameRateDen := (DWORD)(framerate)

	frame_ms := f64(FrameRateNum) / f64(FrameRateDen)

	frame_count := MFllMulDiv(duration, i64(FrameRateNum), i64(FrameRateDen) * 10000000, 0)

	fmt.println("Duration:", duration)
	fmt.println("Frame Count:", frame_count)
	fmt.println("Video Size:", width, "x", height)
	fmt.println("Video Rate:", FrameRateNum, "/", FrameRateDen)
	fmt.println("Pixel Aspect Ratio:", u32(pixel_aspect >> 32), u32(pixel_aspect))

	SubType: GUID
	media_type->GetGUID(MF_MT_SUBTYPE, &SubType)

	Profile : u32= 0
	media_type->GetUINT32(MF_MT_VIDEO_PROFILE^, &Profile)

	MaxProfile : u32 = 0xffffffff
	if (IsEqualGUID(&SubType, &MFVideoFormat_H264)) do MaxProfile = eAVEncH264VProfile_High
	if (IsEqualGUID(&SubType, &MFVideoFormat_HEVC)) do MaxProfile = eAVEncH265VProfile_Main_420_8
	if (IsEqualGUID(&SubType, &MFVideoFormat_VP90)) do MaxProfile = eAVEncVP9VProfile_420_8
	// if (IsEqualGUID(&SubType, &MFVideoFormat_AV1))  MaxProfile = eAVEncAV1VProfile_Main_420_8;

	if (Profile > MaxProfile)
	{
		fmt.println("Unsupported video profile!")
		return
	}

	//Imedia_type->SetGUID(Type, &MF_MT_SUBTYPE, &MFVideoFormat_ARGB32)
	media_type->SetGUID(MF_MT_SUBTYPE, MFVideoFormat_RGB32)
	//media_type->SetGUID(MF_MT_SUBTYPE, MFVideoFormat_NV12)
	//media_type->SetGUID(Type, &MF_MT_SUBTYPE, &MFVideoFormat_P010)
	//media_type->SetGUID(Type, &MF_MT_SUBTYPE, &MFVideoFormat_A2R10G10B10)
	//media_type->SetGUID(Type, &MF_MT_SUBTYPE, &MFVideoFormat_A16B16G16R16F)
	
	reader->SetCurrentMediaType(MF_SOURCE_READER_FIRST_VIDEO_STREAM, nil, media_type)
	media_type->Release()

	///////////////////////////////////////////////////////////////////////////////////////////////

	dragging: bool

	start_time: time.Tick
	SDL.ShowWindow(window)
	for quit := false; !quit; {
		for e: SDL.Event; SDL.PollEvent(&e); {
			#partial switch e.type {
			case .QUIT:
				quit = true
			case .KEYDOWN:
				if e.key.keysym.sym == .ESCAPE {
					quit = true
				}
			case .MOUSEBUTTONDOWN: dragging = true
			case .MOUSEBUTTONUP: dragging = false
			case .MOUSEMOTION:
				// seek by dragging
				if dragging {
					x := f64(e.button.x) / f64(VIDEO_WIDTH)
					video_pos := i64(x * f64(duration))
					pos := MYPROPVARIANT{vt = 20, value={hVal=video_pos}}
					reader->SetCurrentPosition(GUID_NULL^, (^PROPVARIANT)(&pos))
				}
			}
		}

		// check if 1 frame's worth of ms have elapsed, otherwise don't read next sample
		now := time.tick_now()
		ms_elapsed := time.duration_milliseconds(time.tick_diff(start_time, now))
		if ms_elapsed >= frame_ms {
			start_time = now

			Flags: DWORD
			Timestamp: LONGLONG
			sample: ^IMFSample
			reader->ReadSample(MF_SOURCE_READER_FIRST_VIDEO_STREAM, 0, nil, &Flags, &Timestamp, &sample)
			
			if bool(Flags & MF_SOURCE_READERF_ERROR) {
				fmt.println("error")
				return
			}
			if bool(Flags & MF_SOURCE_READERF_ENDOFSTREAM) {
				pos := MYPROPVARIANT{vt = 20, value={hVal=0}}
				reader->SetCurrentPosition(GUID_NULL^, (^PROPVARIANT)(&pos))
				fmt.println("eof")
				return
			}
			if bool(Flags & MF_SOURCE_READERF_NATIVEMEDIATYPECHANGED) {
				fmt.println("media type changed, not supported")
				return
			}
			buffer: ^IMFMediaBuffer
			sample->ConvertToContiguousBuffer(&buffer)

			DxgiBuffer:^IMFDXGIBuffer
			buffer->QueryInterface(IID_IMFDXGIBuffer, (^rawptr)(&DxgiBuffer))

			dxgi_texture: ^D3D11.ITexture2D
			DxgiBuffer->GetResource(D3D11.ITexture2D_UUID, (^rawptr)(&dxgi_texture))

			Subresource: UINT
			DxgiBuffer->GetSubresourceIndex(&Subresource)

			Desc: D3D11.TEXTURE2D_DESC
			dxgi_texture->GetDesc(&Desc)

			DstDesc: D3D11.TEXTURE2D_DESC
			texture->GetDesc(&DstDesc)
			// Format = DXGI_FORMAT_B8G8R8X8_UNORM // DXGI_FORMAT_NV12 // DXGI_FORMAT_P010
			// Usage = D3D11_USAGE_DEFAULT
			// BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE
			device_context->CopyResource(texture, dxgi_texture)

			dxgi_texture->Release()
			DxgiBuffer->Release()
			buffer->Release()
			sample->Release()
			
		}

		viewport := D3D11.VIEWPORT{0, 0, f32(VIDEO_WIDTH), f32(VIDEO_HEIGHT), 0, 1,
		}

		///////////////////////////////////////////////////////////////////////////////////////////////

		device_context->ClearRenderTargetView(framebuffer_view, &[4]f32{0.25, 0.5, 0.3, 1.0})

		device_context->IASetPrimitiveTopology(.TRIANGLESTRIP)
		device_context->RSSetViewports(1, &viewport)

		device_context->VSSetShader(vertex_shader, nil, 0)
		device_context->PSSetShader(pixel_shader, nil, 0)
		device_context->PSSetShaderResources(0, 1, &texture_view)
		device_context->PSSetSamplers(0, 1, &sampler_state)

		device_context->OMSetRenderTargets(1, &framebuffer_view, nil)
		device_context->OMSetBlendState(nil, nil, ~u32(0)) // use default blend mode (i.e. disable)

		///////////////////////////////////////////////////////////////////////////////////////////////

		device_context->DrawInstanced(4, 1, 0, 0)

		swapchain->Present(1, {})
	}
}

shaders_hlsl := `
struct vs_out {
	float4 position : SV_POSITION;
	float2 texcoord : TEX;
};
Texture2D    mytexture : register(t0);
SamplerState mysampler : register(s0);
vs_out vs_main(uint vertex_id : SV_VERTEXID) {
	static float2 vertices[] =
	{
		{-1, -1},
		{-1, +1},
		{+1, -1},
		{+1, +1},
	};

	static uint2 uv_coords[] =
	{
		{0, 1},
		{0, 0},
		{1, 1},
		{1, 0},
	};

	vs_out output;
	output.position = float4(vertices[vertex_id], 0, 1);
	output.texcoord = uv_coords[vertex_id];
	return output;
}
float4 ps_main(vs_out input) : SV_TARGET {
	return mytexture.Sample(mysampler, input.texcoord);
}
`
