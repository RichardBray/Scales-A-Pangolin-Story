package;

// - Flixel
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class MainMenu extends FlxState {
	var _gameTitle:FlxText;

	override public function create():Void {
		_gameTitle = new FlxText(10, 90, 300, "Pangolin Panic");
		_gameTitle.setFormat(null, 16, FlxColor.WHITE, CENTER);
		add(_gameTitle);
	}
}
