package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.addons.display.shapes.FlxShapeBox;

class DialogueBox extends FlxTypedGroup<FlxSprite> {
	var _dialogueBox:FlxShapeBox;
	var _dialogueBoxText:FlxText;
	var _pressDown:FlxText;
	var _dialogueArray:Array<String>;
	var _arrTextNum:Int = 0;
	var _parentState:LevelState;
	var _primaryText:FlxTextFormat;
	var _controls:Controls;

	static var _heightFromBase:Int = 340;

	/**
	 * Dialogue Box constructor
	 *
	 * @param Dialogue 		Text that the NPC/Player will give.
	 * @param ParentState	The parent state of the dialoge, needed to hide the HUD and prevent Player movement.
	 */
	public function new(Dialogue:Array<String>, ParentState:LevelState) {
		super();

		// Assign these to variables to use in other methods
		_dialogueArray = Dialogue;
		_parentState = ParentState;

		// Markup styles for text
		_primaryText = new FlxTextFormat(Constants.secondaryColor, false, false, null);

		// Create the box
		var spacingWidth:Int = 150;
		var spacingHeight:Int = 55;

		_dialogueBox = new FlxShapeBox(
			spacingWidth,
			FlxG.height - (_heightFromBase + spacingHeight),
			FlxG.width - (spacingWidth * 2),
			_heightFromBase - spacingHeight,
			{ thickness:8, color:Constants.primaryColorLight }, 
			Constants.primaryColor			
		);		
		add(_dialogueBox);

		// Create the text
		_dialogueBoxText = new FlxText(
			spacingWidth + 20, 
			FlxG.height - (_heightFromBase - 100), 
			FlxG.width - (spacingWidth * 2), 
			_dialogueArray[_arrTextNum]
		);
		_dialogueBoxText.setFormat(Constants.squareFont, Constants.medFont, FlxColor.WHITE, LEFT);

		add(_dialogueBoxText);

		// TODO Create down arrow
		_pressDown = new FlxText(
			FlxG.width - 350, 
			FlxG.height - 140, 
			FlxG.width - 400, 
			"Press SPACE to skip"
		);
		_pressDown.setFormat(Constants.squareFont, Constants.smlFont, FlxColor.WHITE, LEFT);
		add(_pressDown);

		// Hide and fix the members to the screen
		this.forEach((_member:FlxSprite) -> {
			_member.alpha = 0;
			_member.scrollFactor.set(0, 0);
		});
		this.visible = false;

		// Intialise controls
		_controls = new Controls();		
	}

	public function showBox() {
		this.visible = true;
		this.forEach((_member:FlxSprite) -> {
			FlxTween.tween(_member, {alpha: 1}, .1);
		});
	}

	public function hideBox() {
		this.visible = false;
		this.forEach((_member:FlxSprite) -> {
			_member.alpha = 0;
		});
	}

	function revertUI() {
		this.hideBox();
		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {
			onComplete: (_) -> {
				_parentState.startingConvo = false;
				_parentState.player.preventMovement = false;
				_parentState.grpHud.toggleHUD(1);
			}
		});
	}

	override public function update(Elapsed:Float) {
		// Press jump button to move to next bit of text
		if (visible && _controls.cross.check()) {
			// This is used to keep running the `revertUI` method on the last array number.
			_arrTextNum == _dialogueArray.length ? _arrTextNum : _arrTextNum++;

			if (_arrTextNum == _dialogueArray.length) {
				this.revertUI();
			} else {
				_dialogueBoxText.text = _dialogueArray[_arrTextNum];
				_dialogueBoxText.applyMarkup(_dialogueArray[_arrTextNum], [new FlxTextFormatMarkerPair(_primaryText, "<pt>")]);
			}
		}

		super.update(Elapsed);
	}	
}
