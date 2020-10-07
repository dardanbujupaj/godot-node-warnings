tool
extends VBoxContainer

signal warning_rules_updated
signal warning_rules_reset

var warning_rules: Dictionary setget _set_warning_rules

onready var class_popup: PopupMenu = $ClassPopupMenu

onready var tree: Tree = $Tree

onready var delete_texture = get_icon("Remove", "EditorIcons")
onready var add_texture = get_icon("Add", "EditorIcons")

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
		item.add_button(1, add_texture, -1, false, "Add a new rule for this class")
		item.add_button(1, delete_texture, -1, false, "Remove rules for this class")
		
		
		var category_color = get_color("prop_category", "Editor")
		item.set_custom_bg_color(0, category_color)
		item.set_custom_bg_color(1, category_color)
		
		
		for rule in warning_rules[node]:
			add_rule(item, rule["property"], rule["critical_value"], rule["description"])


# is called when a class is selected for a ruleset
func _on_Tree_custom_popup_edited(arrow_clicked):
	var property_popup = PopupMenu.new()
	
	var property_item = tree.get_selected()
	var class_item = property_item.get_parent()
	
	# TODO: remove classes where rules already exist
	var properties = ClassDB.class_get_property_list(class_item.get_text(0), true)
	properties.sort()
	for property in properties:
		property_popup.add_item(property["name"])
		
	# show popup to choose new class
	property_popup.connect("index_pressed", self, "_on_property_selected", [property_popup, property_item])
	add_child(property_popup)
	property_popup.popup(tree.get_custom_popup_rect())


func _on_property_selected(index, property_popup, property_item):
	var property = property_popup.get_item_text(index)
	property_item.set_text(0, property)
	property_popup.queue_free()
	_on_rules_updated()


func add_rule(class_item: TreeItem, property: String, critical_value: bool, description: String):
	var rule_item = tree.create_item(class_item)
	rule_item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
	rule_item.set_text(0, property)
	rule_item.set_editable(0, true)
	rule_item.add_button(1, get_icon("Remove", "EditorIcons"), -1, false, "Remove this rule")
	
	var section_color = get_color("prop_section", "Editor")
	rule_item.set_custom_bg_color(0, section_color)
	rule_item.set_custom_bg_color(1, section_color)
	
	
	var value_item = tree.create_item(rule_item)
	value_item.set_text(0, "Critical value")
	value_item.set_tooltip(0, "When property equals this value, a warning will be shown")
	value_item.set_editable(1, true)
	value_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	value_item.set_checked(1, critical_value)
	
	var description_item = tree.create_item(rule_item)
	description_item.set_text(0, "Description")
	description_item.set_tooltip(0, "Description of the rule")
	description_item.set_editable(1, true)
	description_item.set_text(1, description)
	

# change icon and text if a new class was selected
# TODO: change properties
func _on_ClassPopupMenu_index_pressed(index):
	
	var item = tree.create_item(tree.get_root())
	
	item.set_text(0, class_popup.get_item_text(index))
	item.set_icon(0, class_popup.get_item_icon(index))
	item.add_button(1, delete_texture, 0, false, "Remove this rule")
	
	
	var category_color = get_color("prop_category", "Editor")
	item.set_custom_bg_color(0, category_color)
	item.set_custom_bg_color(1, category_color)
	
	_on_rules_updated()



func _on_Tree_button_pressed(item, column, id):
	var texture = item.get_button(column, id)
	
	# match the texture to find out which action was pressed
	match texture:
		delete_texture:
			item.free()
		add_texture:
			add_rule(item, "", false, "")
	_on_rules_updated()


func _on_AddRule_pressed():
	class_popup.clear()
	# TODO: remove classes where rules already exist
	var classes: Array = ClassDB.get_inheriters_from_class("Node")
	classes.append("Node")
	classes.sort()
	for c in classes:
		if not warning_rules.has(c):
			var icon = get_icon(c, "EditorIcons")
			class_popup.add_icon_item(icon, c)
	class_popup.popup()
	class_popup.set_position(get_global_mouse_position())


# whenever the rules are updated from outside the tree should be updated
func _set_warning_rules(new_rules):
	warning_rules = new_rules
	call_deferred("setup_tree")


# to be called whenever the rules tree is modified
func _on_rules_updated():
	var rules = get_rules_dictionary()
	emit_signal("warning_rules_updated", rules)


# parse the rules tree into a dictionary
func get_rules_dictionary():
	var dictionary = {}
	
	# iterate over rule node entries
	var current_item = tree.get_root().get_children()
	while current_item != null:
		var rules = []
		
		# iterate over rules for this node
		var current_rule = current_item.get_children()
		while current_rule != null:
			var property = current_rule.get_text(0)
			var critical_value = current_rule.get_children().is_checked(1)
			var description = current_rule.get_children().get_next().get_text(1)
			
			# add the rule to the list
			rules.append({
				"property": property,
				"critical_value": critical_value,
				"description": description
			})
			
			current_rule = current_rule.get_next()
		
		dictionary[current_item.get_text(0)] = rules
		
		
		
		# get next sibling
		current_item = current_item.get_next()
	
	return dictionary

func _on_Tree_item_edited():
	# compare old and new rules, only update if they changed
	if to_json(warning_rules) != to_json(get_rules_dictionary()):
		_on_rules_updated()


func _on_ResetRules_pressed():
	emit_signal("warning_rules_reset")


