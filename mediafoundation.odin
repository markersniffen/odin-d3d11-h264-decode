package decode

import win32 "core:sys/windows"

foreign import "system:ole32.lib"
foreign import "system:mfplat.lib"
foreign import "system:mfreadwrite.lib"
foreign import "system:propsys.lib"

HANDLE                 :: win32.HANDLE
HRESULT                :: win32.HRESULT
GUID                   :: win32.GUID
BYTE                   :: win32.BYTE
USHORT                 :: win32.USHORT
CHAR                   :: win32.CHAR
UINT                   :: win32.UINT
UINT8                  :: win32.UINT8
UINT32                 :: win32.UINT32
UINT64                 :: win32.UINT64
ULONG                  :: win32.ULONG
LONGLONG               :: win32.c_longlong
WORD                   :: win32.WORD
IID                    :: win32.IID
DWORD                  :: win32.DWORD
REFGUID                :: win32.REFGUID
REFIID                 :: win32.REFIID
LPCWSTR                :: win32.LPCWSTR
LPWSTR                 :: win32.LPWSTR
LPVOID                 :: win32.LPVOID
BOOL                   :: win32.BOOL
REFPROPVARIANT         :: win32.REFPROPVARIANT
PROPVARIANT            :: win32.PROPVARIANT
double                 :: f64
ULONG_PTR              :: win32.ULONG_PTR

MFSTARTUP_NOSOCKET :: 0x1
MFSTARTUP_LITE     :: MFSTARTUP_NOSOCKET
MFSTARTUP_FULL     :: 0

MF_SDK_VERSION :: 0x0002
MF_API_VERSION :: 0x0070
MF_VERSION : u32 = MF_SDK_VERSION << 16 | MF_API_VERSION


@(default_calling_convention="system")
foreign mfplat {
	MFSetAttributeSize :: proc(
	  pAttributes: ^IMFAttributes,
	  guidKey:      REFGUID,
	  punWidth:    UINT32,
	  punHeigh:    UINT32,
	) -> HRESULT ---
	MFllMulDiv :: proc(
  	a, b, c, d: LONGLONG,
	) -> LONGLONG ---
}

@(default_calling_convention="system")
foreign propsys {
	PropVariantToInt64 :: proc(
	  propvarIn: REFPROPVARIANT,
	  pllRet:    ^LONGLONG,
	) -> HRESULT ---
	// InitPropVariantFromInt64 :: proc(
	//   llVal:LONGLONG,
	//   ppropvar:^PROPVARIANT
	// ) -> HRESULT ---
}
 

@(default_calling_convention="system")
foreign mfreadwrite {
  MFCreateSourceReaderFromURL :: proc(
     pwszURL: LPCWSTR,
     pAttributes: ^IMFAttributes,
     ppSourceReader: ^^IMFSourceReader,
  ) -> HRESULT ---

}

@(default_calling_convention="system")
foreign ole32 {
  CLSIDFromString :: proc(
    lpsz:   win32.LPCTSTR,
    pclsid: ^GUID,
  ) -> HRESULT ---
  IsEqualGUID :: proc(
    rguid1, rguid2: ^GUID
  ) -> bool ---
}

@(default_calling_convention="system")
foreign mfplat {
  MFTEnumEx :: proc(
    guidCategory:       GUID,
    Flags:              MFT_ENUM_FLAGS,
    pInputType:        ^MFT_REGISTER_TYPE_INFO,
    pOutputType:       ^MFT_REGISTER_TYPE_INFO,
    pppMFTActivate:  ^^^IMFActivate,
    pnumMFTActivat:    ^UINT32,
  ) -> HRESULT ---
  MFStartup :: proc(
    Version: ULONG,
    dwFlags: DWORD,
  ) -> HRESULT ---
  MFCreateMediaType :: proc(
    ppMFType: ^^IMFMediaType,
  ) -> HRESULT ---
  MFCreateAttributes :: proc(
    ppMFAttributes:^^IMFAttributes,
    cInitialSize:UINT32
  ) -> HRESULT ---

  MFCreateDXGIDeviceManager :: proc(
    resetToken:^UINT,
    ppDeviceManager:^^IMFDXGIDeviceManager,
  ) -> HRESULT ---
}

MYPROPVARIANT :: struct {
  vt:         USHORT,
  wReserved1: WORD,
  wReserved2: WORD,
  wReserved3: WORD,
  value: struct #raw_union {
    hVal:                       i64,
  }
}

IUnknown :: struct {
	using _iunknown_vtable: ^IUnknown_VTable,
}

IUnknown_VTable :: struct {
	QueryInterface: proc "system" (this: ^IUnknown, riid: ^IID, ppvObject: ^rawptr) -> HRESULT,
	AddRef:         proc "system" (this: ^IUnknown) -> ULONG,
	Release:        proc "system" (this: ^IUnknown) -> ULONG,
}

//-----------------------

IMFCollection :: struct #raw_union {
	#subtype iunknown: IUnknown,
	using imfcollection_vtable: ^IMFCollection_VTable,
}

IMFCollection_VTable :: struct {
	using iunknown_vtable: IUnknown_VTable,
	// AddElement         proc "system" (this: ^IMFCollection,) -> HRESULT,
	// GetElement         proc "system" (this: ^IMFCollection,) -> HRESULT,
	// GetElementCount    proc "system" (this: ^IMFCollection,) -> HRESULT,
	// InsertElementAt    proc "system" (this: ^IMFCollection,) -> HRESULT,
	// RemoveAllElements  proc "system" (this: ^IMFCollection,) -> HRESULT,
	// RemoveElement      proc "system" (this: ^IMFCollection,) -> HRESULT,
}

//-----------------------

IMFAttributes :: struct #raw_union {
	#subtype iunknown: IUnknown,
	using imfattributes_vtable: ^IMFAttributes_VTable,
}

IMFAttributes_VTable :: struct {
	using iunknown_vtable: IUnknown_VTable,
  GetItem:            proc "system" (this: ^IMFAttributes, guidKey:REFGUID, pValue:^PROPVARIANT) -> HRESULT,
  GetItemType:        proc "system" (this: ^IMFAttributes, guidKey:REFGUID, pType:^MF_ATTRIBUTE_TYPE) -> HRESULT,
  CompareItem:        proc "system" (this: ^IMFAttributes, guidKey:REFGUID,Value:REFPROPVARIANT,pbResult:^BOOL) -> HRESULT,
  Compare:            proc "system" (this: ^IMFAttributes, pTheirs:^IMFAttributes, MatchType:MF_ATTRIBUTES_MATCH_TYPE,pbResult:^BOOL) -> HRESULT,
  GetUINT32:          proc "system" (this: ^IMFAttributes, guidKey:REFGUID, punValue:^UINT32) -> HRESULT,
  GetUINT64:          proc "system" (this: ^IMFAttributes, guidKey:REFGUID, punValue:^UINT64) -> HRESULT,
  GetDouble:          proc "system" (this: ^IMFAttributes, guidKey:REFGUID, pfValue:^double) -> HRESULT,
  GetGUID:            proc "system" (this: ^IMFAttributes, guidKey:REFGUID, pguidValue:^GUID) -> HRESULT,
  GetStringLength:    proc "system" (this: ^IMFAttributes, guidKey:REFGUID, pcchLength:^UINT32) -> HRESULT,
  GetString:          proc "system" (this: ^IMFAttributes, guidKey:REFGUID, pwszValue:LPWSTR, cchBufSize:UINT32, pcchLength:UINT32) -> HRESULT,
  GetAllocatedString: proc "system" (this: ^IMFAttributes, guidKey:REFGUID, ppwszValue:^LPWSTR, pcchLength:^UINT32) -> HRESULT,
  GetBlobSize:        proc "system" (this: ^IMFAttributes, guidKey:REFGUID, pcbBlobSize:^UINT32) -> HRESULT,
  GetBlob:            proc "system" (this: ^IMFAttributes, guidKey:REFGUID, pBuf:^UINT8, cbBufSize:UINT32,  pcbBlobSize:^UINT32) -> HRESULT,
  GetAllocatedBlob:   proc "system" (this: ^IMFAttributes, guidKey:REFGUID, ppBuf:^^UINT8, pcbSize:^UINT32) -> HRESULT,
  GetUnknown:         proc "system" (this: ^IMFAttributes, guidKey:REFGUID, riid:REFIID, ppv:^LPVOID) -> HRESULT,
  SetItem:            proc "system" (this: ^IMFAttributes, guidKey:REFGUID, Value:REFPROPVARIANT) -> HRESULT,
  DeleteItem:         proc "system" (this: ^IMFAttributes, guidKey:REFGUID) -> HRESULT,
  DeleteAllItems:     proc "system" (this: ^IMFAttributes) -> HRESULT,
  SetUINT32:          proc "system" (this: ^IMFAttributes, guidKey:REFGUID, unValue:UINT32) -> HRESULT,
  SetUINT64:          proc "system" (this: ^IMFAttributes, guidKey:REFGUID, unValue:UINT64) -> HRESULT,
  SetDouble:          proc "system" (this: ^IMFAttributes, guidKey:REFGUID, fValue:double) -> HRESULT,
  SetGUID:            proc "system" (this: ^IMFAttributes, guidKey:REFGUID, guidValue:REFGUID) -> HRESULT,
  SetString:          proc "system" (this: ^IMFAttributes, guidKey:REFGUID, wszValue:LPCWSTR) -> HRESULT,
  SetBlob:            proc "system" (this: ^IMFAttributes, guidKey:REFGUID, pBuf:^UINT8, cbBufSize:UINT32) -> HRESULT,
  SetUnknown:         proc "system" (this: ^IMFAttributes, guidKey:REFGUID, pUnknown:^IUnknown) -> HRESULT,
  LockStore:          proc "system" (this: ^IMFAttributes) -> HRESULT,
  UnlockStore:        proc "system" (this: ^IMFAttributes) -> HRESULT,
  GetCount:           proc "system" (this: ^IMFAttributes, pcItems:^UINT32) -> HRESULT,
  GetItemByIndex:     proc "system" (this: ^IMFAttributes, unIndex:UINT32, pguidKey:^GUID, pValue:^PROPVARIANT) -> HRESULT,
  CopyAllItems:       proc "system" (this: ^IMFAttributes, pDest:^IMFAttributes) -> HRESULT,
}

//-------------------

IMFActivate :: struct #raw_union {
	#subtype imfattributes: IMFAttributes,
	using imfactivate_vtable: ^IMFActivate_VTable,
}

IMFActivate_VTable :: struct {
	using imfattributes_vtable: IMFAttributes_VTable,
	ActivateObject:       proc "system" (this: ^IMFActivate, guid: ^GUID, ppDevice: ^rawptr) -> HRESULT,
	ShutdownObject:       proc "system" (this: ^IMFActivate) -> HRESULT,
	DetatchObject:        proc "system" (this: ^IMFActivate) -> HRESULT,
}

//----------------------

IMFSample :: struct #raw_union {
	#subtype imfattributes: IMFAttributes,
	using imfsample_vtable: ^IMFSample_VTable,
}

IMFSample_VTable :: struct {
	using imfattributes_vtable: IMFAttributes_VTable,
  GetSampleFlags:           proc "system" (this: ^IMFSample, pdwSampleFlags: ^DWORD) -> HRESULT,
  SetSampleFlags:           proc "system" (this: ^IMFSample, dwSampleFlags: DWORD) -> HRESULT,
  GetSampleTime:            proc "system" (this: ^IMFSample, phnsSampleTime: ^LONGLONG) -> HRESULT,
  SetSampleTime:            proc "system" (this: ^IMFSample, hnsSampleTime: LONGLONG) -> HRESULT,
  GetSampleDuration:        proc "system" (this: ^IMFSample, phnsSampleDuration: ^LONGLONG) -> HRESULT,
  SetSampleDuration:        proc "system" (this: ^IMFSample, hnsSampleDuration: LONGLONG) -> HRESULT,
  GetBufferCount:           proc "system" (this: ^IMFSample, pdwBufferCount: ^DWORD) -> HRESULT,
  GetBufferByIndex:         proc "system" (this: ^IMFSample, dwIndex: DWORD,ppBuffer: ^^IMFMediaBuffer) -> HRESULT,
  ConvertToContiguousBuffer:proc "system" (this: ^IMFSample, ppBuffer: ^^IMFMediaBuffer) -> HRESULT,
  AddBuffer:                proc "system" (this: ^IMFSample, pBuffer: ^IMFMediaBuffer) -> HRESULT,
  RemoveBufferByIndex:      proc "system" (this: ^IMFSample, dwIndex: DWORD) -> HRESULT,
  RemoveAllBuffers:         proc "system" (this: ^IMFSample) -> HRESULT,
  GetTotalLength:           proc "system" (this: ^IMFSample, pcbTotalLength:^DWORD) -> HRESULT,
  CopyToBuffer:             proc "system" (this: ^IMFSample, pBuffer:^IMFMediaBuffer) -> HRESULT,
}

//----------------------

IMFMediaEvent :: struct #raw_union {
	#subtype imfattributes: IMFAttributes,
	using imfmediaevent_vtable: ^IMFMediaEvent_VTable,
}

IMFMediaEvent_VTable :: struct {
	using imfattributes_vtable: IMFAttributes_VTable,
	GetExtendedType: proc "system" (this: ^IMFMediaEvent, pguidExtendedType:^GUID) -> HRESULT,
	GetStatus:       proc "system" (this: ^IMFMediaEvent, phrStatus:HRESULT) -> HRESULT,
	GetType:         proc "system" (this: ^IMFMediaEvent, pmet:^MediaEventType) -> HRESULT,
	GetValue:        proc "system" (this: ^IMFMediaEvent, pvValue:^PROPVARIANT) -> HRESULT,
}

//----------------------

IMFMediaType :: struct #raw_union {
	#subtype imfattributes: IMFAttributes,
	using imfmediatype_vtable: ^IMFMediaType_VTable,
}

IMFMediaType_VTable :: struct {
	using imfattributes_vtable: IMFAttributes_VTable,
	GetMajorType:        proc "system" (this: ^IMFMediaType, pguidMajorType:^GUID) -> HRESULT,
	IsCompressedFormat:  proc "system" (this: ^IMFMediaType, pfCompressed:^BOOL) -> HRESULT,
	IsEqual:             proc "system" (this: ^IMFMediaType, pIMediaType:^IMFMediaType, pdwFlags:^DWORD) -> HRESULT,
	GetRepresentation:   proc "system" (this: ^IMFMediaType, guidRepresentation:GUID, ppvRepresentation:^LPVOID) -> HRESULT,
	FreeRepresentation:  proc "system" (this: ^IMFMediaType, guidRepresentation:GUID, pvRepresentation: LPVOID) -> HRESULT,
}

IMFMediaBuffer :: struct #raw_union {
	#subtype iunknown: IUnknown,
	using imfmediabuffer_vtable: ^IMFMediaBuffer_VTable,
}

//----------------------

IMFMediaBuffer_VTable :: struct {
	using iunknown_vtable: IUnknown_VTable,
  Lock: proc "system" (this: ^IMFMediaBuffer, ppbBuffer: ^^BYTE, pcbMaxLength: ^DWORD, pcbCurrentLength: ^DWORD) -> HRESULT,
  Unlock: proc "system" (this: ^IMFMediaBuffer, ) -> HRESULT,
  GetCurrentLength: proc "system" (this: ^IMFMediaBuffer, pcbCurrentLength:^DWORD) -> HRESULT,
  SetCurrentLength: proc "system" (this: ^IMFMediaBuffer, cbCurrentLength:DWORD) -> HRESULT,
  GetMaxLength: proc "system" (this: ^IMFMediaBuffer, pcbMaxLength:^DWORD) -> HRESULT,
}

//-----------------------

IMFSourceReader :: struct #raw_union {
	#subtype iunknown: IUnknown,
	using imfsourcereader_vtable: ^IMFSourceReader_VTable,
}

IMFSourceReader_VTable :: struct {
	using iunknown_vtable: IUnknown_VTable,
  GetStreamSelection:       proc "system" (this: ^IMFSourceReader, index:DWORD,selected:^BOOL) -> HRESULT,
  SetStreamSelection:       proc "system" (this: ^IMFSourceReader, index:DWORD,selected:BOOL) -> HRESULT,
  GetNativeMediaType:       proc "system" (this: ^IMFSourceReader, index:DWORD,typeindex:DWORD,type:^^IMFMediaType) -> HRESULT,
  GetCurrentMediaType:      proc "system" (this: ^IMFSourceReader, index:DWORD,type:^^IMFMediaType) -> HRESULT,
  SetCurrentMediaType:      proc "system" (this: ^IMFSourceReader, index:DWORD,reserved:^DWORD, type:^IMFMediaType) -> HRESULT,
  SetCurrentPosition:       proc "system" (this: ^IMFSourceReader, format:REFGUID,position:REFPROPVARIANT) -> HRESULT,
  ReadSample:               proc "system" (this: ^IMFSourceReader, index:DWORD,flags:DWORD,actualindex:^DWORD,sampleflags:^DWORD,timestamp:^LONGLONG,sample:^^IMFSample) -> HRESULT,
  Flush:                    proc "system" (this: ^IMFSourceReader, index:DWORD) -> HRESULT,
  GetServiceForStream:      proc "system" (this: ^IMFSourceReader, index:DWORD,service:REFGUID,riid:REFIID,object:^^rawptr) -> HRESULT,
  GetPresentationAttribute: proc "system" (this: ^IMFSourceReader, index:DWORD,guid:REFGUID,attr:^PROPVARIANT) -> HRESULT,
}

//-----------------------

IMFTransform_GUID := &IID{0xbf94c121, 0x5b05, 0x4e6f, {0x80,0x00, 0xba,0x59,0x89,0x61,0x41,0x4d}}
IMFTransform :: struct #raw_union {
  #subtype iunknown: IUnknown,
  using imftransform_vtable: ^IMFTransform_VTable,
}

IMFTransform_VTable :: struct {
  using iunknown_vtable: IUnknown_VTable,
  GetStreamLimits:           proc "system" (this: ^IMFTransform, pdwInputMinimum:^DWORD, pdwInputMaximum:^DWORD, pdwOutputMinimum:^DWORD, pdwOutputMaximum:^DWORD) -> HRESULT,
  GetStreamCount:            proc "system" (this: ^IMFTransform, pcInputStreams:^DWORD, pcOutputStreams:^DWORD) -> HRESULT,
  GetStreamIDs:              proc "system" (this: ^IMFTransform, dwInputIDArraySize:DWORD, pdwInputIDs:^DWORD, dwOutputIDArraySize:DWORD, pdwOutputIDs:^DWORD) -> HRESULT,
  GetInputStreamInfo:        proc "system" (this: ^IMFTransform, dwInputStreamID:DWORD, pStreamInfo:^MFT_INPUT_STREAM_INFO) -> HRESULT,
  GetOutputStreamInfo:       proc "system" (this: ^IMFTransform, dwInputStreamID:DWORD, pStreamInfo:^MFT_INPUT_STREAM_INFO) -> HRESULT,
  GetAttributes:             proc "system" (this: ^IMFTransform, pAttributes:^^IMFAttributes) -> HRESULT,
  GetInputStreamAttributes:  proc "system" (this: ^IMFTransform, dwInputStreamID:DWORD, pAttributes:^^IMFAttributes) -> HRESULT,
  GetOutputStreamAttributes: proc "system" (this: ^IMFTransform, dwInputStreamID:DWORD, pAttributes:^^IMFAttributes) -> HRESULT,
  DeleteInputStream:         proc "system" (this: ^IMFTransform, dwStreamID:DWORD) -> HRESULT,
  AddInputStreams:           proc "system" (this: ^IMFTransform, cStreams:DWORD, adwStreamIDs:^DWORD) -> HRESULT,
  GetInputAvailableType:     proc "system" (this: ^IMFTransform, dwInputStreamID:DWORD, dwTypeIndex:DWORD, ppType:^^IMFMediaType) -> HRESULT,
  GetOutputAvailableType:    proc "system" (this: ^IMFTransform, dwInputStreamID:DWORD, dwTypeIndex:DWORD, ppType:^^IMFMediaType) -> HRESULT,
  SetInputType:              proc "system" (this: ^IMFTransform, dwInputStreamID:DWORD, pType:^IMFMediaType, dwFlags:DWORD) -> HRESULT,
  SetOutputType:             proc "system" (this: ^IMFTransform, dwOuputStreamID:DWORD, pType:^IMFMediaType, dwFlags:DWORD) -> HRESULT,
  GetInputCurrentType:       proc "system" (this: ^IMFTransform, dwInputStreamID:DWORD, ppType:^^IMFMediaType) -> HRESULT,
  GetOutputCurrentType:      proc "system" (this: ^IMFTransform, dwInputStreamID:DWORD, ppType:^^IMFMediaType) -> HRESULT,
  GetInputStatus:            proc "system" (this: ^IMFTransform, dwInputStreamID:DWORD, pdwFlags:^DWORD) -> HRESULT,
  GetOutputStatus:           proc "system" (this: ^IMFTransform, pdwFlags:^DWORD) -> HRESULT,
  SetOutputBounds:           proc "system" (this: ^IMFTransform, hnsLowerBound:LONGLONG, hnsUpperBound:LONGLONG) -> HRESULT,
  ProcessEvent:              proc "system" (this: ^IMFTransform, dwInputStreamID:DWORD, pEvent:^IMFMediaEvent) -> HRESULT,
  ProcessMessage:            proc "system" (this: ^IMFTransform, eMessage: MFT_MESSAGE_TYPE, ulParam:ULONG_PTR) -> HRESULT,
  ProcessInput:              proc "system" (this: ^IMFTransform, dwInputStreamID:DWORD, pSample:^IMFSample, dwFlags:DWORD) -> HRESULT,
  ProcessOutput:             proc "system" (this: ^IMFTransform, dwFlags:DWORD, cOutputBufferCount:DWORD, pOutputSamples:^MFT_OUTPUT_DATA_BUFFER, pdwStatus:^DWORD) -> HRESULT,
}

//-----------------------

IID_IMFDXGIDeviceManager := &IID{0xeb533d5d, 0x2db6, 0x40f8, {0x97,0xa9, 0x49,0x46,0x92,0x01,0x4f,0x07}}
IMFDXGIDeviceManager :: struct #raw_union {
	#subtype iunknown: IUnknown,
	using imfdxgidevicemanager_vtable: ^IMFDXGIDeviceManager_VTable,
}

IMFDXGIDeviceManager_VTable :: struct {
	using iunknown_vtable: IUnknown_VTable,
  CloseDeviceHandle: proc "system" (this: ^IMFDXGIDeviceManager, hDevice:HANDLE) -> HRESULT,
  GetVideoService:   proc "system" (this: ^IMFDXGIDeviceManager, hDevice:HANDLE, riid:REFIID, ppService:^^rawptr) -> HRESULT,
  LockDevice:        proc "system" (this: ^IMFDXGIDeviceManager, hDevice:HANDLE, riid:REFIID, ppUnkDevice:^^rawptr, fBlock:BOOL) -> HRESULT,
  OpenDeviceHandle:  proc "system" (this: ^IMFDXGIDeviceManager, phDevice:HANDLE) -> HRESULT,
  ResetDevice:       proc "system" (this: ^IMFDXGIDeviceManager, pUnkDevice:^IUnknown, resetToken:UINT) -> HRESULT,
  TestDevice:        proc "system" (this: ^IMFDXGIDeviceManager, hDevice:HANDLE) -> HRESULT,
  UnlockDevice:      proc "system" (this: ^IMFDXGIDeviceManager, hDevice:HANDLE, fSaveState:BOOL) -> HRESULT,
}

//-----------------------

IID_IMFDXGIBuffer := &IID{0xe7174cfa, 0x1c9e, 0x48b1, {0x88,0x66, 0x62,0x62,0x26,0xbf,0xc2,0x58}}
IMFDXGIBuffer :: struct #raw_union {
	#subtype iunknown: IUnknown,
	using imfdxgibuffer_vtable: ^IMFDXGIBuffer_VTable,
}

IMFDXGIBuffer_VTable :: struct {
	using iunknown_vtable: IUnknown_VTable,
  GetResource:         proc "system" (this: ^IMFDXGIBuffer, riid:REFIID,ppvObject: ^rawptr) -> HRESULT,
	GetSubresourceIndex: proc "system" (this: ^IMFDXGIBuffer, puSubresource:^UINT) -> HRESULT,
	GetUnknown:          proc "system" (this: ^IMFDXGIBuffer, guid:REFIID, riid:REFIID, ppvObject: ^rawptr) -> HRESULT,
  SetUnknown:          proc "system" (this: ^IMFDXGIBuffer, guid:REFIID, pUnkData:^IUnknown) -> HRESULT,
}

//-----------------------

IMultithread_UUID_STRING :: "9B7E4E00-342C-4106-A19F-4F2704F689F0"
IMultithread_UUID := &IID{0x9B7E4E00,0x342C,0x4106,{0xA1,0x9F,0x4F,0x27,0x04,0xF6,0x89,0xF0}}
IMultithread :: struct #raw_union {
  #subtype iunknown: IUnknown,
  using imultithread_vtable: ^IMultithread_VTable,
}
IMultithread_VTable :: struct {
  using iunknown_vtable: IUnknown_VTable,
  Enter:                   proc "system" (this: ^IMultithread) -> HRESULT,
  Leave:                   proc "system" (this: ^IMultithread) -> HRESULT,
  SetMultithreadProtected: proc "system" (this: ^IMultithread, bMTProtect:BOOL) -> BOOL,
  GetMultithreadProtected: proc "system" (this: ^IMultithread) -> BOOL,
}


MFT_ENUM_FLAGS :: distinct bit_set[MFT_ENUM_FLAG; u32]
MFT_ENUM_FLAG :: enum u32 {
	SYNCMFT                         = 0,  // 0x00000001 bit 0
	ASYNCMFT                        = 1,  // 0x00000002 bit 1
	HARDWARE                        = 2,  // 0x00000004 bit 2
	FIELDOFUSE                      = 3,  // 0x00000008 bit 3
	LOCALMFT                        = 4,  // 0x00000010 bit 4
	TRANSCODE_ONLY                  = 5,  // 0x00000020 bit 5
	SORTANDFILTER                   = 6,  // 0x00000040 bit 6
	APPROVED_ONLY                   = 7,  // 0x000000C0 bit 6 AND 7
	WEB_ONLY                        = 8,  // 0x00000140 bit 6 AND 8
	EDGEMODE                        = 9,  // 0x00000240 bit 6 AND 9
	UNTRUSTED_STOREMFT              = 10, // 0x00000400 bit 10
	// ALL                             = ?,  // 0x0000003F bits 0, 1, 2, 3, 4, 5
}

get_guid_from_string :: proc(str:string) -> IID {
  clsid := win32.utf8_to_wstring(str)
  guid: GUID
  CLSIDFromString(clsid, &guid)
  return guid
}

GUID_NULL                      := &IID{0x00000000, 0x0000, 0x0000, {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}}

CLSID_CMSH264DecoderMFT := get_guid_from_string("{62CE7E72-4C71-4d20-B15D-452831A87D9D}")
CLSID_CMSH264EncoderMFT := get_guid_from_string("{6ca50344-051a-4ded-9779-a43305165e35}")

MF_MT_MAJOR_TYPE                := IID{0x48eba18e, 0xf8c9, 0x4687, {0xbf, 0x11, 0x0a, 0x74, 0xc9, 0xf9, 0x6a, 0x8f}}
MF_MT_SUBTYPE                   := IID{0xf7e34c9a, 0x42e8, 0x4714, {0xb7, 0x4b, 0xcb, 0x29, 0xd7, 0x2c, 0x35, 0xe5}}
MF_MT_ALL_SAMPLES_INDEPENDENT   := IID{0xc9173739, 0x5e56, 0x461c, {0xb7, 0x13, 0x46, 0xfb, 0x99, 0x5c, 0xb9, 0x5f}}
MF_MT_FIXED_SIZE_SAMPLES        := IID{0xb8ebefaf, 0xb718, 0x4e04, {0xb0, 0xa9, 0x11, 0x67, 0x75, 0xe3, 0x32, 0x1b}}
MF_MT_COMPRESSED                := IID{0x3afd0cee, 0x18f2, 0x4ba5, {0xa1, 0x10, 0x8b, 0xea, 0x50, 0x2e, 0x1f, 0x92}}
MF_MT_SAMPLE_SIZE               := IID{0xdad3ab78, 0x1990, 0x408b, {0xbc, 0xe2, 0xeb, 0xa6, 0x73, 0xda, 0xcc, 0x10}}
MF_MT_WRAPPED_TYPE              := IID{0x4d3f7b23, 0xd02f, 0x4e6c, {0x9b, 0xee, 0xe4, 0xbf, 0x2c, 0x6c, 0x69, 0x5d}}

MFT_CATEGORY_VIDEO_DECODER := IID{0xd6c02d4b, 0x6833, 0x45b4, {0x97, 0x1a, 0x05, 0xa4, 0xb0, 0x4b, 0xab, 0x91}}
MFT_CATEGORY_VIDEO_ENCODER := IID{0xf79eac7d, 0xe545, 0x4387, {0xbd, 0xee, 0xd6, 0x47, 0xd7, 0xbd, 0xe4, 0x2a}}
MFT_CATEGORY_VIDEO_EFFECT  := IID{0x12e17c21, 0x532c, 0x4a6e, {0x8a, 0x1c, 0x40, 0x82, 0x5a, 0x73, 0x63, 0x97}}
MFT_CATEGORY_MULTIPLEXER   := IID{0x059c561e, 0x05ae, 0x4b61, {0xb6, 0x9d, 0x55, 0xb6, 0x1e, 0xe5, 0x4a, 0x7b}}
MFT_CATEGORY_DEMULTIPLEXER := IID{0xa8700a7a, 0x939b, 0x44c5, {0x99, 0xd7, 0x76, 0x22, 0x6b, 0x23, 0xb3, 0xf1}}
MFT_CATEGORY_AUDIO_DECODER := IID{0x9ea73fb4, 0xef7a, 0x4559, {0x8d, 0x5d, 0x71, 0x9d, 0x8f, 0x04, 0x26, 0xc7}}
MFT_CATEGORY_AUDIO_ENCODER := IID{0x91c64bd0, 0xf91e, 0x4d8c, {0x92, 0x76, 0xdb, 0x24, 0x82, 0x79, 0xd9, 0x75}}
MFT_CATEGORY_AUDIO_EFFECT  := IID{0x11064c48, 0x3648, 0x4ed0, {0x93, 0x2e, 0x05, 0xce, 0x8a, 0xc8, 0x11, 0xb7}}

D3DFMT_R8G8B8        :: 20
D3DFMT_A8R8G8B8      :: 21
D3DFMT_X8R8G8B8      :: 22
D3DFMT_R5G6B5        :: 23
D3DFMT_X1R5G5B5      :: 24
D3DFMT_A2B10G10R10   :: 31
D3DFMT_P8            :: 41
D3DFMT_L8            :: 50
D3DFMT_D16           :: 80
D3DFMT_L16           :: 81
D3DFMT_A16B16G16R16F :: 113
LOCAL_D3DFMT_DEFINES :: 1

FCC :: proc(l:string) -> DWORD {
	assert(len(l)==4)
	result : [4]byte
	for letter, li in l { result[li] = u8(letter)	}
	return ((^DWORD)(&result[0]))^
}

MFVideoFormat_Base      := IID{0x00000000,       0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_RGB32     := IID{D3DFMT_X8R8G8B8,  0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_ARGB32    := IID{D3DFMT_A8R8G8B8,  0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_RGB24     := IID{D3DFMT_R8G8B8,    0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_RGB555    := IID{D3DFMT_X1R5G5B5,  0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_RGB565    := IID{D3DFMT_R5G6B5,    0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_RGB8      := IID{D3DFMT_P8,        0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_L8        := IID{D3DFMT_L8,        0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_L16       := IID{D3DFMT_L16,       0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_D16       := IID{D3DFMT_D16,       0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_AI44      := IID{FCC("AI44"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_AYUV      := IID{FCC("AYUV"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_YUY2      := IID{FCC("YUY2"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_YVYU      := IID{FCC("YVYU"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_YVU9      := IID{FCC("YVU9"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_UYVY      := IID{FCC("UYVY"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_NV11      := IID{FCC("NV11"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_NV12      := IID{FCC("NV12"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_YV12      := IID{FCC("YV12"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_I420      := IID{FCC("I420"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_IYUV      := IID{FCC("IYUV"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_Y210      := IID{FCC("Y210"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_Y216      := IID{FCC("Y216"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_Y410      := IID{FCC("Y410"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_Y416      := IID{FCC("Y416"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_Y41P      := IID{FCC("Y41P"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_Y41T      := IID{FCC("Y41T"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_Y42T      := IID{FCC("Y42T"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_P210      := IID{FCC("P210"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_P216      := IID{FCC("P216"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_P010      := IID{FCC("P010"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_P016      := IID{FCC("P016"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_v210      := IID{FCC("v210"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_v216      := IID{FCC("v216"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_v410      := IID{FCC("v410"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_MP43      := IID{FCC("MP43"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_MP4S      := IID{FCC("MP4S"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_M4S2      := IID{FCC("M4S2"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_MP4V      := IID{FCC("MP4V"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_WMV1      := IID{FCC("WMV1"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_WMV2      := IID{FCC("WMV2"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_WMV3      := IID{FCC("WMV3"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_WVC1      := IID{FCC("WVC1"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_MSS1      := IID{FCC("MSS1"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_MSS2      := IID{FCC("MSS2"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_MPG1      := IID{FCC("MPG1"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_DVSL      := IID{FCC("dvsl"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_DVSD      := IID{FCC("dvsd"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_DVHD      := IID{FCC("dvhd"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_DV25      := IID{FCC("dv25"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_DV50      := IID{FCC("dv50"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_DVH1      := IID{FCC("dvh1"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_DVC       := IID{FCC("dvc "),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_H264      := IID{FCC("H264"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_H265      := IID{FCC("H265"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_MJPG      := IID{FCC("MJPG"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_420O      := IID{FCC("420O"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_HEVC      := IID{FCC("HEVC"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_HEVC_ES   := IID{FCC("HEVS"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_VP80      := IID{FCC("VP80"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_VP90      := IID{FCC("VP90"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFVideoFormat_ORAW      := IID{FCC("ORAW"),      0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}

CLSID_MFReadWriteClassFactory :=                       &IID{0x48e2ed0f, 0x98c2, 0x4a37, {0xbe, 0xd5, 0x16, 0x63, 0x12, 0xdd, 0xd8, 0x3f}}
CLSID_MFSourceReader :=                                &IID{0x1777133c, 0x0881, 0x411b, {0xa5, 0x77, 0xad, 0x54, 0x5f, 0x07, 0x14, 0xc4}}
CLSID_MFSinkWriter :=                                  &IID{0xa3bbfb17, 0x8273, 0x4e52, {0x9e, 0x0e, 0x97, 0x39, 0xdc, 0x88, 0x79, 0x90}}
MF_MEDIASINK_AUTOFINALIZE_SUPPORTED :=                 &IID{0x48c131be, 0x135a, 0x41cb, {0x82, 0x90, 0x03, 0x65, 0x25, 0x09, 0xc9, 0x99}}
MF_MEDIASINK_ENABLE_AUTOFINALIZE :=                    &IID{0x34014265, 0xcb7e, 0x4cde, {0xac, 0x7c, 0xef, 0xfd, 0x3b, 0x3c, 0x25, 0x30}}
MF_SINK_WRITER_ASYNC_CALLBACK :=                       &IID{0x48cb183e, 0x7b0b, 0x46f4, {0x82, 0x2e, 0x5e, 0x1d, 0x2d, 0xda, 0x43, 0x54}}
MF_SINK_WRITER_DISABLE_THROTTLING :=                   &IID{0x08b845d8, 0x2b74, 0x4afe, {0x9d, 0x53, 0xbe, 0x16, 0xd2, 0xd5, 0xae, 0x4f}}
MF_SINK_WRITER_D3D_MANAGER :=                          &IID{0xec822da2, 0xe1e9, 0x4b29, {0xa0, 0xd8, 0x56, 0x3c, 0x71, 0x9f, 0x52, 0x69}}
MF_SINK_WRITER_ENCODER_CONFIG :=                       &IID{0xad91cd04, 0xa7cc, 0x4ac7, {0x99, 0xb6, 0xa5, 0x7b, 0x9a, 0x4a, 0x7c, 0x70}}
MF_READWRITE_DISABLE_CONVERTERS :=                     &IID{0x98d5b065, 0x1374, 0x4847, {0x8d, 0x5d, 0x31, 0x52, 0x0f, 0xee, 0x71, 0x56}}
MF_READWRITE_ENABLE_AUTOFINALIZE :=                    &IID{0xdd7ca129, 0x8cd1, 0x4dc5, {0x9d, 0xde, 0xce, 0x16, 0x86, 0x75, 0xde, 0x61}}
MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS :=             &IID{0xa634a91c, 0x822b, 0x41b9, {0xa4, 0x94, 0x4d, 0xe4, 0x64, 0x36, 0x12, 0xb0}}
MF_READWRITE_MMCSS_CLASS :=                            &IID{0x39384300, 0xd0eb, 0x40b1, {0x87, 0xa0, 0x33, 0x18, 0x87, 0x1b, 0x5a, 0x53}}
MF_READWRITE_MMCSS_PRIORITY :=                         &IID{0x43ad19ce, 0xf33f, 0x4ba9, {0xa5, 0x80, 0xe4, 0xcd, 0x12, 0xf2, 0xd1, 0x44}}
MF_READWRITE_MMCSS_CLASS_AUDIO :=                      &IID{0x430847da, 0x0890, 0x4b0e, {0x93, 0x8c, 0x05, 0x43, 0x32, 0xc5, 0x47, 0xe1}}
MF_READWRITE_MMCSS_PRIORITY_AUDIO :=                   &IID{0x273db885, 0x2de2, 0x4db2, {0xa6, 0xa7, 0xfd, 0xb6, 0x6f, 0xb4, 0x0b, 0x61}}
MF_READWRITE_D3D_OPTIONAL :=                           &IID{0x216479d9, 0x3071, 0x42ca, {0xbb, 0x6c, 0x4c, 0x22, 0x10, 0x2e, 0x1d, 0x18}}
MF_SOURCE_READER_ASYNC_CALLBACK :=                     &IID{0x1e3dbeac, 0xbb43, 0x4c35, {0xb5, 0x07, 0xcd, 0x64, 0x44, 0x64, 0xc9, 0x65}}
MF_SOURCE_READER_D3D_MANAGER :=                        &IID{0xec822da2, 0xe1e9, 0x4b29, {0xa0, 0xd8, 0x56, 0x3c, 0x71, 0x9f, 0x52, 0x69}}
MF_SOURCE_READER_D3D11_BIND_FLAGS :=                   &IID{0x33f3197b, 0xf73a, 0x4e14, {0x8d, 0x85, 0x0e, 0x4c, 0x43, 0x68, 0x78, 0x8d}}
MF_SOURCE_READER_DISABLE_CAMERA_PLUGINS :=             &IID{0x9d3365dd, 0x058f, 0x4cfb, {0x9f, 0x97, 0xb3, 0x14, 0xcc, 0x99, 0xc8, 0xad}}
MF_SOURCE_READER_DISABLE_DXVA :=                       &IID{0xaa456cfd, 0x3943, 0x4a1e, {0xa7, 0x7d, 0x18, 0x38, 0xc0, 0xea, 0x2e, 0x35}}
MF_SOURCE_READER_DISCONNECT_MEDIASOURCE_ON_SHUTDOWN := &IID{0x56b67165, 0x219e, 0x456d, {0xa2, 0x2e, 0x2d, 0x30, 0x04, 0xc7, 0xfe, 0x56}}
MF_SOURCE_READER_ENABLE_ADVANCED_VIDEO_PROCESSING :=   &IID{0x0f81da2c, 0xb537, 0x4672, {0xa8, 0xb2, 0xa6, 0x81, 0xb1, 0x73, 0x07, 0xa3}}
MF_SOURCE_READER_ENABLE_TRANSCODE_ONLY_TRANSFORMS :=   &IID{0xdfd4f008, 0xb5fd, 0x4e78, {0xae, 0x44, 0x62, 0xa1, 0xe6, 0x7b, 0xbe, 0x27}}
MF_SOURCE_READER_ENABLE_VIDEO_PROCESSING :=            &IID{0xfb394f3d, 0xccf1, 0x42ee, {0xbb, 0xb3, 0xf9, 0xb8, 0x45, 0xd5, 0x68, 0x1d}}
MF_SOURCE_READER_MEDIASOURCE_CHARACTERISTICS :=        &IID{0x6d23f5c8, 0xc5d7, 0x4a9b, {0x99, 0x71, 0x5d, 0x11, 0xf8, 0xbc, 0xa8, 0x80}}
MF_SOURCE_READER_MEDIASOURCE_CONFIG :=                 &IID{0x9085abeb, 0x0354, 0x48f9, {0xab, 0xb5, 0x20, 0x0d, 0xf8, 0x38, 0xc6, 0x8e}}

MFVideoFormat_H264_ES := &IID{0x3f40f4f0, 0x5622, 0x4ff8, {0xb6, 0xd8, 0xa1, 0x7a, 0x58, 0x4b, 0xee, 0x5e}}
MFVideoFormat_MPEG2 := &IID{0xe06d8026, 0xdb46, 0x11cf, {0xb4, 0xd1, 0x00, 0x80, 0x5f, 0x6c, 0xbb, 0xea}}
// MFAudioFormat_Base := &IID{0x00000000);
// MFAudioFormat_PCM :{= &IID{WAVE_FORMAT_PCM}}
// MFAudioFormat_Float :{= &IID{WAVE_FORMAT_IEEE_FLOAT}}
// MFAudioFormat_DTS :{= &IID{WAVE_FORMAT_DTS}}
// MFAudioFormat_Dolby_AC3_SPDIF :{= &IID{WAVE_FORMAT_DOLBY_AC3_SPDIF}}
// MFAudioFormat_DRM :{= &IID{WAVE_FORMAT_DRM}}
// MFAudioFormat_WMAudioV8 :{= &IID{WAVE_FORMAT_WMAUDIO2}}
// MFAudioFormat_WMAudioV9 :{= &IID{WAVE_FORMAT_WMAUDIO3}}
// MFAudioFormat_WMAudio_Lossless :{= &IID{WAVE_FORMAT_WMAUDIO_LOSSLESS}}
// MFAudioFormat_WMASPDIF :{= &IID{WAVE_FORMAT_WMASPDIF}}
// MFAudioFormat_MSP1 :{= &IID{WAVE_FORMAT_WMAVOICE9}}
// MFAudioFormat_MP3 :{= &IID{WAVE_FORMAT_MPEGLAYER3}}
// MFAudioFormat_MPEG :{= &IID{WAVE_FORMAT_MPEG}}
// MFAudioFormat_AAC :{= &IID{WAVE_FORMAT_MPEG_HEAAC}}
// MFAudioFormat_ADTS :{= &IID{WAVE_FORMAT_MPEG_ADTS_AAC}}
MFAudioFormat_Dolby_AC3                 := &IID{0xe06d802c, 0xdb46, 0x11cf, {0xb4, 0xd1, 0x00, 0x80, 0x05f, 0x6c, 0xbb, 0xea}}
MFAudioFormat_Dolby_DDPlus              := &IID{0xa7fb87af, 0x2d02, 0x42fb, {0xa4, 0xd4, 0x5, 0xcd, 0x93, 0x84, 0x3b, 0xdd}}
MFMPEG4Format_Base                      := &IID{0x00000000, 0x767a, 0x494d, {0xb4, 0x78, 0xf2, 0x9d, 0x25, 0xdc, 0x90, 0x37}}
MF_MT_AUDIO_NUM_CHANNELS                := &IID{0x37e48bf5, 0x645e, 0x4c5b, {0x89, 0xde, 0xad, 0xa9, 0xe2, 0x9b, 0x69, 0x6a}}
MF_MT_AUDIO_SAMPLES_PER_SECOND          := &IID{0x5faeeae7, 0x0290, 0x4c31, {0x9e, 0x8a, 0xc5, 0x34, 0xf6, 0x8d, 0x9d, 0xba}}
MF_MT_AUDIO_FLOAT_SAMPLES_PER_SECOND    := &IID{0xfb3b724a, 0xcfb5, 0x4319, {0xae, 0xfe, 0x6e, 0x42, 0xb2, 0x40, 0x61, 0x32}}
MF_MT_AUDIO_AVG_BYTES_PER_SECOND        := &IID{0x1aab75c8, 0xcfef, 0x451c, {0xab, 0x95, 0xac, 0x03, 0x4b, 0x8e, 0x17, 0x31}}
MF_MT_AUDIO_BLOCK_ALIGNMENT             := &IID{0x322de230, 0x9eeb, 0x43bd, {0xab, 0x7a, 0xff, 0x41, 0x22, 0x51, 0x54, 0x1d}}
MF_MT_AUDIO_BITS_PER_SAMPLE             := &IID{0xf2deb57f, 0x40fa, 0x4764, {0xaa, 0x33, 0xed, 0x4f, 0x2d, 0x1f, 0xf6, 0x69}}
MF_MT_AUDIO_VALID_BITS_PER_SAMPLE       := &IID{0xd9bf8d6a, 0x9530, 0x4b7c, {0x9d, 0xdf, 0xff, 0x6f, 0xd5, 0x8b, 0xbd, 0x06}}
MF_MT_AUDIO_SAMPLES_PER_BLOCK           := &IID{0xaab15aac, 0xe13a, 0x4995, {0x92, 0x22, 0x50, 0x1e, 0xa1, 0x5c, 0x68, 0x77}}
MF_MT_AUDIO_CHANNEL_MASK                := &IID{0x55fb5765, 0x644a, 0x4caf, {0x84, 0x79, 0x93, 0x89, 0x83, 0xbb, 0x15, 0x88}}
MF_MT_AUDIO_FOLDDOWN_MATRIX             := &IID{0x9d62927c, 0x36be, 0x4cf2, {0xb5, 0xc4, 0xa3, 0x92, 0x6e, 0x3e, 0x87, 0x11}}
MF_MT_AUDIO_WMADRC_PEAKREF              := &IID{0x9d62927d, 0x36be, 0x4cf2, {0xb5, 0xc4, 0xa3, 0x92, 0x6e, 0x3e, 0x87, 0x11}}
MF_MT_AUDIO_WMADRC_PEAKTARGET           := &IID{0x9d62927e, 0x36be, 0x4cf2, {0xb5, 0xc4, 0xa3, 0x92, 0x6e, 0x3e, 0x87, 0x11}}
MF_MT_AUDIO_WMADRC_AVGREF               := &IID{0x9d62927f, 0x36be, 0x4cf2, {0xb5, 0xc4, 0xa3, 0x92, 0x6e, 0x3e, 0x87, 0x11}}
MF_MT_AUDIO_WMADRC_AVGTARGET            := &IID{0x9d629280, 0x36be, 0x4cf2, {0xb5, 0xc4, 0xa3, 0x92, 0x6e, 0x3e, 0x87, 0x11}}
MF_MT_AUDIO_PREFER_WAVEFORMATEX         := &IID{0xa901aaba, 0xe037, 0x458a, {0xbd, 0xf6, 0x54, 0x5b, 0xe2, 0x07, 0x40, 0x42}}
MF_MT_FRAME_SIZE                        := &IID{0x1652c33d, 0xd6b2, 0x4012, {0xb8, 0x34, 0x72, 0x03, 0x08, 0x49, 0xa3, 0x7d}}
MF_MT_FRAME_RATE                        := &IID{0xc459a2e8, 0x3d2c, 0x4e44, {0xb1, 0x32, 0xfe, 0xe5, 0x15, 0x6c, 0x7b, 0xb0}}
MF_MT_PIXEL_ASPECT_RATIO                := &IID{0xc6376a1e, 0x8d0a, 0x4027, {0xbe, 0x45, 0x6d, 0x9a, 0x0a, 0xd3, 0x9b, 0xb6}}
MF_MT_DRM_FLAGS                         := &IID{0x8772f323, 0x355a, 0x4cc7, {0xbb, 0x78, 0x6d, 0x61, 0xa0, 0x48, 0xae, 0x82}}
MF_MT_PAD_CONTROL_FLAGS                 := &IID{0x4d0e73e5, 0x80ea, 0x4354, {0xa9, 0xd0, 0x11, 0x76, 0xce, 0xb0, 0x28, 0xea}}
MF_MT_SOURCE_CONTENT_HINT               := &IID{0x68aca3cc, 0x22d0, 0x44e6, {0x85, 0xf8, 0x28, 0x16, 0x71, 0x97, 0xfa, 0x38}}
MF_MT_VIDEO_CHROMA_SITING               := &IID{0x65df2370, 0xc773, 0x4c33, {0xaa, 0x64, 0x84, 0x3e, 0x06, 0x8e, 0xfb, 0x0c}}
MF_MT_INTERLACE_MODE                    := &IID{0xe2724bb8, 0xe676, 0x4806, {0xb4, 0xb2, 0xa8, 0xd6, 0xef, 0xb4, 0x4c, 0xcd}}
MF_MT_TRANSFER_FUNCTION                 := &IID{0x5fb0fce9, 0xbe5c, 0x4935, {0xa8, 0x11, 0xec, 0x83, 0x8f, 0x8e, 0xed, 0x93}}
MF_MT_VIDEO_PRIMARIES                   := &IID{0xdbfbe4d7, 0x0740, 0x4ee0, {0x81, 0x92, 0x85, 0x0a, 0xb0, 0xe2, 0x19, 0x35}}
MF_MT_YUV_MATRIX                        := &IID{0x3e23d450, 0x2c75, 0x4d25, {0xa0, 0x0e, 0xb9, 0x16, 0x70, 0xd1, 0x23, 0x27}}
MF_MT_VIDEO_LIGHTING                    := &IID{0x53a0529c, 0x890b, 0x4216, {0x8b, 0xf9, 0x59, 0x93, 0x67, 0xad, 0x6d, 0x20}}
MF_MT_VIDEO_NOMINAL_RANGE               := &IID{0xc21b8ee5, 0xb956, 0x4071, {0x8d, 0xaf, 0x32, 0x5e, 0xdf, 0x5c, 0xab, 0x11}}
MF_MT_GEOMETRIC_APERTURE                := &IID{0x66758743, 0x7e5f, 0x400d, {0x98, 0x0a, 0xaa, 0x85, 0x96, 0xc8, 0x56, 0x96}}
MF_MT_MINIMUM_DISPLAY_APERTURE          := &IID{0xd7388766, 0x18fe, 0x48c6, {0xa1, 0x77, 0xee, 0x89, 0x48, 0x67, 0xc8, 0xc4}}
MF_MT_PAN_SCAN_APERTURE                 := &IID{0x79614dde, 0x9187, 0x48fb, {0xb8, 0xc7, 0x4d, 0x52, 0x68, 0x9d, 0xe6, 0x49}}
MF_MT_PAN_SCAN_ENABLED                  := &IID{0x4b7f6bc3, 0x8b13, 0x40b2, {0xa9, 0x93, 0xab, 0xf6, 0x30, 0xb8, 0x20, 0x4e}}
MF_MT_AVG_BITRATE                       := &IID{0x20332624, 0xfb0d, 0x4d9e, {0xbd, 0x0d, 0xcb, 0xf6, 0x78, 0x6c, 0x10, 0x2e}}
MF_MT_AVG_BIT_ERROR_RATE                := &IID{0x799cabd6, 0x3508, 0x4db4, {0xa3, 0xc7, 0x56, 0x9c, 0xd5, 0x33, 0xde, 0xb1}}
MF_MT_MAX_KEYFRAME_SPACING              := &IID{0xc16eb52b, 0x73a1, 0x476f, {0x8d, 0x62, 0x83, 0x9d, 0x6a, 0x02, 0x06, 0x52}}
MF_MT_USER_DATA                         := &IID{0xb6bc765f, 0x4c3b, 0x40a4, {0xbd, 0x51, 0x25, 0x35, 0xb6, 0x6f, 0xe0, 0x9d}}
MF_MT_DEFAULT_STRIDE                    := &IID{0x644b4e48, 0x1e02, 0x4516, {0xb0, 0xeb, 0xc0, 0x1c, 0xa9, 0xd4, 0x9a, 0xc6}}
MF_MT_PALETTE                           := &IID{0x6d283f42, 0x9846, 0x4410, {0xaf, 0xd9, 0x65, 0x4d, 0x50, 0x3b, 0x1a, 0x54}}
MF_MT_MPEG_START_TIME_CODE              := &IID{0x91f67885, 0x4333, 0x4280, {0x97, 0xcd, 0xbd, 0x5a, 0x6c, 0x03, 0xa0, 0x6e}}
MF_MT_MPEG2_PROFILE                     := &IID{0xad76a80b, 0x2d5c, 0x4e0b, {0xb3, 0x75, 0x64, 0xe5, 0x20, 0x13, 0x70, 0x36}}
MF_MT_MPEG2_LEVEL                       := &IID{0x96f66574, 0x11c5, 0x4015, {0x86, 0x66, 0xbf, 0xf5, 0x16, 0x43, 0x6d, 0xa7}}
MF_MT_MPEG2_FLAGS                       := &IID{0x31e3991d, 0xf701, 0x4b2f, {0xb4, 0x26, 0x8a, 0xe3, 0xbd, 0xa9, 0xe0, 0x4b}}
MF_MT_MPEG_SEQUENCE_HEADER              := &IID{0x3c036de7, 0x3ad0, 0x4c9e, {0x92, 0x16, 0xee, 0x6d, 0x6a, 0xc2, 0x1c, 0xb3}}
MF_MT_MPEG2_STANDARD                    := &IID{0xa20af9e8, 0x928a, 0x4b26, {0xaa, 0xa9, 0xf0, 0x5c, 0x74, 0xca, 0xc4, 0x7c}}
MF_MT_MPEG2_TIMECODE                    := &IID{0x5229ba10, 0xe29d, 0x4f80, {0xa5, 0x9c, 0xdf, 0x4f, 0x18, 0x2, 0x7, 0xd2}}
MF_MT_MPEG2_CONTENT_PACKET              := &IID{0x825d55e4, 0x4f12, 0x4197, {0x9e, 0xb3, 0x59, 0xb6, 0xe4, 0x71, 0xf, 0x6}}
MF_MT_H264_MAX_CODEC_CONFIG_DELAY       := &IID{0xf5929986, 0x4c45, 0x4fbb, {0xbb, 0x49, 0x6c, 0xc5, 0x34, 0xd0, 0x5b, 0x9b}}
MF_MT_H264_SUPPORTED_SLICE_MODES        := &IID{0xc8be1937, 0x4d64, 0x4549, {0x83, 0x43, 0xa8, 0x8, 0x6c, 0xb, 0xfd, 0xa5}}
MF_MT_H264_SUPPORTED_SYNC_FRAME_TYPES   := &IID{0x89a52c01, 0xf282, 0x48d2, {0xb5, 0x22, 0x22, 0xe6, 0xae, 0x63, 0x31, 0x99}}
MF_MT_H264_RESOLUTION_SCALING           := &IID{0xe3854272, 0xf715, 0x4757, {0xba, 0x90, 0x1b, 0x69, 0x6c, 0x77, 0x34, 0x57}}
MF_MT_H264_SIMULCAST_SUPPORT            := &IID{0x9ea2d63d, 0x53f0, 0x4a34, {0xb9, 0x4e, 0x9d, 0xe4, 0x9a, 0x7, 0x8c, 0xb3}}
MF_MT_H264_SUPPORTED_RATE_CONTROL_MODES := &IID{0x6a8ac47e, 0x519c, 0x4f18, {0x9b, 0xb3, 0x7e, 0xea, 0xae, 0xa5, 0x59, 0x4d}}
MF_MT_H264_MAX_MB_PER_SEC               := &IID{0x45256d30, 0x7215, 0x4576, {0x93, 0x36, 0xb0, 0xf1, 0xbc, 0xd5, 0x9b, 0xb2}}
MF_MT_H264_SUPPORTED_USAGES             := &IID{0x60b1a998, 0xdc01, 0x40ce, {0x97, 0x36, 0xab, 0xa8, 0x45, 0xa2, 0xdb, 0xdc}}
MF_MT_H264_CAPABILITIES                 := &IID{0xbb3bd508, 0x490a, 0x11e0, {0x99, 0xe4, 0x13, 0x16, 0xdf, 0xd7, 0x20, 0x85}}
MF_MT_H264_SVC_CAPABILITIES             := &IID{0xf8993abe, 0xd937, 0x4a8f, {0xbb, 0xca, 0x69, 0x66, 0xfe, 0x9e, 0x11, 0x52}}
MF_MT_H264_USAGE                        := &IID{0x359ce3a5, 0xaf00, 0x49ca, {0xa2, 0xf4, 0x2a, 0xc9, 0x4c, 0xa8, 0x2b, 0x61}}
MF_MT_H264_RATE_CONTROL_MODES           := &IID{0x705177d8, 0x45cb, 0x11e0, {0xac, 0x7d, 0xb9, 0x1c, 0xe0, 0xd7, 0x20, 0x85}}
MF_MT_H264_LAYOUT_PER_STREAM            := &IID{0x85e299b2, 0x90e3, 0x4fe8, {0xb2, 0xf5, 0xc0, 0x67, 0xe0, 0xbf, 0xe5, 0x7a}}
MF_MT_DV_AAUX_SRC_PACK_0                := &IID{0x84bd5d88, 0x0fb8, 0x4ac8, {0xbe, 0x4b, 0xa8, 0x84, 0x8b, 0xef, 0x98, 0xf3}}
MF_MT_DV_AAUX_CTRL_PACK_0               := &IID{0xf731004e, 0x1dd1, 0x4515, {0xaa, 0xbe, 0xf0, 0xc0, 0x6a, 0xa5, 0x36, 0xac}}
MF_MT_DV_AAUX_SRC_PACK_1                := &IID{0x720e6544, 0x0225, 0x4003, {0xa6, 0x51, 0x01, 0x96, 0x56, 0x3a, 0x95, 0x8e}}
MF_MT_DV_AAUX_CTRL_PACK_1               := &IID{0xcd1f470d, 0x1f04, 0x4fe0, {0xbf, 0xb9, 0xd0, 0x7a, 0xe0, 0x38, 0x6a, 0xd8}}
MF_MT_DV_VAUX_SRC_PACK                  := &IID{0x41402d9d, 0x7b57, 0x43c6, {0xb1, 0x29, 0x2c, 0xb9, 0x97, 0xf1, 0x50, 0x09}}
MF_MT_DV_VAUX_CTRL_PACK                 := &IID{0x2f84e1c4, 0x0da1, 0x4788, {0x93, 0x8e, 0x0d, 0xfb, 0xfb, 0xb3, 0x4b, 0x48}}

MFMediaType_Default                     := IID{0x81A412E6, 0x8103, 0x4B06, {0x85, 0x7F, 0x18, 0x62, 0x78, 0x10, 0x24, 0xAC}}
MFMediaType_Audio                       := IID{0x73647561, 0x0000, 0x0010, {0x80, 0x00, 0x00, 0xAA, 0x00, 0x38, 0x9B, 0x71}}
MFMediaType_Video                       := IID{0x73646976, 0x0000, 0x0010, {0x80, 0x00, 0x00, 0xAA, 0x00, 0x38, 0x9B, 0x71}}
MFMediaType_Protected                   := IID{0x7b4b6fe6, 0x9d04, 0x4494, {0xbe, 0x14, 0x7e, 0x0b, 0xd0, 0x76, 0xc8, 0xe4}}
MFMediaType_SAMI                        := IID{0xe69669a0, 0x3dcd, 0x40cb, {0x9e, 0x2e, 0x37, 0x08, 0x38, 0x7c, 0x06, 0x16}}
MFMediaType_Script                      := IID{0x72178C22, 0xE45B, 0x11D5, {0xBC, 0x2A, 0x00, 0xB0, 0xD0, 0xF3, 0xF4, 0xAB}}
MFMediaType_Image                       := IID{0x72178C23, 0xE45B, 0x11D5, {0xBC, 0x2A, 0x00, 0xB0, 0xD0, 0xF3, 0xF4, 0xAB}}
MFMediaType_HTML                        := IID{0x72178C24, 0xE45B, 0x11D5, {0xBC, 0x2A, 0x00, 0xB0, 0xD0, 0xF3, 0xF4, 0xAB}}
MFMediaType_Binary                      := IID{0x72178C25, 0xE45B, 0x11D5, {0xBC, 0x2A, 0x00, 0xB0, 0xD0, 0xF3, 0xF4, 0xAB}}
MFMediaType_FileTransfer                := IID{0x72178C26, 0xE45B, 0x11D5, {0xBC, 0x2A, 0x00, 0xB0, 0xD0, 0xF3, 0xF4, 0xAB}}
MFMediaType_Stream                      := IID{0xe436eb83, 0x524f, 0x11ce, {0x9f, 0x53, 0x00, 0x20, 0xaf, 0x0b, 0xa7, 0x70}}
MFMediaType_MultiplexedFrames           := IID{0x6ea542b0, 0x281f, 0x4231, {0xa4, 0x64, 0xfe, 0x2f, 0x50, 0x22, 0x50, 0x1c}}
MFMediaType_Subtitle                    := IID{0xa6d13581, 0xed50, 0x4e65, {0xae, 0x08, 0x26, 0x06, 0x55, 0x76, 0xaa, 0xcc}}

MFImageFormat_JPEG                      := &IID{0x19e4a5aa, 0x5662, 0x4fc5, {0xa0, 0xc0, 0x17, 0x58, 0x02, 0x8e, 0x10, 0x57}}
MFImageFormat_RGB32                     := &IID{0x00000016, 0x0000, 0x0010, {0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71}}
MFStreamFormat_MPEG2Transport           := &IID{0xe06d8023, 0xdb46, 0x11cf, {0xb4, 0xd1, 0x00, 0x80, 0x5f, 0x6c, 0xbb, 0xea}}
MFStreamFormat_MPEG2Program             := &IID{0x263067d1, 0xd330, 0x45dc, {0xb6, 0x69, 0x34, 0xd9, 0x86, 0xe4, 0xe3, 0xe1}}

MFPKEY_CATEGORY :=                                &IID{0xc57a84c0,0x1a80,0x40a3,{0x97,0xb5,0x92,0x72,0xa4,0x3,0xc8,0xae}}
MFPKEY_EXATTRIBUTE_SUPPORTED :=                   &IID{0x456fe843,0x3c87,0x40c0,{0x94,0x9d,0x14,0x9,0xc9,0x7d,0xab,0x2c}}
MFPKEY_MULTICHANNEL_CHANNEL_MASK :=               &IID{0x58bdaf8c,0x3224,0x4692,{0x86,0xd0,0x44,0xd6,0x5c,0x5b,0xf8,0x2b}}
MF_SA_D3D_AWARE :=                                &IID{0xeaa35c29,0x775e,0x488e,{0x9b,0x61,0xb3,0x28,0x3e,0x49,0x58,0x3b}}
MF_SA_REQUIRED_SAMPLE_COUNT :=                    &IID{0x18802c61,0x324b,0x4952,{0xab,0xd0,0x17,0x6f,0xf5,0xc6,0x96,0xff}}
MF_TRANSFORM_ASYNC :=                             &IID{0xf81a699a,0x649a,0x497d,{0x8c,0x73,0x29,0xf8,0xfe,0xd6,0xad,0x7a}}
MF_TRANSFORM_ASYNC_UNLOCK :=                      &IID{0xe5666d6b,0x3422,0x4eb6,{0xa4,0x21,0xda,0x7d,0xb1,0xf8,0xe2,0x7}}
MF_TRANSFORM_FLAGS_Attribute :=                   &IID{0x9359bb7e,0x6275,0x46c4,{0xa0,0x25,0x1c,0x1,0xe4,0x5f,0x1a,0x86}}
MF_TRANSFORM_CATEGORY_Attribute :=                &IID{0xceabba49,0x506d,0x4757,{0xa6,0xff,0x66,0xc1,0x84,0x98,0x7e,0x4e}}
MFT_TRANSFORM_CLSID_Attribute :=                  &IID{0x6821c42b,0x65a4,0x4e82,{0x99,0xbc,0x9a,0x88,0x20,0x5e,0xcd,0xc}}
MFT_INPUT_TYPES_Attributes :=                     &IID{0x4276c9b1,0x759d,0x4bf3,{0x9c,0xd0,0xd,0x72,0x3d,0x13,0x8f,0x96}}
MFT_OUTPUT_TYPES_Attributes :=                    &IID{0x8eae8cf3,0xa44f,0x4306,{0xba,0x5c,0xbf,0x5d,0xda,0x24,0x28,0x18}}
MFT_ENUM_HARDWARE_URL_Attribute :=                &IID{0x2fb866ac,0xb078,0x4942,{0xab,0x6c,0x0,0x3d,0x5,0xcd,0xa6,0x74}}
MFT_FRIENDLY_NAME_Attribute :=                    &IID{0x314ffbae,0x5b41,0x4c95,{0x9c,0x19,0x4e,0x7d,0x58,0x6f,0xac,0xe3}}
MFT_CONNECTED_STREAM_ATTRIBUTE :=                 &IID{0x71eeb820,0xa59f,0x4de2,{0xbc,0xec,0x38,0xdb,0x1d,0xd6,0x11,0xa4}}
MFT_CONNECTED_TO_HW_STREAM :=                     &IID{0x34e6e728,0x6d6,0x4491,{0xa5,0x53,0x47,0x95,0x65,0xd,0xb9,0x12}}
MFT_PREFERRED_OUTPUTTYPE_Attribute :=             &IID{0x7e700499,0x396a,0x49ee,{0xb1,0xb4,0xf6,0x28,0x2,0x1e,0x8c,0x9d}}
MFT_PROCESS_LOCAL_Attribute :=                    &IID{0x543186e4,0x4649,0x4e65,{0xb5,0x88,0x4a,0xa3,0x52,0xaf,0xf3,0x79}}
MFT_PREFERRED_ENCODER_PROFILE :=                  &IID{0x53004909,0x1ef5,0x46d7,{0xa1,0x8e,0x5a,0x75,0xf8,0xb5,0x90,0x5f}}
MFT_HW_TIMESTAMP_WITH_QPC_Attribute :=            &IID{0x8d030fb8,0xcc43,0x4258,{0xa2,0x2e,0x92,0x10,0xbe,0xf8,0x9b,0xe4}}
MFT_FIELDOFUSE_UNLOCK_Attribute :=                &IID{0x8ec2e9fd,0x9148,0x410d,{0x83,0x1e,0x70,0x24,0x39,0x46,0x1a,0x8e}}
MFT_CODEC_MERIT_Attribute :=                      &IID{0x88a7cb15,0x7b07,0x4a34,{0x91,0x28,0xe6,0x4c,0x67,0x3,0xc4,0xd3}}
MFT_ENUM_TRANSCODE_ONLY_ATTRIBUTE :=              &IID{0x111ea8cd,0xb62a,0x4bdb,{0x89,0xf6,0x67,0xff,0xcd,0xc2,0x45,0x8b}}
MF_SA_REQUIRED_SAMPLE_COUNT_PROGRESSIVE :=        &IID{0xb172d58e,0xfa77,0x4e48,{0x8d,0x2a,0x1d,0xf2,0xd8,0x50,0xea,0xc2}}
MF_SA_MINIMUM_OUTPUT_SAMPLE_COUNT :=              &IID{0x851745d5,0xc3d6,0x476d,{0x95,0x27,0x49,0x8e,0xf2,0xd1,0xd,0x18}}
MF_SA_MINIMUM_OUTPUT_SAMPLE_COUNT_PROGRESSIVE :=  &IID{0xf5523a5,0x1cb2,0x47c5,{0xa5,0x50,0x2e,0xeb,0x84,0xb4,0xd1,0x4a}}
MF_SA_D3D11_BINDFLAGS :=                          &IID{0xeacf97ad,0x065c,0x4408,{0xbe,0xe3,0xfd,0xcb,0xfd,0x12,0x8b,0xe2}}
MF_SA_D3D11_USAGE :=                              &IID{0xe85fe442,0x2ca3,0x486e,{0xa9,0xc7,0x10,0x9d,0xda,0x60,0x98,0x80}}
MF_SA_D3D11_AWARE :=                              &IID{0x206b4fc8,0xfcf9,0x4c51,{0xaf,0xe3,0x97,0x64,0x36,0x9e,0x33,0xa0}}
MF_SA_D3D11_SHARED :=                             &IID{0x7b8f32c3,0x6d96,0x4b89,{0x92,0x3,0xdd,0x38,0xb6,0x14,0x14,0xf3 }}
MF_SA_D3D11_SHARED_WITHOUT_MUTEX :=               &IID{0x39dbd44d,0x2e44,0x4931,{0xa4,0xc8,0x35,0x2d,0x3d,0xc4,0x21,0x15}}
MF_SA_D3D11_ALLOW_DYNAMIC_YUV_TEXTURE :=          &IID{0xce06d49f,0x613,0x4b9d,{0x86,0xa6,0xd8,0xc4,0xf9,0xc1,0x0,0x75}}
MF_SA_D3D11_HW_PROTECTED :=                       &IID{0x3a8ba9d9,0x92ca,0x4307,{0xa3,0x91,0x69,0x99,0xdb,0xf3,0xb6,0xce}}

MF_LOW_LATENCY                := &IID{0x9c27891a, 0xed7a, 0x40e1, {0x88, 0xe8, 0xb2, 0x27, 0x27, 0xa0, 0x24, 0xee}}

MF_PD_PMPHOST_CONTEXT         := &IID{0x6c990d31, 0xbb8e, 0x477a, {0x85, 0x98, 0xd, 0x5d, 0x96, 0xfc, 0xd8, 0x8a}}
MF_PD_APP_CONTEXT             := &IID{0x6c990d32, 0xbb8e, 0x477a, {0x85, 0x98, 0xd, 0x5d, 0x96, 0xfc, 0xd8, 0x8a}}
MF_PD_DURATION                := &IID{0x6c990d33, 0xbb8e, 0x477a, {0x85, 0x98, 0xd, 0x5d, 0x96, 0xfc, 0xd8, 0x8a}}
MF_PD_TOTAL_FILE_SIZE         := &IID{0x6c990d34, 0xbb8e, 0x477a, {0x85, 0x98, 0xd, 0x5d, 0x96, 0xfc, 0xd8, 0x8a}}
MF_PD_AUDIO_ENCODING_BITRATE  := &IID{0x6c990d35, 0xbb8e, 0x477a, {0x85, 0x98, 0xd, 0x5d, 0x96, 0xfc, 0xd8, 0x8a}}
MF_PD_VIDEO_ENCODING_BITRATE  := &IID{0x6c990d36, 0xbb8e, 0x477a, {0x85, 0x98, 0xd, 0x5d, 0x96, 0xfc, 0xd8, 0x8a}}
MF_PD_MIME_TYPE               := &IID{0x6c990d37, 0xbb8e, 0x477a, {0x85, 0x98, 0xd, 0x5d, 0x96, 0xfc, 0xd8, 0x8a}}
MF_PD_LAST_MODIFIED_TIME      := &IID{0x6c990d38, 0xbb8e, 0x477a, {0x85, 0x98, 0xd, 0x5d, 0x96, 0xfc, 0xd8, 0x8a}}

MF_MT_VIDEO_PROFILE           := &IID{0xad76a80b, 0x2d5c, 0x4e0b, {0xb3, 0x75, 0x64, 0xe5, 0x20, 0x13, 0x70, 0x36}}


MFT_INPUT_STREAM_INFO :: struct {
  hnsMaxLatency: LONGLONG,
  dwFlags: DWORD,
  cbSize: DWORD,
  cbMaxLookahead: DWORD,
  cbAlignment: DWORD,
}

MFT_REGISTER_TYPE_INFO :: struct {
  guidMajorType:  GUID,
  guidSubtype:    GUID,
}

MFT_OUTPUT_DATA_BUFFER :: struct {
  dwStreamID: DWORD,
  pSample:    ^IMFSample,
  dwStatus:   DWORD,
  pEvents:    ^IMFCollection,
}

MF_ATTRIBUTES_MATCH_TYPE :: enum {
  MF_ATTRIBUTES_MATCH_OUR_ITEMS = 0,
  MF_ATTRIBUTES_MATCH_THEIR_ITEMS = 1,
  MF_ATTRIBUTES_MATCH_ALL_ITEMS = 2,
  MF_ATTRIBUTES_MATCH_INTERSECTION = 3,
  MF_ATTRIBUTES_MATCH_SMALLER = 4,
}

MF_ATTRIBUTE_TYPE :: enum {
  MF_ATTRIBUTE_UINT32 = VT_UI4,
  MF_ATTRIBUTE_UINT64 = VT_UI8,
  MF_ATTRIBUTE_DOUBLE = VT_R8,
  MF_ATTRIBUTE_GUID = VT_CLSID,
  MF_ATTRIBUTE_STRING = VT_LPWSTR,
  MF_ATTRIBUTE_BLOB,
  MF_ATTRIBUTE_IUNKNOWN = VT_UNKNOWN
}

VT_EMPTY            :: 0
VT_NULL             :: 1
VT_I2               :: 2
VT_I4               :: 3
VT_R4               :: 4
VT_R8               :: 5
VT_CY               :: 6
VT_DATE             :: 7
VT_BSTR             :: 8
VT_DISPATCH         :: 9
VT_ERROR            :: 10
VT_BOOL             :: 11
VT_VARIANT          :: 12
VT_UNKNOWN          :: 13
VT_DECIMAL          :: 14
VT_I1               :: 16
VT_UI1              :: 17
VT_UI2              :: 18
VT_UI4              :: 19
VT_I8               :: 20
VT_UI8              :: 21
VT_INT              :: 22
VT_UINT             :: 23
VT_VOID             :: 24
VT_HRESULT          :: 25
VT_PTR              :: 26
VT_SAFEARRAY        :: 27
VT_CARRAY           :: 28
VT_USERDEFINED      :: 29
VT_LPSTR            :: 30
VT_LPWSTR           :: 31
VT_RECORD           :: 36
VT_INT_PTR          :: 37
VT_UINT_PTR         :: 38
VT_FILETIME         :: 64
VT_BLOB             :: 65
VT_STREAM           :: 66
VT_STORAGE          :: 67
VT_STREAMED_OBJECT  :: 68
VT_STORED_OBJECT    :: 69
VT_BLOB_OBJECT      :: 70
VT_CF               :: 71
VT_CLSID            :: 72
VT_VERSIONED_STREAM :: 73
VT_BSTR_BLOB        :: 0xfff
VT_VECTOR           :: 0x1000
VT_ARRAY            :: 0x2000
VT_BYREF            :: 0x4000
VT_RESERVED         :: 0x8000
VT_ILLEGAL          :: 0xffff
VT_ILLEGALMASKED    :: 0xfff
VT_TYPEMASK         :: 0xff

MediaEventType :: enum DWORD {
  MEUnknown	= 0,
  MEError	= 1,
  MEExtendedType	= 2,
  MENonFatalError	= 3,
  MEGenericV1Anchor	= MENonFatalError,
  MESessionUnknown	= 100,
  MESessionTopologySet	= 101,
  MESessionTopologiesCleared	= 102,
  MESessionStarted	= 103,
  MESessionPaused	= 104,
  MESessionStopped	= 105,
  MESessionClosed	= 106,
  MESessionEnded	= 107,
  MESessionRateChanged	= 108,
  MESessionScrubSampleComplete	= 109,
  MESessionCapabilitiesChanged	= 110,
  MESessionTopologyStatus	= 111,
  MESessionNotifyPresentationTime	= 112,
  MENewPresentation	= 113,
  MELicenseAcquisitionStart	= 114,
  MELicenseAcquisitionCompleted	= 115,
  MEIndividualizationStart	= 116,
  MEIndividualizationCompleted	= 117,
  MEEnablerProgress	= 118,
  MEEnablerCompleted	= 119,
  MEPolicyError	= 120,
  MEPolicyReport	= 121,
  MEBufferingStarted	= 122,
  MEBufferingStopped	= 123,
  MEConnectStart	= 124,
  MEConnectEnd	= 125,
  MEReconnectStart	= 126,
  MEReconnectEnd	= 127,
  MERendererEvent	= 128,
  MESessionStreamSinkFormatChanged	= 129,
  MESessionV1Anchor	= MESessionStreamSinkFormatChanged,
  MESourceUnknown	= 200,
  MESourceStarted	= 201,
  MEStreamStarted	= 202,
  MESourceSeeked	= 203,
  MEStreamSeeked	= 204,
  MENewStream	= 205,
  MEUpdatedStream	= 206,
  MESourceStopped	= 207,
  MEStreamStopped	= 208,
  MESourcePaused	= 209,
  MEStreamPaused	= 210,
  MEEndOfPresentation	= 211,
  MEEndOfStream	= 212,
  MEMediaSample	= 213,
  MEStreamTick	= 214,
  MEStreamThinMode	= 215,
  MEStreamFormatChanged	= 216,
  MESourceRateChanged	= 217,
  MEEndOfPresentationSegment	= 218,
  MESourceCharacteristicsChanged	= 219,
  MESourceRateChangeRequested	= 220,
  MESourceMetadataChanged	= 221,
  MESequencerSourceTopologyUpdated	= 222,
  MESourceV1Anchor	= MESequencerSourceTopologyUpdated,
  MESinkUnknown	= 300,
  MEStreamSinkStarted	= 301,
  MEStreamSinkStopped	= 302,
  MEStreamSinkPaused	= 303,
  MEStreamSinkRateChanged	= 304,
  MEStreamSinkRequestSample	= 305,
  MEStreamSinkMarker	= 306,
  MEStreamSinkPrerolled	= 307,
  MEStreamSinkScrubSampleComplete	= 308,
  MEStreamSinkFormatChanged	= 309,
  MEStreamSinkDeviceChanged	= 310,
  MEQualityNotify	= 311,
  MESinkInvalidated	= 312,
  MEAudioSessionNameChanged	= 313,
  MEAudioSessionVolumeChanged	= 314,
  MEAudioSessionDeviceRemoved	= 315,
  MEAudioSessionServerShutdown	= 316,
  MEAudioSessionGroupingParamChanged	= 317,
  MEAudioSessionIconChanged	= 318,
  MEAudioSessionFormatChanged	= 319,
  MEAudioSessionDisconnected	= 320,
  MEAudioSessionExclusiveModeOverride	= 321,
  MESinkV1Anchor	= MEAudioSessionExclusiveModeOverride,
  MECaptureAudioSessionVolumeChanged	= 322,
  MECaptureAudioSessionDeviceRemoved	= 323,
  MECaptureAudioSessionFormatChanged	= 324,
  MECaptureAudioSessionDisconnected	= 325,
  MECaptureAudioSessionExclusiveModeOverride	= 326,
  MECaptureAudioSessionServerShutdown	= 327,
  MESinkV2Anchor	= MECaptureAudioSessionServerShutdown,
  METrustUnknown	= 400,
  MEPolicyChanged	= 401,
  MEContentProtectionMessage	= 402,
  MEPolicySet	= 403,
  METrustV1Anchor	= MEPolicySet,
  MEWMDRMLicenseBackupCompleted	= 500,
  MEWMDRMLicenseBackupProgress	= 501,
  MEWMDRMLicenseRestoreCompleted	= 502,
  MEWMDRMLicenseRestoreProgress	= 503,
  MEWMDRMLicenseAcquisitionCompleted	= 506,
  MEWMDRMIndividualizationCompleted	= 508,
  MEWMDRMIndividualizationProgress	= 513,
  MEWMDRMProximityCompleted	= 514,
  MEWMDRMLicenseStoreCleaned	= 515,
  MEWMDRMRevocationDownloadCompleted	= 516,
  MEWMDRMV1Anchor	= MEWMDRMRevocationDownloadCompleted,
  METransformUnknown	= 600,
  METransformNeedInput	= ( METransformUnknown + 1 ) ,
  METransformHaveOutput	= ( METransformNeedInput + 1 ) ,
  METransformDrainComplete	= ( METransformHaveOutput + 1 ) ,
  METransformMarker	= ( METransformDrainComplete + 1 ) ,
  METransformInputStreamStateChanged	= ( METransformMarker + 1 ) ,
  MEByteStreamCharacteristicsChanged	= 700,
  MEVideoCaptureDeviceRemoved	= 800,
  MEVideoCaptureDevicePreempted	= 801,
  MEStreamSinkFormatInvalidated	= 802,
  MEEncodingParameters	= 803,
  MEContentProtectionMetadata	= 900,
  MEDeviceThermalStateChanged	= 950,
  MEReservedMax	= 10000
}

MFT_MESSAGE_TYPE :: enum {
  MFT_MESSAGE_COMMAND_FLUSH = 0,
  MFT_MESSAGE_COMMAND_DRAIN = 0x1,
  MFT_MESSAGE_SET_D3D_MANAGER = 0x2,
  MFT_MESSAGE_DROP_SAMPLES = 0x3,
  MFT_MESSAGE_COMMAND_TICK = 0x4,
  MFT_MESSAGE_NOTIFY_BEGIN_STREAMING = 0x10000000,
  MFT_MESSAGE_NOTIFY_END_STREAMING = 0x10000001,
  MFT_MESSAGE_NOTIFY_END_OF_STREAM = 0x10000002,
  MFT_MESSAGE_NOTIFY_START_OF_STREAM = 0x10000003,
  MFT_MESSAGE_NOTIFY_RELEASE_RESOURCES = 0x10000004,
  MFT_MESSAGE_NOTIFY_REACQUIRE_RESOURCES = 0x10000005,
  MFT_MESSAGE_NOTIFY_EVENT = 0x10000006,
  MFT_MESSAGE_COMMAND_SET_OUTPUT_STREAM_STATE = 0x10000007,
  MFT_MESSAGE_COMMAND_FLUSH_OUTPUT_STREAM = 0x10000008,
  MFT_MESSAGE_COMMAND_MARKER = 0x20000000
}

MF_SOURCE_READER_ALL_STREAMS          :: 0xfffffffe
MF_SOURCE_READER_ANY_STREAM           :: 0xfffffffe
MF_SOURCE_READER_FIRST_AUDIO_STREAM   :: 0xfffffffd
MF_SOURCE_READER_FIRST_VIDEO_STREAM   :: 0xfffffffc
MF_SOURCE_READER_MEDIASOURCE          :: 0xffffffff
MF_SOURCE_READER_CURRENT_TYPE_INDEX   :: 0xfffffff

MF_SOURCE_READERF_ERROR                   :: 0x1
MF_SOURCE_READERF_ENDOFSTREAM             :: 0x2
MF_SOURCE_READERF_NEWSTREAM               :: 0x4
MF_SOURCE_READERF_NATIVEMEDIATYPECHANGED  :: 0x10
MF_SOURCE_READERF_CURRENTMEDIATYPECHANGED :: 0x20
MF_SOURCE_READERF_STREAMTICK              :: 0x100
MF_SOURCE_READERF_ALLEFFECTSREMOVED       :: 0x20

MFT_INPUT_STATUS_ACCEPT_DATA :: 0x1

MFT_INPUT_DATA_BUFFER_PLACEHOLDER :: 0xffffffff
MFT_OUTPUT_STREAM_WHOLE_SAMPLES :: 0x1
MFT_OUTPUT_STREAM_SINGLE_SAMPLE_PER_BUFFER :: 0x2
MFT_OUTPUT_STREAM_FIXED_SAMPLE_SIZE :: 0x4
MFT_OUTPUT_STREAM_DISCARDABLE :: 0x8
MFT_OUTPUT_STREAM_OPTIONAL :: 0x10
MFT_OUTPUT_STREAM_PROVIDES_SAMPLES :: 0x100
MFT_OUTPUT_STREAM_CAN_PROVIDE_SAMPLES :: 0x200
MFT_OUTPUT_STREAM_LAZY_READ :: 0x400
MFT_OUTPUT_STREAM_REMOVABLE :: 0x800
MFT_OUTPUT_STATUS_SAMPLE_READY :: 0x1
MFT_OUTPUT_DATA_BUFFER_INCOMPLETE :: 0x1000000
MFT_OUTPUT_DATA_BUFFER_FORMAT_CHANGE :: 0x100
MFT_OUTPUT_DATA_BUFFER_STREAM_END :: 0x200
MFT_OUTPUT_DATA_BUFFER_NO_SAMPLE :: 0x300
MFT_INPUT_STREAM_WHOLE_SAMPLES :: 0x1
MFT_INPUT_STREAM_SINGLE_SAMPLE_PER_BUFFER :: 0x2
MFT_INPUT_STREAM_FIXED_SAMPLE_SIZE :: 0x4
MFT_INPUT_STREAM_HOLDS_BUFFERS :: 0x8
MFT_INPUT_STREAM_DOES_NOT_ADDREF :: 0x100
MFT_INPUT_STREAM_REMOVABLE :: 0x200
MFT_INPUT_STREAM_OPTIONAL :: 0x400
MFT_INPUT_STREAM_PROCESSES_IN_PLACE :: 0x800
MFT_SET_TYPE_TEST_ONLY :: 0x1
MFT_PROCESS_OUTPUT_STATUS_NEW_STREAMS :: 0x100
MFT_PROCESS_OUTPUT_DISCARD_WHEN_NO_BUFFER :: 0x1
MFT_PROCESS_OUTPUT_REGENERATE_LAST_OUTPUT :: 0x2

eAVEncH264VProfile_unknown :: 0
eAVEncH264VProfile_Simple :: 66
eAVEncH264VProfile_Base :: 66
eAVEncH264VProfile_Main :: 77
eAVEncH264VProfile_High :: 100
eAVEncH264VProfile_422 :: 122
eAVEncH264VProfile_High10 :: 110
eAVEncH264VProfile_444 :: 244
eAVEncH264VProfile_Extended :: 88
eAVEncH264VProfile_ScalableBase :: 83
eAVEncH264VProfile_ScalableHigh :: 86
eAVEncH264VProfile_MultiviewHigh :: 118
eAVEncH264VProfile_StereoHigh :: 128
eAVEncH264VProfile_ConstrainedBase :: 256
eAVEncH264VProfile_UCConstrainedHigh :: 257
eAVEncH264VProfile_UCScalableConstrainedBase :: 258
eAVEncH264VProfile_UCScalableConstrainedHigh :: 259

eAVEncH265VProfile_unknown           :: 0
eAVEncH265VProfile_Main_420_8        :: 1
eAVEncH265VProfile_Main_420_10       :: 2
eAVEncH265VProfile_Main_420_12       :: 3
eAVEncH265VProfile_Main_422_10       :: 4
eAVEncH265VProfile_Main_422_12       :: 5
eAVEncH265VProfile_Main_444_8        :: 6
eAVEncH265VProfile_Main_444_10       :: 7
eAVEncH265VProfile_Main_444_12       :: 8
eAVEncH265VProfile_Monochrome_12     :: 9
eAVEncH265VProfile_Monochrome_16     :: 10
eAVEncH265VProfile_MainIntra_420_8   :: 11
eAVEncH265VProfile_MainIntra_420_10  :: 12
eAVEncH265VProfile_MainIntra_420_12  :: 13
eAVEncH265VProfile_MainIntra_422_10  :: 14
eAVEncH265VProfile_MainIntra_422_12  :: 15
eAVEncH265VProfile_MainIntra_444_8   :: 16
eAVEncH265VProfile_MainIntra_444_10  :: 17
eAVEncH265VProfile_MainIntra_444_12  :: 18
eAVEncH265VProfile_MainIntra_444_16  :: 19
eAVEncH265VProfile_MainStill_420_8   :: 20
eAVEncH265VProfile_MainStill_444_8   :: 21
eAVEncH265VProfile_MainStill_444_16  :: 22

eAVEncVP9VProfile_unknown            :: 0
eAVEncVP9VProfile_420_8              :: 1
eAVEncVP9VProfile_420_10             :: 2
eAVEncVP9VProfile_420_12             :: 3

CLSCTX :: enum u32 {
  CLSCTX_INPROC_SERVER =                 0x1,
  CLSCTX_INPROC_HANDLER =                0x2,
  CLSCTX_LOCAL_SERVER =                  0x4,
  CLSCTX_INPROC_SERVER16 =               0x8,
  CLSCTX_REMOTE_SERVER =                 0x10,
  CLSCTX_INPROC_HANDLER16 =              0x20,
  CLSCTX_RESERVED1 =                     0x40,
  CLSCTX_RESERVED2 =                     0x80,
  CLSCTX_RESERVED3 =                     0x100,
  CLSCTX_RESERVED4 =                     0x200,
  CLSCTX_NO_CODE_DOWNLOAD =              0x400,
  CLSCTX_RESERVED5 =                     0x800,
  CLSCTX_NO_CUSTOM_MARSHAL =             0x1000,
  CLSCTX_ENABLE_CODE_DOWNLOAD =          0x2000,
  CLSCTX_NO_FAILURE_LOG =                0x4000,
  CLSCTX_DISABLE_AAA =                   0x8000,
  CLSCTX_ENABLE_AAA =                    0x10000,
  CLSCTX_FROM_DEFAULT_CONTEXT =          0x20000,
  CLSCTX_ACTIVATE_X86_SERVER =           0x40000,
  CLSCTX_ACTIVATE_32_BIT_SERVER,
  CLSCTX_ACTIVATE_64_BIT_SERVER =        0x80000,
  CLSCTX_ENABLE_CLOAKING =               0x100000,
  CLSCTX_APPCONTAINER =                  0x400000,
  CLSCTX_ACTIVATE_AAA_AS_IU =            0x800000,
  CLSCTX_RESERVED6 =                     0x1000000,
  CLSCTX_ACTIVATE_ARM32_SERVER =         0x2000000,
  CLSCTX_ALLOW_LOWER_TRUST_REGISTRATION,
  CLSCTX_PS_DLL =                        0x80000000
}