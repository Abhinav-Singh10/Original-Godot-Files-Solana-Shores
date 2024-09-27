extends Node2D

@onready var _fade: ColorRect=$Control/CanvasLayer/Fade


@export_category("CandyMachine Info")
@export var early_CM_id :String 
@export var allCoins_CM_id :String 
@export var completion_CM_id :String 
@export var SpeedRun_CM_id :String 
@export var pacifist_CM_id :String 
@export var brawler_CM_id :String 

@onready var cm_owner_path:String = "res://TempWallet/CandyMachineOwner.json"
@onready var early_panel: PanelContainer= $Control/CanvasLayer/VBoxContainer/HBoxContainer/EarlyPanel
@onready var coin_panel: PanelContainer= $Control/CanvasLayer/VBoxContainer/HBoxContainer/AllCoinsPanel
@onready var complete_panel: PanelContainer= $Control/CanvasLayer/VBoxContainer/HBoxContainer/CompelitonPanel
@onready var speed_panel: PanelContainer= $Control/CanvasLayer/VBoxContainer/HBoxContainer2/Speedpanel
@onready var pacifist_panel: PanelContainer= $Control/CanvasLayer/VBoxContainer/HBoxContainer2/PacifistPanel
@onready var brawler_panel: PanelContainer= $Control/CanvasLayer/VBoxContainer/HBoxContainer2/BrawlerPanel

var coins_collected: int = File.data.coins
var diamonds_count: int= File.data.diamonds
var potions_drank:int= File.data.potion
var skulls_picked: int= File.data.skull
var keys_collected: int= File.data.key
var time_elapsed:int =File.data.time_passed

var coin_progress: bool
var speed_progress:bool
var completion_progress: bool
#
var cm_data:CandyMachineData

func _ready() -> void:	
	_fade.visible= true
	_fade.fade_to_clear()
	early_panel.visible=true
	if coins_collected ==99:
		coin_panel.visible=true
		coin_progress=true
		if diamonds_count==3 && skulls_picked ==1 && keys_collected==2:
			complete_panel.visible=true
			completion_progress=true
	if time_elapsed <=30:
		speed_panel.visible=true
	if coin_progress:
		coin_panel.visible=true
	if speed_progress:
		speed_panel.visible=true
	if completion_progress:
		complete_panel.visible=true


func _on_return_pressed() -> void:
	_fade.fade_to_black()
	get_tree().change_scene_to_file("res://Scenes/game_finish.tscn")

func _on_early_button_pressed() -> void:
	mint_frm_cm(early_CM_id)
	
	
func mint_frm_cm (cm_id:String):
	cm_data = await SolanaService.candy_machine_manager.fetch_candy_machine(Pubkey.new_from_string(cm_id))
	
	var tx_data: TransactionData
	
	#if !(SolanaService.wallet.get_kp() is WalletAdapter):
		#var reciever:Keypair = SolanaService.wallet.get_kp();
	#else:
	
	var reciver: WalletAdapter= SolanaService.wallet.get_kp()
	print("Reciver")
	#print(reciever)
	SolanaService.wallet.change_custom_path(cm_owner_path)
	SolanaService.wallet.try_login()
	print("After login new Keypair")
	print(SolanaService.wallet.get_kp())
		
	print(Pubkey.new_from_string(cm_id))
	tx_data= await SolanaService.candy_machine_manager.mint_nft(
			Pubkey.new_from_string(cm_id),
			cm_data,
			SolanaService.wallet,
			reciver,
		)
	if !tx_data.is_successful():
		print("Transaction Failed")
		return
	else:
		SolanaService.wallet.reset_after_transaction()
		SolanaService.wallet.try_login()

func _on_coin_button_pressed() -> void:
	mint_frm_cm(allCoins_CM_id)


func _on_completion_button_pressed() -> void:
	mint_frm_cm(completion_CM_id)



func _on_speed_button_pressed() -> void:
	mint_frm_cm(SpeedRun_CM_id)
