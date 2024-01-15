class_name Stack extends Node

var stack_array = []

# Method to push an item onto the stack
func push(item):
	stack_array.push_back(item)

# Method to pop the top item from the stack
func pop():
	if is_empty():
		print_debug("Can't pop stack. Stack is empty")
		return null
	else:
		return stack_array.pop_back()

# Method to check if the stack is empty
func is_empty():
	return stack_array.is_empty()

# Method to get the size of the stack
func size():
	return stack_array.size()

# Method to peek at the top item without removing it
func peek():
	if is_empty():
		print_debug("Can't peek stack. Stack is empty")
		return null
	else:
		return stack_array[stack_array.size() - 1]
		
func has(item):
	if is_empty(): 
		print_debug("Item not in stack. Stack is empty")
		return null
	else:
		return stack_array.has(item)
		
func pretty_print():
	print("Stack")
	for item in stack_array:
		print("├──", item)
	print("└── end")
