package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class DialogueBox extends FlxTypedGroup<FlxSprite> {
	var _dialogueBox:FlxSprite;
	var _dialogueBoxText:FlxText;
	var _pressDown:FlxText;
	var _dialogueArray:Array<String>;
	var _arrTextNum:Int = 0;
	var _parentState:PlayState;
	var _primaryText:FlxTextFormat;

	static var _heightFromBase:Int = 200;

	/**
	 * Dialogue Box constructor
	 *
	 * @param Dialogue 		Text that the NPC/Player will give.
	 * @param ParentState	The parent state of the dialoge, needed to hide the HUD and prevent Player movement.
	 */
	public function new(Dialogue:Array<String>, ParentState:PlayState) {
		super();

		// Assign these to variables to use in other methods
		_dialogueArray = Dialogue;
		_parentState = ParentState;

		// Markup styles for text
		_primaryText = new FlxTextFormat(0xffdc2de4, false, false, null);

		// Create the box
		_dialogueBox = new FlxSprite(0, FlxG.height - _heightFromBase).makeGraphic(FlxG.width, _heightFromBase, 0xff205ab7);
		add(_dialogueBox);

		// Create the text
		_dialogueBoxText = new FlxText(120, FlxG.height - (_heightFromBase - 20), FlxG.width - 200, _dialogueArray[_arrTextNum]);
		_dialogueBoxText.setFormat(null, 20, FlxColor.WHITE, LEFT);

		add(_dialogueBoxText);

		// TODO Create down arrow
		_pressDown = new FlxText(FlxG.width - 350, FlxG.height - (_heightFromBase - 130), FlxG.width - 400, "Press SPACE to skip");
		_pressDown.setFormat(null, 16, FlxColor.WHITE, LEFT);
		add(_pressDown);

		// Hide and fix the members to the screen
		this.forEach((_member:FlxSprite) -> {
			_member.alpha = 0;
			_member.scrollFactor.set(0, 0);
		});
		this.visible = false;
	}

	override public function update(elapsed:Float):Void {
		// Press down to move to next bit of text
		if (visible && FlxG.keys.anyJustPressed([SPACE])) {
			// This is used to keep running the `revertUI` method on the last array number.
			_arrTextNum == _dialogueArray.length ? _arrTextNum : _arrTextNum++;

			if (_arrTextNum == _dialogueArray.length) {
				this.revertUI();
			} else {
				_dialogueBoxText.text = _dialogueArray[_arrTextNum];
				_dialogueBoxText.applyMarkup(_dialogueArray[_arrTextNum], [new FlxTextFormatMarkerPair(_primaryText, "<pt>")]);
			}
		}

		super.update(elapsed);
	}

	public function showBox():Void {
		this.visible = true;
		this.forEach((_member:FlxSprite) -> {
			FlxTween.tween(_member, {alpha: 1}, .1);
		});
	}

	public function hideBox():Void {
		this.visible = false;
		this.forEach((_member:FlxSprite) -> {
			_member.alpha = 0;
		});
	}

	function revertUI():Void {
		this.hideBox();
		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {
			onComplete: (_) -> {
				_parentState.startingConvo = false;
				_parentState.player.preventMovement = false;
				_parentState.grpHud.toggleHUD(1);
			}
		});
	}
}
