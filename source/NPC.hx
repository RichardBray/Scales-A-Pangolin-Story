package;

import Controls;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxObject;

class NPC extends FlxTypedGroup<FlxTypedGroup<FlxSprite>> {
	var _dialogueBox:DialogueBox;
	var _parentState:LevelState;
	var _controls:Controls;

	public var dialoguePrompt:DialoguePrompt; // Used to hide and show prompt in levels.
	public var npcSprite: NpcSprite; // Used to get boundaries for collision.

    /**
     * Create an NPC
     * --
     * @param X				X posiiton in the level.
     * @param Y				Y position in the level.
     * @param DialogueText	Text for the NPC.
		 * @param SpriteData	Sprite image unique to this NPC.
		 * @param ParentState	Used to adjust vieport and stop player when dialogue starts.
     */
    public function new(
			X:Int, 
			Y:Int, 
			?DialogueText:Null<Array<String>>, 
			SpriteData:FlxSprite, 
			ParentState:LevelState
	) {
		super();
		_parentState = ParentState;
		// Init controls

		npcSprite = new NpcSprite(X, Y, SpriteData);
		add(npcSprite);

		dialoguePrompt = new DialoguePrompt(
			null, 
			X, 
			(Y - 350),  // 350 = magic number
			"Press E"
		);
		add(dialoguePrompt);

		_dialogueBox = new DialogueBox(DialogueText, ParentState);
		add(_dialogueBox);

		// Intialise controls
		_controls = new Controls();
    }

	public function initConvo(Player:Player, Friend:FlxSprite) {
		if (Player.isTouching(FlxObject.FLOOR)) {
			if (!_parentState.actionPressed) dialoguePrompt.showPrompt();

			if (_controls.triangle.check()) {
				_parentState.actionPressed = true;

				if (!_parentState.startingConvo) {
					dialoguePrompt.hidePrompt(true); // hide dialogue bubble
					// zoom camera
					FlxTween.tween(FlxG.camera, {zoom: 1.1}, 0.2, {
						onComplete: (_) -> {
							_parentState.startingConvo = true;
							_dialogueBox.showBox(); // show dialogue box
						}
					});
					Player.preventMovement = true; // prevent character movement
					_parentState.grpHud.toggleHUD(0); // hide HUD
				} else {
					// unzoom camera
					FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {
						onComplete: (_) -> _parentState.startingConvo = false
					});
					_dialogueBox.hideBox(); // hide dialogue box
					Player.preventMovement = false; // allow character movement
					_parentState.grpHud.toggleHUD(1); // show HUD
				}
			}
		} 
	}  
}

class NpcSprite extends FlxTypedGroup<FlxSprite> {

	public var npcBoundary:FlxSprite; // Used to get boundaries for collision.

	/**
	 * This creates the NPC sprite with it's boundary
	 *
	 * @param X	X position of the NPC sprite on the map.
	 * @param Y	Y position of the NPC sprite on the map.
	 */
	public function new(X:Int, Y:Int, SpriteData:FlxSprite) {
		super();	
	
		add(SpriteData);

		npcBoundary = new FlxSprite(
			(X - SpriteData.width), Y).makeGraphic(
			Std.int(SpriteData.width * 3), 
			Std.int(SpriteData.height * 3), 
			FlxColor.TRANSPARENT
		);
		add(npcBoundary);
	}
}  