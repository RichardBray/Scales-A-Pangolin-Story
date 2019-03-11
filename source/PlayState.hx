package;

import flixel.FlxState;
import flixel.text.FlxText;

// import flixel.util.FlxColor;
class PlayState extends FlxState {
	var _txtTitle:FlxText;
	var _player:Player;

	override public function create():Void {
		bgColor = 0xffc7e4db; // Game background color
		// Test text
		_txtTitle = new FlxText(0, 0, 0, "Test game here", 12);
		_txtTitle.setFormat(null, 12, 0xFF194869);
		_txtTitle.screenCenter();
		add(_txtTitle);

		// Add Player
		_player = new Player(10,10);
		add(_player);
		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}
