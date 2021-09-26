extends Node2D

# configuration
export (PackedScene) var boidScene : PackedScene
export (int) var numberOfBoids = 40 #controls the number of boid would appair 
export (float) var visualRange = 100 #sets visual range for boids
export (float) var separationDistance = 80 #sets minimum separetion distence for boids
export (NodePath) var predator #inheritance of predator
export (NodePath) var predator2 #inheritance of predator2
export (NodePath) var predator3 #inheritance of predator3
export (NodePath) var leader #inheritance of leader of the predators
export (float) var predatorMinDist = 300 #minimum distence that should be maintained from predator
export (int) var maxNeighborsColor = 20 #maximum neighbour that can stay together at a time
var _predatorRef
var _predatorRef2
var _predatorRef3
var _leader
export (Vector2) var d

# weights for parameters
export (float) var cohesionWeight = 0.1
export (float) var separationWeight = 100
export (float) var alignmentWeight = 1
export (float) var bordersWeight = 300
export (float) var predatorWeight = 500
var c = 0
var _boids = []
var _envDims # Environment Dimentions

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) # Useing this will allow to take input from mouse's movement
	
	randomize()
	_envDims = get_viewport().size
	_predatorRef = get_node(predator)
	_predatorRef2 = get_node(predator2)
	_predatorRef3 = get_node(predator3)
	_leader = get_node(leader)
	
	for i in range(numberOfBoids):
		var instance = boidScene.instance()
		add_child(instance) #Adding boids 
		_boids.append(instance) #Appending characteristics of Boid to the added boids 
		var a = _envDims.x/2
		var b = -_envDims.x/2
		var x = rand_range(-_envDims.x, _envDims.x)  
		var y = ((b/a)*(sqrt((a*a)-(x*x)))) #Responsible for boids appearing on a circulaer formation
		if (c%2 == 0):
			y=-y
		else:
			y=y
		#var x = rand_range(-_envDims.x, _envDims.x) # Responsible for boids appearing im random positions
		#var y = rand_range(-_envDims.y, _envDims.y) # Responsible for boids appearing im random positions
		instance.set_position(Vector2(x, y))
		c=c+1 #count for the equation
		
		

func _process(delta):
	_detectNeighbors()
	_cohesion()	
	_separation()
	_alignment()
	_escapePredator()
	_escapePredator2()
	_escapePredator3()
	_escapeLeader()
	_borders(delta)
	_calculateColor()
	_trminate()

func _detectNeighbors(): #Function for neighbour ditection
	for i in range(_boids.size()):
		_boids[i].neighbors.clear()
		_boids[i].neighborsDistances.clear()
	
	for i in range(_boids.size()):		
		for j in range(i+1, _boids.size()):
			var distance = _boids[i].get_position().distance_to(_boids[j].get_position())
			if (distance <= visualRange):
				_boids[i].neighbors.append(_boids[j])
				_boids[j].neighbors.append(_boids[i])
				_boids[i].neighborsDistances.append(distance)
				_boids[j].neighborsDistances.append(distance)


func _cohesion(): #Function for cohesion
	for i in range(_boids.size()):
		var neighbors = _boids[i].neighbors
		if (neighbors.empty()):
			continue;
		var averagePos = Vector2(0, 0)
		for closeBoid in neighbors:
			averagePos += closeBoid.get_position()
			
		averagePos /= neighbors.size()
		d = averagePos
		var direction = averagePos - _boids[i].get_position()
		for boid in _boids:
				var dist = boid.get_position().distance_to(_predatorRef.get_position())
				if (dist < predatorMinDist):
					_boids[i].acceleration += direction * cohesionWeight
				elif (dist > predatorMinDist):
					_boids[i].acceleration = direction * 0

func _separation(): #Function for separation
	for i in range(_boids.size()):
		var neighbors = _boids[i].neighbors
		var distances = _boids[i].neighborsDistances
		if (neighbors.empty()):
			continue;
		for j in range(neighbors.size()):
			if (distances[j] >= separationDistance):
				continue
			var distMultiplier = 1 - (distances[j] / separationDistance)
			var direction = _boids[i].get_position() - neighbors[j].get_position()
			direction = direction.normalized()
			for boid in _boids:
				var dist = boid.get_position().distance_to(_predatorRef.get_position())
				if (dist < predatorMinDist):
					_boids[i].acceleration += direction * distMultiplier * separationWeight
				elif (dist > predatorMinDist):
					_boids[i].acceleration = direction * distMultiplier * 0
			
func _alignment(): #Function for alignment
	for i in range(_boids.size()):
		var neighbors = _boids[i].neighbors
		if (neighbors.empty()):
			continue;
		var averageVel = Vector2(0, 0)
		for j in range(neighbors.size()):
			averageVel += neighbors[j].velocity
		averageVel /= neighbors.size()
		for boid in _boids:
			var dist = boid.get_position().distance_to(_predatorRef.get_position())
			if (dist < predatorMinDist):
				_boids[i].acceleration += averageVel * alignmentWeight
			elif (dist > predatorMinDist):
				_boids[i].acceleration = averageVel * 0


func _borders(delta):  #Function for avoiding borders
	for boid in _boids:
		var pos = boid.get_position()
		if (pos.x < -_envDims.x or pos.x > _envDims.x or pos.y < -_envDims.y or pos.y > _envDims.y):
			boid.timeOutOfBorders += delta
			
			var x = -_envDims.x/2
			var y = -_envDims.y/2
			
			var midPoint = Vector2(x, y)
			var dir = (midPoint - boid.get_position()).normalized()
			boid.acceleration += dir * boid.timeOutOfBorders * bordersWeight
		
		else:
			boid.timeOutOfBorders = 0

func _escapePredator(): #Function for escaping predator
	for boid in _boids:
		var dist = boid.get_position().distance_to(_predatorRef.get_position())
		if (dist < predatorMinDist):
			var dir = (boid.get_position() - _predatorRef.get_position()).normalized()
			var multiplier = sqrt(1 - (dist / predatorMinDist))
			boid.acceleration += dir * multiplier * predatorWeight

func _escapePredator2(): #Function for escaping predator
	for boid in _boids:
		var dist = boid.get_position().distance_to(_predatorRef2.get_position())
		if (dist < predatorMinDist):
			var dir = (boid.get_position() - _predatorRef2.get_position()).normalized()
			var multiplier = sqrt(1 - (dist / predatorMinDist))
			boid.acceleration += dir * multiplier * predatorWeight
			
func _escapePredator3(): #Function for escaping predator
	for boid in _boids:
		var dist = boid.get_position().distance_to(_predatorRef3.get_position())
		if (dist < predatorMinDist):
			var dir = (boid.get_position() - _predatorRef3.get_position()).normalized()
			var multiplier = sqrt(1 - (dist / predatorMinDist))
			boid.acceleration += dir * multiplier * predatorWeight

func _escapeLeader(): #Function for escaping predator
	for boid in _boids:
		var dist = boid.get_position().distance_to(_leader.get_position())
		if (dist < predatorMinDist):
			var dir = (boid.get_position() - _leader.get_position()).normalized()
			var multiplier = sqrt(1 - (dist / predatorMinDist))
			boid.acceleration += dir * multiplier * predatorWeight

func _calculateColor(): #Function for calculating colour of boids
	for boid in _boids:
		if (boid.neighbors.empty()):
			continue
		var specialColorPercent = float(boid.neighbors.size()) / maxNeighborsColor
		var baseColorPercent = 1 - specialColorPercent
		boid.targetColor = boid.baseColor * baseColorPercent + boid.specialColor * specialColorPercent #changes colour when has too many neighbours
		_leader.target.targetColor = Color(1, 1 , 1 ,1) #changes colour when selected as target by the leader

func _trminate(): #Function for simulating tarmination
	var tarDisL = _leader.target.get_position().distance_to(_leader.get_position()) #for leader
	if (tarDisL <= 100):  #Tarmination minimum distence seting
		_leader.target.targetColor = Color( 0, 0, 0, 1) #Turning tarminated boid black
		_leader.target.acceleration = Vector2(0, 0) * 0 #Turning the accelaration zero for the tarminated boid
		_leader.target.velocity = Vector2(0, 0) * 0 #Turning the Velocity zero for the tarminated boid
	var tarDisP = _leader.target.get_position().distance_to(_predatorRef.get_position()) #for predator
	if (tarDisP <= 100):
		_leader.target.targetColor = Color( 0, 0, 0, 1)
		_leader.target.acceleration = Vector2(0, 0) * 0
		_leader.target.velocity = Vector2(0, 0) * 0
	var tarDisP2 = _leader.target.get_position().distance_to(_predatorRef2.get_position()) #for predator 2 
	if (tarDisP2 <= 100):
		_leader.target.targetColor = Color( 0, 0, 0, 1)
		_leader.target.acceleration = Vector2(0, 0) * 0
		_leader.target.velocity = Vector2(0, 0) * 0
	var tarDisP3 = _leader.target.get_position().distance_to(_predatorRef3.get_position()) #for predator 3 
	if (tarDisP3 <= 100):
		_leader.target.targetColor = Color( 0, 0, 0, 1)
		_leader.target.acceleration = Vector2(0, 0) * 0
		_leader.target.velocity = Vector2(0, 0) * 0
