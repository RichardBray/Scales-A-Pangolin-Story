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

		/**
		* By default flixel only processes what it initally sees, so collisions won't 
		* work unit it can process the whole level.
		*/
		FlxG.worldBounds.set(0, 0, _level.width, _level.height); 
		FlxG.camera.setScrollBoundsRect(0, 0, _level.width, _level.height); 

		// Add Player
		_player = new Player(20, 460);
		add(_player);

		// Player Camera
		FlxG.camera.follow(_player, PLATFORMER, 1);

		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FlxG.collide(_player, _level);
	}
}
