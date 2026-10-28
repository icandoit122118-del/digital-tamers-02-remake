extends GMInstance
## obj_Special_ENEMY (원작 우하단 적 필살기 아이콘)

func create() -> void:
	image_speed = 0.0
	depth = -2100


func step() -> void:
	image_index = 1.0 if float(GM.battle.get("e_sp", 0.0)) >= 100.0 else 0.0
