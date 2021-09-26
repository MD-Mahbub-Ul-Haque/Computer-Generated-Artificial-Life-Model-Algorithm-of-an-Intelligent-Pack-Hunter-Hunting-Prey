extends Node2D

export (NodePath) var flock #inheritance of the flock
export (float) var acceleration # setting acceleration for predator's leader
export (float) var maxSpeed # setting maximum speed for predator's leader
export (float) var minSpeed # setting minimum speed for predator's leader
export (float) var visualRange = 300 # setting visual range for predator's leader
var _flockRef
var speed
var _envDims
var _vel = Vector2.ZERO
var targetPos = Vector2.ZERO
var _arr = []
var _dis=[_arr.size()]
var minPos 
var minDis
var target
var velocity := Vector2.ZERO
var vis_color = Color(.867, .91, .247, 0.1)
var freezPos
var activefl

func inactive(delta): #Function for inactive state 
	_vel += (target.get_position() - position).clamped(acceleration) * delta
	_vel = _vel.clamped(minSpeed)
	position = position + (_vel * delta)
	look_at(position + _vel)
	rotation += PI / 2
	
func active(delta): #Function for inactive state
	if (targetPos != position ):
		_vel += (targetPos - position).clamped(acceleration) * delta
		_vel = _vel.clamped(maxSpeed)
		position = position + (_vel * delta)
		look_at(position + _vel)
		rotation += PI / 2
		
	freezPos = target.get_position().distance_to(position) #responseble for frame freezing/ slow-motion when too near if target
	if( freezPos < 200 ): #minimum distence for frame freezing 
		frameFreeze(0.25, 5.0) #duration of frame freezing

func _process(delta):
	
	randomize()
	_envDims = get_viewport().size
	_flockRef = get_node(flock)
	_arr = _flockRef._boids
	_targetSelection(_arr)
	
	if (target.get_position().distance_to(position) <= 1200): # Detarmines active or inactive sates
		active(delta)
		activefl = 1
	else: 
		inactive(delta)
		

# This target selection section is only for predator's leader 

var _S = [100]
var _D = [100]
var min_S
var min_D

func _targetSelection(boid):
	for i in range(boid.size()):
		for j in range(_S.size()):
			_S[j] = boid[i].acceleration
		for k in range(_D.size()):
			_D[k] = boid[i].get_position().distance_to(position)
			
	_S.sort()
	min_S = _S[0]
	_D.sort()
	min_D = _D[0]
	minPos = min_D
	for i in range(boid.size()):
		if (boid[i].acceleration <= min_S && boid[i].get_position().distance_to(position) <= min_D ):
			targetPos = boid[i].get_position()
			target = boid[i]
			break
		else: 
			targetPos = _arr[0].get_position()
			target = _arr[0]
		
# function for frame freezing
func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	yield(get_tree().create_timer(duration * timeScale), "timeout")
	Engine.time_scale = 1.0
