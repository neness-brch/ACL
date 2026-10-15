extends TextureProgressBar


@export var player: Player

func _ready():
	player.HealthChanged.connect(update)
	update()

func update():
	
	value = player.current_health * 100/player.max_health
