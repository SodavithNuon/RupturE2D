extends Node
var active_npc = null
var is_dialogue_active := false
var zombie_kills := 0
var kills_required := 5
var elapsed_time := 0.0
var time_display := "00:00"

signal kill_count_changed(current: int, required: int)
signal quest_complete()
signal time_updated(time_string: String)
