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
	var _txtScore:FlxText;
	var _score:Int = 0;
	var _player:Player;
	var _level:FlxTilemap;
	var _bugs:FlxGroup;

	override public function create():Void {
		FlxG.mouse.visible = false;
		bgColor = 0xffc7e4db; // Game background color

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
		// top left
		createBug(150, 490);
		// middle
		createBug(600, 890);
		// bottom left
		createBug(100, 790);
		createBug(300, 790);
		add(_bugs);

		// Show score text
		_txtScore = new FlxText(FlxG.width / 2, 40, 0, updateScore());
		_txtScore.setFormat(null, 24, 0xFF194869, FlxTextAlign.CENTER);
		_txtScore.scrollFactor.set(0, 0);
		add(_txtScore);
		// Add Player
		_player = new Player(20, 400);
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

	function createBug(X:Int, Y:Int):Void {
		var bug:FlxSprite = new FlxSprite(X, Y);
		bug.makeGraphic(10, 10, 0xffbf1ebf);
		_bugs.add(bug);
	}

	function updateScore():String {
		return "Score:" + _score;
	}

	function getBug(Bug:FlxObject, Player:FlxObject):Void {
		_score++;
		_txtScore.text = updateScore();
		Bug.kill();
	}
}
