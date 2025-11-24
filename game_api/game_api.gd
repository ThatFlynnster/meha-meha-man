extends Node

enum Player {
	EVENT_PLAYER,
	ATTACKER,
	VICTIM,
	HEALER,
	HEALEE,
}

enum WaitBehavior {
	IGNORE_CONDITION,
	ABORT_WHEN_FALSE,
	RESTART_WHEN_TRUE,
}

# User-facing names
const EVENT_PLAYER = Player.EVENT_PLAYER
const IGNORE_CONDITION = WaitBehavior.IGNORE_CONDITION
const ABORT_WHEN_FALSE = WaitBehavior.ABORT_WHEN_FALSE
const RESTART_WHEN_TRUE = WaitBehavior.RESTART_WHEN_TRUE

func get_constants_to_inject() -> Dictionary:
	return {
		"EVENT_PLAYER": EVENT_PLAYER,
		"IGNORE_CONDITION": IGNORE_CONDITION,
		"ABORT_WHEN_FALSE": ABORT_WHEN_FALSE,
		"RESTART_WHEN_TRUE": RESTART_WHEN_TRUE,
		# Add any other global constants here, e.g.:
		# "TEAM_1": 1,
		# "TEAM_2": 2,
	}

# --- 3. Main 'wait' Function ---

# This is the function the user will call as 'api.wait(...)'
#func wait(seconds: float, condition: Callable = Callable(), behavior: int = IGNORE_CONDITION) -> Signal:
	#return
	#if behavior == IGNORE_CONDITION or not condition.is_valid():
		#return get_tree().create_timer(seconds).timeout
	
	## --- Complex Wait ---
	## For abort/restart logic, we need a frame-by-frame check.
	## We instance our inner class to handle this.
	#var waiter = CustomWaiter.new()
	#
	## Configure the waiter with the user's parameters
	#waiter.setup(seconds, condition, behavior)
	#
	## Add to the tree to start its _process loop
	#add_child(waiter)
	#
	## The user's script 'await's this signal.
	## The waiter will emit it when done or aborted,
	## and then free itself.
	#return waiter.wait_finished
	
#func wait(seconds: float) -> Signal:
	#return get_tree().create_timer(seconds).timeout

func get_player_health(player_id: int) -> float:
	#var player = YourPlayerManager.get_player(player_id)
	var player
	if player:
		return player.health
	return 0.0

func set_player_health(player_id: int, health: float) -> void:
	return
