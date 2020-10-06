tool
extends VBoxContainer

var warning_rules: Dictionary

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
	
	for node in warning_rules.keys():
		var item = tree.create_item(root)
		#item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
		#item.set_editable(0, true)
		item.set_text(0, node)
		item.set_icon(0, get_icon(node, "EditorIcons"))
		item.add_button(1, get_icon("Remove", "EditorIcons"), -1, false, "Remove this rule")
		
		
		var category_color = get_color("prop_category", "Editor")
		item.set_custom_bg_color(0, category_color)
		item.set_custom_bg_color(1, category_color)
		
		
		for rule in warning_rules[node]:
			
			var rule_item = tree.create_item(item)
			rule_item.set_text(0, rule['property'])
			rule_item.add_button(1, get_icon("Remove", "EditorIcons"), -1, false, "Remove this rule")
			
			var section_color = get_color("prop_section", "Editor")
			rule_item.set_custom_bg_color(0, section_color)
			rule_item.set_custom_bg_color(1, section_color)
			
			
			var value = tree.create_item(rule_item)
			value.set_text(0, "Critical value")
			value.set_tooltip(0, "When property equals this value, a warning will be shown")
			value.set_editable(1, true)
			value.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
			value.set_checked(1, rule['critical_value'])
			
			var description = tree.create_item(rule_item)
			description.set_text(0, "Description")
			description.set_tooltip(0, "Description of the rule")
			description.set_editable(1, true)
			description.set_text(1, rule["description"])


# is called when a class is selected for a ruleset
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



func _on_Tree_button_pressed(item, column, id):
	item.free()
