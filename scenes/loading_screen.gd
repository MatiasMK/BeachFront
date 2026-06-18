extends Control

var level_path : String
signal level_loaded

func set_level(path):
	level_path = path

func _process(_delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(level_path)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass
		ResourceLoader.THREAD_LOAD_LOADED:
			level_loaded.emit()
