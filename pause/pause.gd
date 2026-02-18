extends Control

@onready var resume_btn: Button = $PanelContainer/VBoxContainer/Resume

@onready var restart_btn: Button = $PanelContainer/VBoxContainer/Restart

@onready var quit_btn: Button = $PanelContainer/VBoxContainer/Quit
func _ready():
	#$AnimationPlayer.play("RESET")
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	resume_btn.pressed.connect(_on_resume_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
func resume():
	get_tree().paused = false
	#$AnimationPlayer.play_backwards("blur")
	hide()
	
func pause():
	get_tree().paused = true
	#$AnimationPlayer.play("blur")
	show()
	
func testEsc():
	if Input.is_action_just_pressed("Esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("Esc") and get_tree().paused == true:
		resume()


func _on_resume_pressed() -> void:
	resume()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()

func _process(delta):
	testEsc()
