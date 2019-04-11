package;

import openfl.utils.Dictionary;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSpriteUtil;
// Imports for map
// - Tiled
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
// - Flixel
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;
import flixel.addons.tile.FlxTilemapExt;

// import flixel.util.FlxColor;
class PlayState extends FlxState {
	var _txtScore:FlxText;
	var _score:Int = 0;
	var _player:Player;
	var _bugs:FlxGroup;
	var _justDied:Bool = false;
	var _enemy:FlxSprite;
	// Vars for health
	var _health:FlxSprite;
	var _hearts:FlxSpriteGroup;
	// Vars for map
	var _level:FlxTilemap;
	var _levelCollisions:FlxTilemapExt;
	var _map:TiledMap;
	var _mapObjects:TiledObjectLayer;
	var _mapTrees:TiledObjectLayer;
	var _mapEntities:FlxSpriteGroup;

	override public function create():Void {
		FlxG.mouse.visible = true; // Hide the mouse cursor
		bgColor = 0xffc7e4db; // Game background color

		// Map objects initiated here.
		_mapEntities = new FlxSpriteGroup();

		// Add envirionment collisions
		_levelCollisions = new FlxTilemapExt();
		_map = new TiledMap("assets/data/level-1-2.tmx");
		_levelCollisions.loadMapFromArray(cast(_map.getLayer("collisions"), TiledTileLayer).tileArray, _map.width, _map.height,
			"assets/images/ground-collisions.png", _map.tileWidth, _map.tileHeight, FlxTilemapAutoTiling.OFF, 1);
		// _levelCollisions.follow(); // lock camera to map's edges
		// set slopes
		_levelCollisions.setSlopes([9, 10]);
		_levelCollisions.setGentle([10], [9]);

		// set cloud/special tiles
		_levelCollisions.setTileProperties(4, FlxObject.ANY, fallInClouds);

		add(_levelCollisions);

		// Add bugs group
		_bugs = new FlxGroup();

		// Add envirionment
		_level = new FlxTilemap();
		_level.loadMapFromArray(cast(_map.getLayer("ground"), TiledTileLayer).tileArray, _map.width, _map.height, "assets/images/ground-collisions.png",
			_map.tileWidth, _map.tileHeight, FlxTilemapAutoTiling.OFF, 1);
		_mapObjects = cast _map.getLayer("objects");
		for (e in _mapObjects.objects) {
			placeEntities(e.xmlData.x, e.gid);
		}
		add(_level);

		// Map objects added here.
		_mapEntities.y = 0; // For some reason this fixes the images being too low -115.
		add(_mapEntities);

		add(_bugs);

		/**
		 * By default flixel only processes what it initally sees, so collisions won't
		 * work until can process the whole level.
		 */
		FlxG.worldBounds.set(0, 0, _level.width, _level.height);
		FlxG.camera.setScrollBoundsRect(0, 0, _level.width, _level.height);

		// Add enemy
		_enemy = new FlxSprite(1570, 600).makeGraphic(50, 50, 0xffff0000);
		add(_enemy);

		_player = new Player(60, 600);
		add(_player);

		/** 
		 * @todo Add `_hud` FlxSpriteGroup
		 */
		// Show score text
		_txtScore = new FlxText(FlxG.width / 2, 40, 0, updateScore());
		_txtScore.setFormat(null, 24, 0xFF194869, FlxTextAlign.CENTER);
		_txtScore.scrollFactor.set(0, 0);
		add(_txtScore);

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
		// Reset the game if the player goes higher/lower than the map
		if (_player.y > _level.height) {
			_justDied = true;
			FlxG.resetState();
		}

		super.update(elapsed);
		// Collisions
		FlxG.collide(_player, _levelCollisions);
		FlxG.overlap(_player, _enemy, hitEnemy);
		FlxG.overlap(_bugs, _player, getBug);
	}

	/**
	 * Std.int converts float to int
	 * @see https://code.haxe.org/category/beginner/numbers-floats-ints.html
	 */
	private function createHearts():Void {
		for (i in 0...Std.int(_player.health)) {
			_health = new FlxSprite((i * 80), 30).loadGraphic("assets/images/heart.png", false, 60, 60);
			_hearts.add(_health);
		}
	}

	private function updateScore():String {
		return "Score:" + _score;
	}

	private function getBug(Bug:FlxObject, Player:FlxObject):Void {
		_score++;
		_txtScore.text = updateScore();
		Bug.kill();
	}

	/**
	 * What happens when the player and the enemy collide
	 */
	private function hitEnemy(Player:FlxSprite, Enemy:FlxObject):Void {
		var index:Int = 0;

		if (Player.isTouching(FlxObject.FLOOR)) {
			Player.hurt(1);
			FlxSpriteUtil.flicker(Player);

			if (Player.flipX) { // if facing left
				FlxTween.tween(Player, {x: (Player.x + 150), y: (Player.y - 40)}, 0.1);
			} else { // facing right
				FlxTween.tween(Player, {x: (Player.x - 150), y: (Player.y - 40)}, 0.1);
			}
		} else {
			// Player bounce
			Player.velocity.y = -600;

			// from the top
			// when rolling animation is playing
			if (Player.animation.curAnim.name != 'run') { 
				Enemy.kill();
			} else { // when rolling animation is NOT playing
				Player.hurt(1);
				FlxSpriteUtil.flicker(Player);
			}
		}

		_hearts.forEach((s:FlxSprite) -> {
			if (index == Player.health) {
				s.alpha = 0.2;
			}
			index++;
		});
	}

	/**
	 * Place entities from Tilemap. This method just converts strings to integers.
	 */
	private function placeEntities(entityData:Xml, objectId:Int):Void {
		var x:Int = Std.parseInt(entityData.get("x")); // Parse string to int
		var y:Int = Std.parseInt(entityData.get("y"));
		var width:Int = Std.parseInt(entityData.get("width"));
		var height:Int = Std.parseInt(entityData.get("height"));
		createEntity(x, y, width, height, objectId);
	}

	/**
	 * Makes object to colider with `Player` in level.
	 */
	private function createEntity(X:Int, Y:Int, width:Int, height:Int, objectId:Int):Void {
		// @see https://code.haxe.org/category/beginner/maps.html
		var layerImage = new Map<Int, String>();
		layerImage = [
			226 => "assets/images/rock-1.png",
			227 => "assets/images/tree-1.png",
			228 => "assets/images/tree-2.png"
		];
		if (objectId == 229) { // 229 means it's a bug/collectable
			createBug(X, (Y - height), width, height);
		} else {
			var _object:FlxSprite = new FlxSprite(X, (Y - height)).loadGraphic(layerImage[objectId], false, width, height);
			_object.immovable = true;
			_mapEntities.add(_object);
		}
	}

	private function createBug(X:Int, Y:Int, width:Int, height:Int):Void {
		var bug:FlxSprite = new FlxSprite(X, Y).loadGraphic("assets/images/purp-bug.png", false, width, height);
		_bugs.add(bug);
	}

	/** Special tiles **/
	private function fallInClouds(Tile:FlxObject, Object:FlxObject):Void {
		js.Browser.console.log(Tile, 'tile');
		if (FlxG.keys.anyPressed([DOWN, S])) {
			Tile.allowCollisions = FlxObject.NONE;
		} else if (Object.y >= Tile.y) {
			Tile.allowCollisions = FlxObject.CEILING;
		}
	}
}
