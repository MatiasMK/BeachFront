extends Node3D

func _ready():
	take_screenshot()
	

func take_screenshot():
	# Wait for the rendering server to finish the frame before capturing
	await RenderingServer.frame_post_draw

	# Get the viewport image texture and convert it to an Image
	var image = get_viewport().get_texture().get_image()
	
	# Create a unique timestamp string for the filename
	var datetime = Time.get_datetime_string_from_system().replace(":", "-")
	var file_path = "res://screenshot_" + datetime + ".png"
	
	# Save the image
	image.save_png(file_path)
	print("Screenshot saved to: ", file_path)
