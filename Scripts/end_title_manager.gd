extends Node2D

@onready var _fade : ColorRect =$CanvasLayer/Fade
@onready var _collect_sol_btn: Button =$"CanvasLayer/Menu/Buttons Menu/Wood/VBoxContainer/Collect Sol Button/Collect Sol"
@onready var _label: Label = $CanvasLayer/Label
@onready var _collect_sol_label: HBoxContainer= $"CanvasLayer/Menu/Buttons Menu/Wood/VBoxContainer/Collect Sol Button/Collect Sol Label"
@onready var _claimed_sol_label: HBoxContainer=$"CanvasLayer/Menu/Buttons Menu/Wood/VBoxContainer/Collect Sol Button/Claimed Sol Label"
@export var vault_wallet_Path: String
@onready var cm_owner_path:String = "res://TempWallet/CandyMachineOwner.json"
@export var wallet_adapter_ui:WalletAdapterUI

func _ready() -> void:
	_fade.visible= true
	_fade.fade_to_clear()
	SolanaService.wallet.on_login_begin.connect(pop_adapter)	
	SolanaService.wallet.on_login_finish.connect(confirm_login)	
	
	wallet_adapter_ui.visible=false
	wallet_adapter_ui.on_provider_selected.connect(process_adapter_result)
	wallet_adapter_ui.on_adapter_cancel.connect(cancel_login)

func _on_new_game_pressed() -> void:
	File.new_game()
	await _fade.fade_to_black()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_collect_sol_pressed() -> void:
	_collect_sol_btn.disabled=true
	
	#var reciever:String = SolanaService.wallet.get_pubkey().to_string()
	#print("Reciver Address")
	#print(reciever)
	
	##################
	
	var reciever: String= SolanaService.wallet.get_pubkey().to_string()
	print("Reciver")
	print(reciever)
	#print(reciever.get_connected_key())
	#print("                   ")
	
	SolanaService.wallet.change_custom_path(cm_owner_path)
	SolanaService.wallet.try_login()
	
	#####################
	var prize_amount: float= float(File.data.coins)/100
	
	var tx_data :TransactionData= await SolanaService.transaction_manager.transfer_sol(reciever,prize_amount)
	#var tx_id: String= tx_data.to_string()
	print("TX_data : %s", tx_data)
	if tx_data.is_successful():
		_collect_sol_label.visible=false
		_claimed_sol_label.visible=true
		_label.text= "You earned %s Sols Check your wallet Buddy :) " % str(float(File.data.coins)/100)
		relogin()
	else:
		_label.text="transaction failed"
		_collect_sol_btn.disabled=false
		
		
func relogin()->void:
		SolanaService.wallet.reset_after_transaction()
		wallet_adapter_ui.visible=true
		SolanaService.wallet.try_login()

func _on_mint_nft_button_pressed() -> void:
	await _fade.fade_to_black()
	get_tree().change_scene_to_file("res://Scenes/nft_minting_menu.tscn")

func pop_adapter()-> void:
	wallet_adapter_ui.setup(SolanaService.wallet.wallet_adapter.get_available_wallets())
	
func process_adapter_result(provider_id:int) -> void:
	SolanaService.wallet.login_adapter(provider_id)

func cancel_login()-> void:
	print("Login Cancelled")
	
func confirm_login(login_success:bool) -> void:
	if login_success:
		pass
		
