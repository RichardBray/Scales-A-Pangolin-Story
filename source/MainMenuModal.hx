package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxSubState;

class MainMenuModal extends FlxSubState {
	var _displayText:FlxText;
	var _boundingBox:FlxSprite;

	public function new(Text:String) {
		super();
		_displayText = new FlxText(20, 110, 0, Text, 20);
		add(_displayText);
	}
}
