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

	static var _heightFromBase:Int = 200;

	public function new(Dialogue:Array<String>) {
		super();
		_dialogueArray = Dialogue;
		// Create the box
		_dialogueBox = new FlxSprite(0, FlxG.height - _heightFromBase).makeGraphic(FlxG.width, _heightFromBase, 0xff205ab7);
		add(_dialogueBox);

		// Create the text
		_dialogueBoxText = new FlxText(120, FlxG.height - (_heightFromBase - 20), FlxG.width, _dialogueArray[0]);
		_dialogueBoxText.setFormat(null, 20, FlxColor.WHITE, LEFT);
		add(_dialogueBoxText);

		// TODO Create down arrow
		_pressDown = new FlxText(FlxG.width - 20, FlxG.height - (_heightFromBase - 20), FlxG.width, "Press down");
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
		if (FlxG.keys.anyJustPressed([SPACE])) {
			_dialogueBoxText.text = _dialogueArray[1];
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
}
