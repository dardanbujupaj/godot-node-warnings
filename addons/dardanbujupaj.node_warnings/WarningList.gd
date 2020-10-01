tool
extends Control


signal warning_selected


var warnings: Array = [] setget _set_warnings

onready var item_list: ItemList = $HSplitContainer/VBoxContainer/ItemList
onready var filter: LineEdit = $HSplitContainer/VBoxContainer/Toolbar/Filter
onready var warning_count: Label = $HSplitContainer/VBoxContainer/Toolbar/WarningCount
onready var tree: Tree = $HSplitContainer/VBoxContainer2/Tree


func _ready():
	setup_tree()


func _set_warnings(new_warnings: Array):
	warnings = new_warnings
	_update_warning_list()


func _on_Filter_text_changed(new_text: String):
	_update_warning_list()


func _update_warning_list():
	warning_count.text = "%d warnings" % len(warnings) 
	
	item_list.clear()
	for warning in warnings:
		var node = warning["node"]
		var text = node.name + ": {property} == {critical_value}".format(warning["rule"])
		if filter.text == "" or filter.text in text:
			var index = item_list.get_item_count()
			item_list.add_item(text, preload("./NodeWarning.svg"), true)
			item_list.set_item_tooltip(index, warning["rule"]["description"])
			item_list.set_item_metadata(index, warning)


# select corresponding node when a warning was selected
func _on_ItemList_item_selected(index):
	var metadata = item_list.get_item_metadata(index)
	emit_signal("warning_selected", metadata)


# TODO: setup correct tree
func setup_tree():
	tree.clear()
	var root = tree.create_item()
	root.set_text(0, "Warning rules")
	root.disable_folding = true
	
	var default_nodes = ["Node2D", "RayCast"]
	
	for node in default_nodes:
	
		var item = tree.create_item(root)
		item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
		item.set_editable(0, true)
		item.set_text(0, node)
		item.set_icon(0, get_icon(node, "EditorIcons"))
		item.set_custom_bg_color(0, Color.black)
		get_color()
		item.set_custom_bg_color(1, Color.black)
		
		var property = tree.create_item(item)
		property.set_text(0, "Property")
		property.set_editable(1, true)
		property.set_text(1, "position")
		
		var value = tree.create_item(item)
		value.set_text(0, "Value")
		value.set_editable(1, true)
		value.set_text(1, "1")
	
	

# is called when a class is selected
func _on_Tree_custom_popup_edited(arrow_clicked):
	
	$ClassPopupMenu.clear()
	# TODO: remove classes where rules already exist
	var classes: Array = ClassDB.get_inheriters_from_class("Node")
	classes.append("Node")
	classes.sort()
	for c in classes:
		if ClassDB.can_instance(c):
			var icon = get_icon(c, "EditorIcons")
			$ClassPopupMenu.add_icon_item(icon, c)
		
	# show popup to choose new class
	$ClassPopupMenu.popup(tree.get_custom_popup_rect())


# change icon and text if a new class was selected
# TODO: change properties
func _on_ClassPopupMenu_index_pressed(index):
	tree.get_edited().set_text(0, $ClassPopupMenu.get_item_text(index))
	tree.get_edited().set_icon(0, $ClassPopupMenu.get_item_icon(index))

