extends GMInstance
## obj_SpecialHUD_Enemy (obj_SpecialHUD_Player가 전체 데크를 렌더링하므로 중복 비활성화)

func create() -> void:
	visible = false
