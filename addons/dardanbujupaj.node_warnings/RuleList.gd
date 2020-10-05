tool
extends VBoxContainer


onready var class_popup: PopupMenu = $ClassPopupMenu

onready var tree: Tree = $Tree

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_tree()
	pass # Replace with function body.


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
		item.add_button(1, get_icon("GuiClose", "EditorIcons"))
		
		var category_color = get_color("prop_category", "Editor")
		item.set_custom_bg_color(0, category_color)
		item.set_custom_bg_color(1, category_color)
		
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
	
	class_popup.clear()
	# TODO: remove classes where rules already exist
	var classes: Array = ClassDB.get_inheriters_from_class("Node")
	classes.append("Node")
	classes.sort()
	for c in classes:
		if ClassDB.can_instance(c):
			var icon = get_icon(c, "EditorIcons")
			class_popup.add_icon_item(icon, c)
		
	# show popup to choose new class
	class_popup.popup(tree.get_custom_popup_rect())


# change icon and text if a new class was selected
# TODO: change properties
func _on_ClassPopupMenu_index_pressed(index):
	tree.get_edited().set_text(0, class_popup.get_item_text(index))
	tree.get_edited().set_icon(0, class_popup.get_item_icon(index))

