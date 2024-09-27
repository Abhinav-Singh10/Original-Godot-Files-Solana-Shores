extends Node2D 

@export var _game_scene:PackedScene
@onready var path_to_scene:String= "res://Scenes/game.tscn"

@onready var _fade : ColorRect =$CanvasLayer/Fade
@export var wallet_adapter_ui:WalletAdapterUI

func _on_connect_wallet_pressed() -> void:
	print("Connect Wallet pressed!")
	wallet_adapter_ui.visible=true
	SolanaService.wallet.try_login()

func _ready() -> void:
	_fade.visible= true
	_fade.fade_to_clear()
	SolanaService.wallet.connect("on_login_finish",load_game)
	wallet_adapter_ui.visible=false
	SolanaService.wallet.on_login_begin.connect(pop_adapter)	
	SolanaService.wallet.on_login_finish.connect(confirm_login)	
	
	wallet_adapter_ui.on_provider_selected.connect(process_adapter_result)
	wallet_adapter_ui.on_adapter_cancel.connect(cancel_login)

func load_game( sucess :bool ) -> void:
	if sucess:
		print("Wallet connected sucessfully");
		File.new_game()
		await _fade.fade_to_black()
		get_tree().change_scene_to_packed(_game_scene)
	else:
		print(sucess)
		print("Wallet connection Failed")
		
	
func pop_adapter()-> void:
	wallet_adapter_ui.setup(SolanaService.wallet.wallet_adapter.get_available_wallets())
	
func process_adapter_result(provider_id:int) -> void:
	SolanaService.wallet.login_adapter(provider_id)

func cancel_login()-> void:
	print("Login Cancelled")
	
func confirm_login(login_success:bool) -> void:
	if login_success:
		get_tree().change_scene_to_packed(_game_scene)
