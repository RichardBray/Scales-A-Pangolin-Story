package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxObject;

class NPC extends FlxTypedGroup<FlxTypedGroup<FlxSprite>> {
	var _dialogueBox:DialogueBox;
	var _parentState:GameLevel;
    var _dialogueText:Array<String>;
    var _xPos:Int;
    var _yPos:Int;

	public var dialoguePrompt:DialoguePrompt;    

    /**
     * Create an NPC
     *
     * @param X
     * @param Y
     * @param DialogueText
	 * @param ParentState	Used to adjust vieport and stop player when dialogue starts.
     */
    public function new(X:Int, Y:Int, ?DialogueText:Null<Array<String>>, ParentState:GameLevel):Void {
        super();
        _dialogueText = DialogueText;
		_parentState = ParentState;

		var _npcSprite = new NpcSprite(X, Y);
		add(_npcSprite);

		// Friend Dialogue Bubble
		dialoguePrompt = new DialoguePrompt(120, 820 + (150 / 2), 390, "Press Z");
		add(dialoguePrompt);

		_dialogueBox = new DialogueBox(_dialogueText, ParentState);
		add(_dialogueBox);
		// NPC end        		
    }

	public function initConvo(Player:Player, Friend:FlxSprite):Void {
		if (Player.isTouching(FlxObject.FLOOR)) {
			if (!_parentState.actionPressed) {
				// show press e prompt
				dialoguePrompt.showPrompt();
			}

			if (FlxG.keys.anyPressed([Z])) {
				_parentState.actionPressed = true;
				if (!_parentState.startingConvo) {
					// hide dialogue bubble
					dialoguePrompt.hidePrompt(true);
					// zoom camera
					FlxTween.tween(FlxG.camera, {zoom: 1.1}, 0.2, {
						onComplete: (_) -> {
							_parentState.startingConvo = true;
							// show dialogue box
							_dialogueBox.showBox();
						}
					});
					// prevent character movement
					Player.preventMovement = true;

					// hide HUD
					_parentState.grpHud.toggleHUD(0);
				} else {
					// unzoom camera
					FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {
						onComplete: (_) -> _parentState.startingConvo = false
					});
					// hide dialogue box
					_dialogueBox.hideBox();

					// allow character movement
					Player.preventMovement = false;
					// show HUD
					_parentState.grpHud.toggleHUD(1);
				}
			}
		}
		
	}  
}

class NpcSprite extends FlxTypedGroup<FlxSprite> {
	var _npcBoundary:FlxSprite;
	var _actualNPC:FlxSprite; 

	public function new(X:Int, Y:Int):Void {
		super();
		// NPC start
		_npcBoundary = new FlxSprite((X - 50), Y).makeGraphic(150, 50, FlxColor.TRANSPARENT);
		add(_npcBoundary);
		_actualNPC = new FlxSprite(X, Y).makeGraphic(50, 50, 0xff205ab7);
		add(_actualNPC);			
	}
}  