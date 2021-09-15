extends CenterContainer

var transition_time:float = 0.6

var playlist = [
	"Brave Space Explorers",
	"Law in the City",
	"Zodik - Cyborg Destiny",
	"Zodik - Future Travel",
	"Zodik - Lord of Zorg I",
	"Zodik - Neon Owl",
	"Zodik - Path Zion",
	"Zodik - Tedox",
	"Zodik - TimeQ",
	"Zodik - Touch The Sky",
	"Aries Beats - UpBeat 2",
	"Aries Beats - Synthwave Party",
	"Nihilore - Disconnected",
	"Nihilore - Motion Blur"
]

var current_track

func _ready():
	play()
	$Music.connect("finished", self, "play")
	pass

func _choose(array:Array)->String:
	randomize()
	array.shuffle()
	return array.front()

func play():
	current_track = _choose(playlist)
	$Bg/HB/Lbl.text = current_track
	$Tween.interpolate_property(
		$Music, "volume_db", 0, -50, transition_time,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	$Tween.interpolate_property(
		$Bg, "rect_position", Vector2(0,-100), Vector2(0,0), 
		transition_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	$Tween.connect("tween_all_completed", self, "_tween_out")
	$Tween.start()
	pass

func _tween_out():
	$Tween.disconnect("tween_all_completed", self, "_tween_out")
	$Tween.interpolate_property(
		$Music, "volume_db", -50, 0, transition_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	$Music.stream = load("res://assets/sfx/" + current_track + ".ogg")
	$Music.play(0.0)
	$Tween.interpolate_property(
		$Bg, "rect_position", Vector2(0,0), Vector2(0,-100), 
		transition_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 
		transition_time*4
	)
	$Tween.start()
	pass
