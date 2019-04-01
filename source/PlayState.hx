package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;
import flixel.group.FlxSpriteGroup;
// Imports for map
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;
// - addons
import flixel.addons.editors.tiled.TiledMap; // Ignore the error VScode gives here
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;

// import flixel.util.FlxColor;
class PlayState extends FlxState {
	var _txtScore:FlxText;
	var _score:Int = 0;
	var _player:Player;
	var _level:FlxTilemap;
	var _bugs:FlxGroup;
	var _health:FlxSprite;
	var _hearts:FlxSpriteGroup;
	var _justDied:Bool = false;
	var _enemy:FlxSprite;
	var _map:TiledMap;
	var _mapImages:TiledObjectLayer;

	override public function create():Void {
		FlxG.mouse.visible = true; // Hide the mouse cursor
		bgColor = 0xffc7e4db; // Game background color

		// add envirionment
		_level = new FlxTilemap();
		_map = new TiledMap("assets/data/test-level-1.tmx");
		_level.loadMapFromArray(cast(_map.getLayer("ground"), TiledTileLayer).tileArray, _map.width, _map.height, "assets/images/ground-map.png",
			_map.tileWidth, _map.tileHeight, FlxTilemapAutoTiling.OFF, 1);
		_level.follow(); // lock camera to map's edges
		_level.setTileProperties(1, FlxObject.ANY);
		// _level.setTileProperties(2, FlxObject.ANY);
		_mapImages = cast _map.getLayer("rocks");
		for (e in _mapImages.objects) {
			js.Browser.console.log(e, 'rocky');
			placeEntities(e.type, e.xmlData.x);
		}
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
		_enemy = new FlxSprite(800, 850).makeGraphic(50, 50, 0xffff0000);
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
		_hearts = new FlxSpriteGroup();
		_hearts.scrollFactor.set(0, 0);
		createHearts();
		add(_hearts);

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
			_hearts.add(_health);
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
		var index:Int = 0;
		// Remove 1 player health if hit by enemy
		if (Player.alive) {
			js.Browser.console.log("Hit by enemy");
			Player.hurt(1);
			// if facing left
			// Move player after they've been hit
			FlxTween.tween(Player, {x: (Player.x - 150), y: (Player.y - 20)}, 0.1);
			FlxFlicker.flicker(Player);
			_hearts.forEach((s:FlxSprite) -> {
				if (index == Player.health) {
					s.alpha = 0.2;
				}
				index++;
			});
		} else {
			js.Browser.console.log("You Died!!");
			// Player.kill();
		}
	}

	function placeEntities(entityName:String, entityData:Xml):Void {
		js.Browser.console.log(entityName);
		var x:Int = Std.parseInt(entityData.get("x")); // Parse string to int
		var y:Int = Std.parseInt(entityData.get("y"));
	}

	function createRock(X:Int, Y:Int, width:Int, height:Int):Void {
		// _health = new FlxSprite(X, Y).loadGraphic("assets/images/rock-1.png", false, width, height);
	}
}
