class_name InventoryData extends Resource

@export var slots : Array[ SlotData ]

func _init() -> void:
	connect_slots()

func add_item(item : ItemData) -> void:
	if item == null:
		push_error("Item null!")
		return
	
	for i in range(slots.size()):
		if slots[i] == null:
			var new_slot := SlotData.new()
			new_slot.item_data = item
			slots[i] = new_slot
			
			new_slot.changed.connect(slot_changed)
			emit_changed()
			
			print("Item masuk:", item.name)
			return
	
	print("Inventory penuh!")

func connect_slots() -> void:
	for s in slots:
		if s:
			if not s.changed.is_connected(slot_changed):
				s.changed.connect(slot_changed)

func slot_changed() -> void:
	if Engine.is_editor_hint():
		return
	
	emit_changed()

func get_save_data() -> Array:
	var item_save : Array = []
	for i in slots.size():
		item_save.append( item_to_save( slots[i] ) )
	return item_save

func item_to_save(slot : SlotData) -> Dictionary:
	var result = { item = "" }
	
	if slot != null and slot.item_data != null:
		result.item = slot.item_data.resource_path
	
	return result

func parse_save_data(save_data : Array) -> void:
	var array_size = slots.size()
	slots.clear()
	slots.resize(array_size)
	
	for i in range(save_data.size()):
		var slot = item_from_save(save_data[i])
		slots[i] = slot
		
		if slot:
			slot.changed.connect(slot_changed)
	
	emit_changed()

func item_from_save( save_object : Dictionary ) -> SlotData:
	if save_object.item == "":
		return null
	var new_slot : SlotData = SlotData.new()
	new_slot.item_data = load( save_object.item )
	return new_slot
