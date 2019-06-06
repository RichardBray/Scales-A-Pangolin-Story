package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxSubState;

class MainMenuModal extends FlxSubState {
	var _displayText:FlxText;
	var _boundingBox:FlxSprite;
	var _menuWidth:Int = 500;
	var _menuHeight:Int = 500;
	var _optionsText:FlxText;
	var _confirmCallback:Void->Void;

	public function new(Text:String, ?ConfirmCallback:Void->Void, ShowOptions:Bool = false):Void {
		super();

		_confirmCallback = ConfirmCallback;
		_boundingBox = new FlxSprite((FlxG.width / 2) - (_menuWidth / 2), (FlxG.height / 2) - (_menuHeight / 2));
		_boundingBox.makeGraphic(_menuWidth, _menuHeight, 0xff205ab7);
		add(_boundingBox);

		_displayText = new FlxText(20, 250, 450, Text, 20);
		_displayText.screenCenter(X);
		add(_displayText);

		if (ShowOptions) {
			_optionsText = new FlxText(20, 350, 450, "Press ENTER for yes", 20);
			_optionsText.screenCenter(X);
			add(_optionsText);
		}
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);

		if (FlxG.keys.anyJustPressed([ESCAPE])) {
			close();
		}

		if (FlxG.keys.anyJustPressed([ENTER])) {
			if (_confirmCallback != null)
				_confirmCallback();
		}
	}
}
