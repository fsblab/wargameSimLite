extends Node

#PlayerInfoScript -> SkirmishMenuScript
signal abortStartOfMatch
#SkirmishMenu -> ServerScript
signal dcplayer
#SkirmishMenu -> ServerScript
signal sc(msg: String)
signal scas(msg: String)


func disconnectPlayer() -> void:
	dcplayer.emit()


func readySetFalse() -> void:
	abortStartOfMatch.emit()


func sendChat(msg: String) -> void:
	sc.emit(msg)


func sendChatAsServer(msg: String) -> void:
	scas.emit(msg)
