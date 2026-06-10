extends Camera3D

var curr_spot = 0 # current spot; in this case, left (0) or right (1)
var positions = [Vector3(-8,9,12),Vector3(8,9,12)] # for each spot, a position
var rotations = [Vector3(-0.5,-0.5,0),Vector3(-0.5,0.5,0)] # for each spot, an angle

func switch_spot():
	var tween = create_tween()
	
	if curr_spot == 1:
		curr_spot = 0
	else:
		curr_spot += 1
	
	var duration = 2
	
	tween.set_parallel()
	tween.tween_property(self, "global_position", positions[curr_spot], duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_rotation", rotations[curr_spot], duration) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)

func _input(event : InputEvent):
	if event.is_action_pressed("move_cam"):
		switch_spot()
