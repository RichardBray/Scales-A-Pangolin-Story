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

	static var _heightFromBase:Int = 200;

	public function new(Dialogue:Array<String>, ParentState:PlayState) {
		super();
		_dialogueArray = Dialogue;
		_parentState = ParentState;
		// Create the box
		_dialogueBox = new FlxSprite(0, FlxG.height - _heightFromBase).makeGraphic(FlxG.width, _heightFromBase, 0xff205ab7);
		add(_dialogueBox);

		// Create the text
		_dialogueBoxText = new FlxText(120, FlxG.height - (_heightFromBase - 20), FlxG.width, _dialogueArray[_arrTextNum]);
		_dialogueBoxText.setFormat(null, 20, FlxColor.WHITE, LEFT);
		add(_dialogueBoxText);

		// TODO Create down arrow
		_pressDown = new FlxText(FlxG.width - 20, FlxG.height - (_heightFromBase - 20), FlxG.width, "Press SPACE to skip");
		_pressDown.setFormat(null, 20, FlxColor.WHITE, LEFT);
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
