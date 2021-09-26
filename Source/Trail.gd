extends Line2D
# this segment is for the tails for both preators and flocks
export (float) var pointDuration = 1 #how much time will it be visible
export (int) var maxPoints = 200 #in how many poits it will appeir 
var _times = []
var _timer = 0

func _ready():
	set_as_toplevel(true)

func _process(delta):
	_timer += delta
	
	if (_times.size() > 0):
		while (_times[0] <= _timer or _times.size() > maxPoints):
			remove_point(0)
			_times.remove(0)
	
	global_position = Vector2.ZERO
	add_point(get_parent().global_position)
	_times.append(_timer + pointDuration)
