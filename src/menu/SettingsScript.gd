extends Control


var vsyncOptions = [DisplayServer.VSYNC_DISABLED, DisplayServer.VSYNC_ADAPTIVE, DisplayServer.VSYNC_ENABLED, DisplayServer.VSYNC_MAILBOX]
var msaaOptions = [Viewport.MSAA_DISABLED, Viewport.MSAA_2X, Viewport.MSAA_4X, Viewport.MSAA_8X]


func vsnyc(index):
	DisplayServer.window_set_vsync_mode(vsyncOptions[index])


func antiAliasing(index):
	get_viewport().msaa_3d = msaaOptions[index]


func fps(index):
	pass
