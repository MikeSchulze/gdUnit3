extends KinematicBody
class_name Player


#warnings-disable
var camera_angle = 0
var mouse_sensitivity = 0.3

var velocity = Vector3.ZERO
var direction = Vector3.ZERO
#
const PLAYER_FLY_SPEED = 20
const PLAYER_FLY_ACCEL = 4
#
const PLAYER_WALK_SPEED = 5
const PLAYER_WALK_SPEED_MAX = 1
const PLAYER_WALK_SPEED_MIN = 10
const PLAYER_WALK_ACCEL = 2
const PLAYER_WALK_DEACCEL = 6
var gravity =  9.8*2


const BULLET_TEMPLATE = preload("res://gdUnit3-examples/RoomDemo3D/src/Bullet.tscn")
const BULLET_SPEED = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	
func _physics_process(delta):
	walk(delta)
	if Input.is_action_just_pressed("player_room3ddemo_input_fire"):
		shootBullet(delta)

func fly(delta):
	direction = Vector3.ZERO
	
	# get rotation of the camera
	var aim = $head/Camera.get_global_transform().basis
	
	if Input.is_action_pressed("player_room3ddemo_input_up"):
		direction -= aim.z
	if Input.is_action_pressed("player_room3ddemo_input_down"):
		direction += aim.z
	if Input.is_action_pressed("player_room3ddemo_input_left"):
		direction -= aim.x
	if Input.is_action_pressed("player_room3ddemo_input_right"):
		direction += aim.x
	
	direction = direction.normalized()
	
	var target = direction * PLAYER_FLY_SPEED
	velocity = velocity.linear_interpolate(target, PLAYER_FLY_ACCEL*delta)
	move_and_slide(velocity)
	
func walk(delta):
	direction = Vector3.ZERO
	
	# get rotation of the camera
	var aim = $head/Camera.get_global_transform().basis
	
	if Input.is_action_pressed("player_room3ddemo_input_up"):
		direction -= aim.z
	if Input.is_action_pressed("player_room3ddemo_input_down"):
		direction += aim.z
	if Input.is_action_pressed("player_room3ddemo_input_left"):
		direction -= aim.x
	if Input.is_action_pressed("player_room3ddemo_input_right"):
		direction += aim.x
	
	direction = direction.normalized()
	
	velocity.y -= gravity * delta
	
	var target = direction * PLAYER_FLY_SPEED
	velocity = velocity.linear_interpolate(target, PLAYER_FLY_ACCEL*delta)
	move_and_slide(velocity)
	
	
func _input(event):
	if event is InputEventMouseMotion:
		$head.rotate_y( deg2rad(-event.relative.x * mouse_sensitivity))
		
		var change = -event.relative.y * mouse_sensitivity
		if change+camera_angle < 90 and change+camera_angle > -90:
			$head/Camera.rotate_x( deg2rad(change))
			camera_angle += change

func shootBullet(delta):
	var bullet:RigidBody = BULLET_TEMPLATE.instance()
	bullet.transform = $body/Hand.global_transform
	bullet.apply_impulse(Vector3(0,0,0), -$head/Camera.global_transform.basis.z.normalized() * 25)
	get_tree().get_root().add_child(bullet)
