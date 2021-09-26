extends Node2D
#All is as same as leader except the target selection part is not aplicable here and it inherits leader
export (NodePath) var flock
export (NodePath) var leader
export (float) var acceleration
export (float) var maxSpeed
export (float) var minSpeed
export (float) var visualRange = 100

var _flockRef
var _leader
var speed
var _vel = Vector2.ZERO
var targetPos
var _arr = []
var _dis=[_arr.size()]
var minPos 
var minDis
var velocity := Vector2.ZERO
var target

func inactive(delta):
	_vel += (_flockRef.d - position).clamped(acceleration) * delta
	_vel = _vel.clamped(minSpeed)
	position = position + (_vel * delta)
	look_at(position + _vel)
	rotation += PI / 2

func active(delta):
	if (targetPos != position ):
		_vel += (targetPos - position).clamped(acceleration) * delta
		_vel = _vel.clamped(maxSpeed)
		position = position + (_vel * delta)
		look_at(position + _vel)
		rotation += PI / 2

func _process(delta):
	randomize()
	_flockRef = get_node(flock)
	_leader = get_node(leader)
	targetPos = _leader.targetPos
	target = _leader.target
	
	if (_leader.activefl == 1):
		active(delta)
	else: 
		inactive(delta)
		
func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	yield(get_tree().create_timer(duration * timeScale), "timeout")
	Engine.time_scale = 1.0
