package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;

// import flixel.util.FlxColor;
class PlayState extends FlxState {
	var _txtTitle:FlxText;
	var _player:Player;
	var _level:FlxTilemap;
	var _bugs:FlxGroup;

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

		// Add bugs
		_bugs = new FlxGroup();	
		createBug(20, 460);
		add(_bugs);

		// Add Player
		_player = new Player(20, 460);
		add(_player);

		// Player Camera
		FlxG.camera.follow(_player, PLATFORMER, 1);

		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// collisions
		FlxG.collide(_player, _level);
		FlxG.overlap(_bugs, _player, getBug);
	}

	function createBug(X:Int,Y:Int):Void
	{
		var bug:FlxSprite = new FlxSprite(X * 8 + 3, Y * 8 + 2);
		bug.makeGraphic(2, 4, 0xffffff00);
		_bugs.add(bug);
	}

	function getBug(Bug:FlxObject, Player:FlxObject):Void {
		Bug.kill();
	}

}
