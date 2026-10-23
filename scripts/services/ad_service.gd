extends Node

signal rewarded_granted(amount: int)
signal ad_closed

var _mock_success := true

func show_rewarded(amount: int) -> void:
    PauseManager.add_reason("ad")
    # Mock: grant after short delay.
    await get_tree().create_timer(0.5, true, false, true).timeout
    if _mock_success:
        rewarded_granted.emit(amount)
    PauseManager.remove_reason("ad")
    ad_closed.emit()

func show_interstitial() -> void:
    PauseManager.add_reason("ad")
    await get_tree().create_timer(0.5, true, false, true).timeout
    PauseManager.remove_reason("ad")