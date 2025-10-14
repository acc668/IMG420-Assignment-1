extends Node

var final_score: int = 0
var high_score: int = 0
var total_games_played: int = 0
var sfx_volume: float = 1.0
var music_volume: float = 0.7

func set_final_score(score: int):
	final_score = score

	if score > high_score:
		high_score = score
		save_high_score()

func get_final_score() -> int:
	return final_score

func get_high_score() -> int:
	return high_score

func increment_games_played():
	total_games_played += 1

func save_high_score():
	var save_file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
	
    if save_file:
		save_file.store_var(high_score)
		save_file.store_var(total_games_played)
		save_file.close()

func load_high_score():
	if FileAccess.file_exists("user://savegame.dat"):
		
        var save_file = FileAccess.open("user://savegame.dat", FileAccess.READ)
		
        if save_file:
			high_score = save_file.get_var()
			total_games_played = save_file.get_var()
			save_file.close()

func _ready():
	load_high_score()