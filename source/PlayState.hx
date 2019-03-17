package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;

// import flixel.util.FlxColor;
class PlayState extends FlxState {
	var _txtTitle:FlxText;
	var _player:Player;
	var _level:FlxTilemap;

	override public function create():Void {
		FlxG.mouse.visible = false;
		
		bgColor = 0xffc7e4db; // Game background color
		// Test text
		_txtTitle = new FlxText(0, 0, 0, "Test game here", 12);
		_txtTitle.setFormat(null, 12, 0xFF194869);
		_txtTitle.screenCenter();
		// add(_txtTitle);

		// add envirionment
		_level = new FlxTilemap();
		_level.loadMapFromCSV("assets/data/test-res-64.csv", "assets/images/debug2.png", 20, 20);
		add(_level);

		// Add Player
		_player = new Player(10, 10);
		add(_player);

		// Player Camera
		FlxG.camera.follow(_player, PLATFORMER, 1);

		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FlxG.collide(_level, _player);
	}
}
