extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

const DASH_SPEED = 850.0
const DASH_DURATION = 0.18
const DASH_COOLDOWN = 0.45
const FIREBALL_SCENE = preload("res://fireball.tscn")

var dash_time_left = 0.0
var facing_direction = 1.0
var dash_cooldown_left = 0.0
var is_attacking = false

var max_health = 3
var health = 3

var max_mana = 100.0
var mana = 100.0

@onready var sword_collision: CollisionShape2D = $SwordHitbox/CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer
@onready var sword_hitbox: Area2D = $SwordHitbox
@onready var player_visual: AnimatedSprite2D = $PlayerVisual
@onready var fireball_spawn: Marker2D = $FireballSpawn

func _ready() -> void:
	player_visual.play("idle")
	
func _physics_process(delta: float) -> void:
	# Gravedad.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Reducir el tiempo de cooldown del dash.
	if dash_cooldown_left > 0:
		dash_cooldown_left -= delta

	# Salto.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimiento horizontal.
	var direction := Input.get_axis("move_left", "move_right")
	
	# Cambiar animación según el movimiento.
	if not is_attacking:
		if dash_time_left > 0:
			player_visual.play("dash")
		elif not is_on_floor():
			player_visual.play("jump")
		elif direction != 0:
			player_visual.play("walk")
		else:
			player_visual.play("idle")

	# Recordar hacia qué lado está mirando el jugador.
	if direction != 0:
		facing_direction = direction
		player_visual.flip_h = direction < 0
		sword_hitbox.position.x = 30.0 * facing_direction
		fireball_spawn.position.x = 30.0 * facing_direction

	# Activar dash solamente si no está en cooldown.
	if Input.is_action_just_pressed("dash") and dash_time_left <= 0 and dash_cooldown_left <= 0:
		dash_time_left = DASH_DURATION
		dash_cooldown_left = DASH_COOLDOWN

	# Movimiento durante dash o movimiento normal.
	if dash_time_left > 0:
		dash_time_left -= delta
		velocity.x = facing_direction * DASH_SPEED
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Ataque con espada.
	if Input.is_action_just_pressed("attack") and attack_timer.is_stopped() and not is_attacking:
		is_attacking = true
		player_visual.play("attack")
		sword_collision.set_deferred("disabled", false)
		attack_timer.start()

		# Lanzar bola de fuego.
	if Input.is_action_just_pressed("magic"):
		var fireball = FIREBALL_SCENE.instantiate()
		get_tree().current_scene.add_child(fireball)
		fireball.global_position = fireball_spawn.global_position
		fireball.direction = facing_direction
		
	move_and_slide()


func _on_attack_timer_timeout() -> void:
	sword_collision.set_deferred("disabled", true)


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	if body == self:
		return

	if body.has_method("take_damage"):
		body.take_damage(1)


func _on_player_visual_animation_finished() -> void:
	if player_visual.animation == "attack":
		is_attacking = false
