package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxSubState;

class MainMenuModal extends FlxSubState {
	var _displayText:FlxText;
	var _boundingBox:FlxSprite;
	var _menuWidth:Int = 500;
	var _menuHeight:Int = 600;
	var _confirmCallback:Void->Void;

	public function new(Text:String, ?ConfirmCallback:Void->Void):Void {
		super();

		_confirmCallback = ConfirmCallback;
		_boundingBox = new FlxSprite((FlxG.width / 2) - _menuWidth, (FlxG.height / 2) - _menuHeight);
		_boundingBox.makeGraphic(_menuWidth, _menuHeight, 0xff205ab7);
		add(_boundingBox);

		_displayText = new FlxText(20, 110, 0, Text, 20);
		add(_displayText);
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);

		if (FlxG.keys.anyJustPressed([ESCAPE])) {
			close();
		}

		if (FlxG.keys.anyJustPressed([ENTER])) {
			_confirmCallback();
		}
	}
}
