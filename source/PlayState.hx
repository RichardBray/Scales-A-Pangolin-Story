package;

import openfl.utils.Dictionary;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
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
	var _grpBugs:FlxTypedGroup<CollectableBug>;
	var _justDied:Bool = false; // Will be used later
	var _enemy:Enemy;
	// Vars for NPC
	var _grpSpeech:FlxTypedGroup<FlxSprite>;
	var _friend:FlxSprite;
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


		// Add friend
		// Want the friend behind the rocks
		_friend = new FlxSprite(870, 510).makeGraphic(150, 50, 0xff205ab7);
		add(_friend);

		// Speech bubble
		_grpSpeech = new FlxTypedGroup<FlxSprite>();
		var _speechArrow:FlxSprite = new FlxSprite(870 + (150 / 2), 440).makeGraphic(50, 50, 0xff205ab7);
		_speechArrow.angle = 45;
		_speechArrow.alpha = 0;
		var _speechBox:FlxSprite = new FlxSprite(870 + (90 / 2), 420).makeGraphic(100, 50, 0xff205ab7);
		_speechBox.alpha = 0;
		_grpSpeech.add(_speechArrow);
		_grpSpeech.add(_speechBox);
		add(_grpSpeech);
		/**
		 * Code for adding the environment and collisions
		 */

		// Load custom tilemap
		_map = new TiledMap("assets/data/level-1-2.tmx");

		// Map objects initiated here.
		_mapEntities = new FlxSpriteGroup();

		// Add bugs group
		_grpBugs = new FlxTypedGroup<CollectableBug>();

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

		add(_grpBugs);

		// Add envirionment collisions
		_levelCollisions = new FlxTilemapExt();
		_levelCollisions.loadMapFromArray(cast(_map.getLayer("collisions"), TiledTileLayer).tileArray, _map.width, _map.height,
			"assets/images/ground-collisions.png", _map.tileWidth, _map.tileHeight, FlxTilemapAutoTiling.OFF, 1);
		// _levelCollisions.follow(); // lock camera to map's edges
		// set slopes
		_levelCollisions.setSlopes([10, 11]);
		_levelCollisions.setGentle([11], [10]);

		// set cloud/special tiles
		_levelCollisions.setTileProperties(5, FlxObject.NONE, fallInClouds);
		_levelCollisions.alpha = 0;
		add(_levelCollisions);

		/**
		 * By default flixel only processes what it initally sees, so collisions won't
		 * work until can process the whole level.
		 */
		FlxG.worldBounds.set(0, 0, _level.width, _level.height);
		FlxG.camera.setScrollBoundsRect(0, 0, _level.width, _level.height);

		// Add enemy
		_enemy = new Enemy(1570, 600);
		add(_enemy);

		// Add player
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

		// Overlaps
		FlxG.overlap(_player, _enemy, hitEnemy);
		FlxG.overlap(_grpBugs, _player, getBug);
	
		if(!FlxG.overlap(_player, _friend, initConvo)) {
			_grpSpeech.forEach((member:FlxSprite) -> {
				FlxTween.tween(member, {alpha: 0}, .1);
			});
		};		
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
			if (Player.animation.curAnim.name == 'jump' || Player.animation.curAnim.name == 'jumpLoop') {
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

	private function initConvo(Player:Player, Friend:FlxSprite):Void {
		if (Player.isTouching(FlxObject.FLOOR)) {
			// show press e prompt
			_grpSpeech.forEach((member:FlxSprite) -> {
				FlxTween.tween(member, {alpha: 1}, .1);
			});
	
			if (FlxG.keys.anyJustPressed([E])) {
				// start the converstation
				// hide prompt
				// zoom camera
				FlxTween.tween(FlxG.camera, { zoom: 1.05 }, 0.2);
				// toggle popup shown variable
				js.Browser.console.log('Hey Pango!');
				Player.preventMovement = true;
				// if (FlxG.keys.anyJustPressed([E])) {
				// 	FlxTween.tween(FlxG.camera, { zoom: 1 }, 0.2);
				// 	Player.preventMovement = false;
				// }
			}
		}
	}

	private function getBug(Bug:FlxObject, Player:FlxObject):Void {
		if (Bug.alive && Bug.exists) {
			_score = _score + 1;
			_txtScore.text = updateScore();
			Bug.kill();
		}
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
			// createBug(X, (Y - height), width, height);
			var bug:CollectableBug = new CollectableBug(X, (Y - height), width, height);
			_grpBugs.add(bug);
		} else {
			var _object:FlxSprite = new FlxSprite(X, (Y - height)).loadGraphic(layerImage[objectId], false, width, height);
			_object.immovable = true;
			_mapEntities.add(_object);
		}
	}

	/** Special tiles **/
	private function fallInClouds(Tile:FlxObject, Object:FlxObject):Void {
		if (FlxG.keys.anyPressed([DOWN, S])) {
			Tile.allowCollisions = FlxObject.NONE;
		} else if (Object.y >= Tile.y) {
			Tile.allowCollisions = FlxObject.CEILING;
		}
	}
}
