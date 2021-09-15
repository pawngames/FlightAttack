extends Control

func _ready():
	pass

func _process(delta):
	pass

func set_enemy_count(count:int):
	$CntRight/HBoxScore/LabelCount.text = str(count)
	pass

func set_coin_count(count:int):
	$CntRight/HBoxCoin/LabelCount.text = str(count)
	pass
