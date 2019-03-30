package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;
import flixel.util.FlxSpriteUtil;

// import flixel.util.FlxColor;
class PlayState extends FlxState {
	var _txtScore:FlxText;
	var _score:Int = 0;
	var _player:Player;
	var _level:FlxTilemap;
	var _bugs:FlxGroup;
	var _health:FlxSprite;
	var _justDied:Bool = false;
	var _enemy:FlxSprite;

	override public function create():Void {
		FlxG.mouse.visible = false; // Hide the mouse cursor
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
		// @todo change this to array of bugs
		_bugs = new FlxGroup();
		// top left
		createBug(150, 490);
		// middle
		createBug(600, 890);
		// bottom left
		createBug(100, 790);
		createBug(300, 790);
		add(_bugs);

		// Test enemy
		_enemy= new FlxSprite(800, 850).makeGraphic(50, 50, 0xffff0000);
		add(_enemy);		

		/** 
		 * @todo Add `_hud` FlxSpriteGroup
		 */
		// Show score text
		_txtScore = new FlxText(FlxG.width / 2, 40, 0, updateScore());
		_txtScore.setFormat(null, 24, 0xFF194869, FlxTextAlign.CENTER);
		_txtScore.scrollFactor.set(0, 0);
		add(_txtScore);

		// Add Player
		_player = new Player(20, 400);
		add(_player);

		// Hearts
		createHearts();

		// Player Camera
		FlxG.camera.follow(_player, PLATFORMER, 1);

		super.create();
	}

	override public function update(elapsed:Float):Void {
		// Reset the game if the player goes higher than the map
		if (_player.y > _level.height) {
			_justDied = true;
			FlxG.resetState();
		}

		super.update(elapsed);
		// collisions
		FlxG.collide(_player, _level);
		FlxG.overlap(_player, _enemy, hitEnemy);
		FlxG.overlap(_bugs, _player, getBug);
	}

	function createBug(X:Int, Y:Int):Void {
		var bug:FlxSprite = new FlxSprite(X, Y);
		bug.makeGraphic(10, 10, 0xffbf1ebf);
		_bugs.add(bug);
	}

	/**
	 * Std.int converts float to int
	 * @see https://code.haxe.org/category/beginner/numbers-floats-ints.html
	 */
	function createHearts():Void {
		for (i in 0...Std.int(_player.health)) {
			_health = new FlxSprite((i * 80), 30).loadGraphic("assets/images/heart.png", false, 60, 60);
			_health.scrollFactor.set(0, 0);
			add(_health);
		}
	}

	function updateScore():String {
		return "Score:" + _score;
	}

	function getBug(Bug:FlxObject, Player:FlxObject):Void {
		_score++;
		_txtScore.text = updateScore();
		Bug.kill();
	}

	function hitEnemy(Player:FlxObject, Enemy:FlxObject):Void {
		// Remove 1 player health if hit by enemy
		if (Player.alive) {
			js.Browser.console.log("Hit by enemy");
			Player.hurt(1);
			// if facing left
			// Move player after they've been hit
			FlxTween.tween(Player, {x: (Player.x -150), y: (Player.y -20)}, 0.1);
			FlxFlicker.flicker(Player);
			_health.alpha = 0.2;
			createHearts();
			js.Browser.console.log("Health", _health);
			
			js.Browser.console.log("Health", Player.health);
		} else {
			js.Browser.console.log("You Died!!");
			// Player.kill();
		}
	}
	
}
