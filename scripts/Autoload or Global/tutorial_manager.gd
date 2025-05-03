# tutorial_manager.gd
extends Node
var collected_pages = {}
signal page_collected(page_number, title, command)

func collect_page(page_number: int, title: String, command: String):
	collected_pages[page_number] = {
		"title": title,
		"command": command,
		"collected_at": Time.get_unix_time_from_system()
	}
	page_collected.emit(page_number, title, command)
	
	# Display the page to the player
	show_collected_page(page_number)
	
func show_collected_page(page_number: int):
	if collected_pages.has(page_number):
		var page_data = collected_pages[page_number]
		# Here you would show a UI with the page content
		# For example:
		# get_node("/root/MainScene/UI/TutorialDisplay").show_page(page_data)
		
func get_all_collected_pages():
	return collected_pages

# Add a method to reset all collected pages when player respawns
func reset_collected_pages():
	collected_pages.clear()
	print("[TUTORIAL_MANAGER] Reset all collected pages")
	
	# Notify any listening objects that pages have been reset
	# This can be used by UI to update page counters
	# We emit with default values to indicate a reset occurred
	page_collected.emit(-1, "reset", "reset")
