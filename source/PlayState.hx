package;

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
// - Nape
import flixel.addons.nape.FlxNapeSpace;
import nape.geom.Vec2;
import nape.callbacks.CbEvent;
import nape.callbacks.InteractionType;
import nape.callbacks.InteractionListener;
import nape.callbacks.CbType;
import nape.shape.Polygon;
// - Tiled
import flixel.addons.editors.tiled.TiledMap; // Ignore the error VScode gives here
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
// - Flixel
import flixel.util.FlxColor;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;

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
	var _map:TiledMap;
	var _mapImages:TiledObjectLayer;
	var _mapEntities:FlxSpriteGroup;

	var _colType:CbType = new CbType();

	override public function create():Void {
		FlxG.mouse.visible = true; // Hide the mouse cursor
		bgColor = 0xffc7e4db; // Game background color

		// messing around with Nape
		FlxNapeSpace.init(); // Create space for nape simulations
		FlxNapeSpace.space.gravity.setxy(0, 500);
		FlxNapeSpace.createWalls();

		FlxNapeSpace.space.listeners.add(new InteractionListener(
			CbEvent.BEGIN, 
			InteractionType.COLLISION, 
			_colType,
			_colType,
			onCollide));		

		// Map objects initiated here.
		_mapEntities = new FlxSpriteGroup();		
	
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
			placeEntities(e.type, e.xmlData.x);
		}
		add(_level);

		// Map objects added here.
		_mapEntities.y = -115; // Fos some reason this fixes the images being too low.
		add(_mapEntities);

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

		// Add enemy
		_enemy = new FlxSprite(800, 850).makeGraphic(50, 50, 0xffff0000);
		add(_enemy);

		_player = new Player(60, 650);
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
		// Reset the game if the player goes higher than the map
		if (_player.y > _level.height) {
			_justDied = true;
			FlxG.resetState();
		}

		super.update(elapsed);
		// Collisions
		// FlxG.collide(_player, box);
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
			FlxSpriteUtil.flicker(Player);
			_hearts.forEach((s:FlxSprite) -> {
				if (index == Player.health) {
					s.alpha = 0.2;
				}
				index++;
			});
		}
	}

	/**
	 * Place entities from Tilemap.
	 */
	function placeEntities(entityName:String, entityData:Xml):Void {
		js.Browser.console.log(entityName);
		var x:Int = Std.parseInt(entityData.get("x")); // Parse string to int
		var y:Int = Std.parseInt(entityData.get("y"));
		var width:Int = Std.parseInt(entityData.get("width"));
		var height:Int = Std.parseInt(entityData.get("height"));
		createEntity(x, y, width, height);
	}

	/**
	 * Makes object to colider with `Player` in level.
	 */
	function createEntity(X:Int, Y:Int, width:Int, height:Int):Void {
		var _object:FlxSprite = new FlxSprite(X, Y).loadGraphic("assets/images/rock-1.png", false, width, height);
		_object.immovable = true;
		js.Browser.console.log(_object);
		_mapEntities.add(_object);
	}

	function collisionType():Void {
		_player.body.cbTypes.add(_colType);
	}
	function onCollide():Void {
		js.Browser.console.log('collisiosn');
	}
}
