extends Resource
class_name QuestionData

# Tambahkan TRUE_FALSE ke dalam opsi
enum GameType { DRAG_AND_DROP, TEXT_INPUT, TRUE_FALSE }

@export var game_type: GameType = GameType.DRAG_AND_DROP

@export_multiline var question_text: String 
@export var options: Array[String]
@export var correct_answers: Array[String]
