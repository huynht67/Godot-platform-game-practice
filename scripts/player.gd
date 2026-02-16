
extends CharacterBody2D
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking: bool = false
var health: int = 3
var is_blue_form: bool = false
var bullet_scene = preload("uid://dtclgpudk4ih3")

enum Form { BASE, BLUE, GREEN, PURPLE }
var current_form: Form = Form.BASE

@export var melee_front_x := 60.0
@export var base_front_x := 60.0
@export var green_front_x := 35.0
@export var hitbox_y := -5.0
@export var purple_y_offset := -10.0

@export var melee_offset_x := 50.0
var rect_long := RectangleShape2D.new()
var rect_short := RectangleShape2D.new()
var circle := CircleShape2D.new()

@export var sword_sfx: AudioStream
@export var axe_sfx: AudioStream
@export var scythe_sfx: AudioStream


@onready var visuals: Node2D = $Visuals
@onready var animated_sprite: AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var hitbox: Area2D = $Visuals/Hitbox
@onready var hitbox_shape: CollisionShape2D = $Visuals/Hitbox/CollisionShape2D

@onready var melee_attack_sfx: AudioStreamPlayer2D = $MeleeAttackSfx
@onready var gun_attack_sfx: AudioStreamPlayer2D = $GunAttackSfx
@onready var form_sfx: AudioStreamPlayer2D = $FormChangeSfx

@onready var death_sfx: AudioStreamPlayer2D = $DeathSfx




func form_suffix() -> String:
	match current_form:
		Form.BASE: return ""
		Form.BLUE: return "_2"
		Form.GREEN: return "_3"
		Form.PURPLE: return "_4"
	return ""

func anim(name: String) -> String:
	return name + form_suffix()



func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox_shape.disabled = true
	add_to_group("player")
	
	rect_long = RectangleShape2D.new()
	rect_short = RectangleShape2D.new()
	circle = CircleShape2D.new()
	
	rect_long.size = Vector2(80, 40)   # base form size
	rect_short.size = Vector2(45, 140)  # green form size
	circle.radius = 80                 # purple circular AOE

	apply_form_visuals()
	#if animated_sprite == null:
	#	push_error("AnimatedSprite2D NOT FOUND! Check scene tree.")
	#animated_sprite.animation_finished.connect(_on_animation_finished)
	#hitbox.monitoring = false
	#add_to_group("player")
	
func cycle_form() -> void:
	current_form = (current_form + 1) % 4
	form_sfx.stop()
	form_sfx.play()
	update_animation()
func get_attack_anim_name() -> String:
	if is_on_floor():
		return anim("attack")
	else:
		return anim("attack_air")
	

	
func get_anim_name(base: String) -> String:
	return base + ("_2" if is_blue_form else "")
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("form_change"):
		cycle_form()
	if event.is_action_pressed("attack") and not is_attacking:
		is_attacking = true

		if current_form == Form.BLUE:
			gun_attack_sfx.stop()
			gun_attack_sfx.play()
			spawn_bullet()
		else:
			# choose melee sound by form
			match current_form:
				Form.BASE:
					melee_attack_sfx.stream = sword_sfx
				Form.GREEN:
					melee_attack_sfx.stream = axe_sfx
				Form.PURPLE:
					melee_attack_sfx.stream = scythe_sfx

			melee_attack_sfx.pitch_scale = randf_range(0.95, 1.05)
			melee_attack_sfx.stop()
			melee_attack_sfx.play()

			configure_melee_hitbox()
			hitbox.monitoring = true
			hitbox.monitorable = true
			hitbox_shape.disabled = false

		animated_sprite.play(get_attack_anim_name())


		


		
func apply_form_visuals() -> void:
	match current_form:
		Form.BASE:   pass
		Form.BLUE:   pass
		Form.GREEN:  pass
		Form.PURPLE: pass
	update_animation()
		
		

func configure_melee_hitbox() -> void:
	match current_form:
		Form.BASE:
			hitbox_shape.shape = rect_long
			hitbox.position = Vector2(base_front_x - rect_long.size.x/2.0, hitbox_y)
		Form.GREEN:
			hitbox_shape.shape = rect_short
			hitbox.position = Vector2(green_front_x - rect_short.size.x/2.0, hitbox_y)
		Form.PURPLE:
			hitbox_shape.shape = circle
			hitbox.position = Vector2(0, purple_y_offset)



		

	
func play_attack_anim(type: String) -> void:
	var prefix = "blue_" if is_blue_form else ""
	if is_on_floor():
		animated_sprite.play(prefix + "attack")
	else:
		animated_sprite.play(prefix + "attack_air" if is_blue_form else "attack")
		
func toggle_blue_form() -> void:
	is_blue_form = !is_blue_form
	print("Switched to ", "Blue" if is_blue_form else "Base", " Form!")
	is_attacking = false
	hitbox.monitorable = false
	hitbox_shape.disabled = true
	update_animation()
	
func _physics_process(delta: float) -> void:
# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_attacking:
		move_and_slide()
		return
	#if is_attacking and is_on_floor():
		#is_attacking=false
		#hitbox.monitoring=false
		#update_animation()
# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
# Get the input direction and handle the movement/deceleration.

	var direction := Input.get_axis("move_left", "move_right")
#Flip sprite
	if direction > 0:
		#animated_sprite.flip_h = false
		$Visuals.scale.x = 1
	elif direction < 0:
		#animated_sprite.flip_h = true
		$Visuals.scale.x = -1
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	update_animation()
	move_and_slide()
	
func update_animation() -> void:
	if is_on_floor():
		if abs(velocity.x) > 10:
			animated_sprite.play(anim("run"))
		else:
			animated_sprite.play(anim("idle"))
	else:
		animated_sprite.play(anim("jump"))
		
func spawn_bullet() -> void:
	var bullet = bullet_scene.instantiate()
	
	
	var dir := 1
	if visuals.scale.x <0:
		dir = -1
	bullet.shoot_direction = dir	
	get_parent().add_child(bullet)
	
	bullet.global_position = global_position + Vector2(30 * dir, -5)
	
	#bullet.global_position = global_position + Vector2(25 * (-1 if animated_sprite.flip_h else 1), -10)
	#bullet.shoot_direction = -1 if animated_sprite.flip_h else 1
func _on_animation_finished() -> void:
	is_attacking = false
	hitbox.monitoring = false
	hitbox.monitorable = false
	hitbox_shape.disabled = true
	update_animation()
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		var knockback_dir = (area.global_position - global_position).normalized()
		area.get_parent().take_damage(1, knockback_dir)
func take_damage(amount: int = 1) -> void:
	health -=amount
	print("Player HP: ", health)
	animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	animated_sprite.modulate = Color.WHITE
	if health <= 0:
		die()
func die() -> void:
	death_sfx.stop()
	death_sfx.play()
	animated_sprite.play("die")
	set_physics_process(false)
