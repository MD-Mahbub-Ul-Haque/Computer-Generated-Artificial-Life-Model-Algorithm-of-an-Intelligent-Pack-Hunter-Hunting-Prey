extends Node2D

class_name Boid

export (float) var maxVelocity = 280 #stes the maximum velocity for the flocks
export (float) var maxAcceleration = 1000 #stes the maximum Acceleration speed for the flocks
export (float) var rotationOffset = PI/2 # defines the rotation of the flock while moving

export (Color) var baseColor : Color # sets the flocks colour when nothing is happening
export (Color) var specialColor : Color # sets flocks colour for spacial situations
export (float) var colorTransitionSpeed = 1 # sets how fast the colour wil change

export (bool) var syncTrail = true 
export (NodePath) var trail # including the tail 
var trailRef : Line2D # inheritance of trail

var velocity := Vector2.ZERO #initializing value 
var acceleration := Vector2.ZERO #initializing value 
var neighbors := []
var neighborsDistances := []
var timeOutOfBorders := 0.0
var targetColor := baseColor

func _ready():  # ready state or initial state
	trailRef = get_node(trail)
	modulate = targetColor
	velocity = Vector2(0,0) #sets velocity so that in begaing the flock don't move
	#velocity = Vector2(rand_range(-maxVelocity, maxVelocity),rand_range(-maxVelocity, maxVelocity)) # Use if you want to flock get movemnt autometically at begaining
	
func _process(delta): #the main function
	velocity += acceleration.clamped(maxAcceleration * delta) #used to increase the velocity slowly to the maximum
	velocity = velocity.clamped(maxVelocity)
	acceleration.x = 0 #sets acceleration so that in begaing the flock don't move
	acceleration.y = 0 #sets acceleration so that in begaing the flock don't move
	
	position += velocity * delta # Increases positions value which makes the flocks move
	
	look_at(position + velocity) # flocks heading
	rotation += rotationOffset #flocks rotation
	
	var targetColorPercent = delta * colorTransitionSpeed
	modulate = modulate * (1 - targetColorPercent) + targetColor * targetColorPercent #for colour changing 
	
	if (syncTrail): #for tail
		var gradient = trailRef.gradient
		for i in range(gradient.colors.size()):
			var nextColor = modulate
			nextColor.a = gradient.colors[i].a
			gradient.set_color(i, nextColor)
