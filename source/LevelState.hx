package;

// - Flixel
import flixel.system.FlxSound;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tile.FlxBaseTilemap;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;
// - Tiled
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;

typedef CollMap = Map<String, Array<Int>>;

class LevelState extends GameState {
	var _level:FlxTilemap;
	var _levelBg:FlxSprite;
	var _mapEntities:FlxSpriteGroup;
	var _grpCollectables:FlxTypedGroup<CollectableBug>;
	var _levelCollisions:FlxTilemapExt;
	var _map:TiledMap;
	var _mapObjects:TiledObjectLayer;
	var _collisionImg:String;
	var _mapObjectId:Int = 0; // Unique ID added for loading level and hiding collected collectable
	var _collectablesMap:CollMap; // Private collectables map for comparison
	var _levelScore:Int; // This is used for the game save
	var _controls:Controls;
	// Sounds
	var _sndCollect:FlxSound;

	public var grpHud:HUD;
	public var player:Player; // used by HUD for health
	public var levelExit:FlxSprite; // used by LevelOne
	public var startingConvo:Bool = false; // Used for toggling view for convo with NPC
	public var actionPressed:Bool = false;
	public var levelName:String; // Give level unique name

	override public function create():Void {
		bgColor = 0xffc7e4db; // Game background color

		// Continue music if it's already playing
		if (FlxG.sound.music == null) {
			playMusic("assets/music/music.ogg");
		}

		/**
		 * By default flixel only processes what it initally sees, so collisions won't
		 * work until can process the whole level.
		 */
		FlxG.worldBounds.set(0, 0, _level.width, _level.height);

		FlxG.camera.setScrollBoundsRect(0, 0, _level.width, _level.height);
		FlxG.camera.antialiasing = true;

		// Camera follows Player
		FlxG.camera.follow(player, PLATFORMER, 1);
		_sndCollect = FlxG.sound.load("assets/sounds/collect.wav");

		// Intialise controls
		_controls = new Controls();

		super.create();
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);

		// Reset the game if the player goes higher/lower than the map
		if (player.y > _level.height) {
			var _pauseMenu:PauseMenu = new PauseMenu(true);
			openSubState(_pauseMenu);
		}
		// Paused game state
		if (_controls.start.check()) {
			// SubState needs to be recreated here as it will be destroyed
			FlxG.sound.music.pause();
			var _pauseMenu:PauseMenu = new PauseMenu(false);
			openSubState(_pauseMenu);
		}

		// Collisions
		FlxG.collide(player, _levelCollisions);

		// Overlaps
		FlxG.overlap(_grpCollectables, player, getCollectable);
	}

	/**
	 *
	 * @param 	MapFile 		Comtains the name of the tmx data file used for the map.
	 * @param 	Background 		Parallax background image name.
	 * @param 	CollectablesMap	List of already collected collectables if revisiting a level.
	 */
	public function createLevel(MapFile:String, Background:String, CollectablesMap:CollMap):Void {
		_collisionImg = "assets/images/ground-collisions.png";
		_collectablesMap = CollectablesMap;

		/**
		 * Code for adding the environment and collisions
		 */

		// Code for parallax background
		_levelBg = new FlxSprite(0, 400, 'assets/images/$Background.png');

		_levelBg.scale.set(4.5, 4.5);
		_levelBg.alpha = 0.75;
		_levelBg.scrollFactor.set(0.3, 1);
		add(_levelBg);
		// Load custom tilemap
		_map = new TiledMap('assets/data/$MapFile.tmx');

		// Map objects initiated here.
		_mapEntities = new FlxSpriteGroup();

		// Add bugs group
		_grpCollectables = new FlxTypedGroup<CollectableBug>();
		add(_grpCollectables);

		// Tile tearing problem fix on Mac (part 1)
		// @see http://forum.haxeflixel.com/topic/39/tilemap-tearing-desktop-targets/5
		var _mapSize:FlxPoint = FlxPoint.get(_map.tileWidth, _map.tileHeight);
		var _tilesetTileFrames:Array<FlxTileFrames> = new Array<FlxTileFrames>();
		for (_tileset in _map.tilesetArray) {
			_tilesetTileFrames.push(FlxTileFrames.fromRectangle(_collisionImg, _mapSize));
		}
		var _tileSpacing:FlxPoint = FlxPoint.get(0, 0);
		var _tileBorder:FlxPoint = FlxPoint.get(2, 2);

		var _mergedTileset = FlxTileFrames.combineTileFrames(_tilesetTileFrames, _tileSpacing, _tileBorder);

		_mapSize.put();
		_tileSpacing.put();
		_tileBorder.put();

		// Flixel level created from Tilemap map
		_level = new FlxTilemap();
		_level.loadMapFromArray(cast(_map.getLayer("ground"), TiledTileLayer).tileArray, _map.width, _map.height, _mergedTileset, _map.tileWidth,
			_map.tileHeight, FlxTilemapAutoTiling.OFF, 1);
		add(_level);

		// Tile tearing problem fix on Mac (part 2)
		// @see https://github.com/HaxeFlixel/flixel-demos/blob/master/Platformers/FlxTilemapExt/source/LevelOne.hx#L48
		var levelTiles = FlxTileFrames.fromBitmapAddSpacesAndBorders(_collisionImg, new FlxPoint(10, 10), new FlxPoint(2, 2), new FlxPoint(2, 2));
		_level.frames = levelTiles;

		// Looping over `objects` layer
		_mapObjects = cast(_map.getLayer("objects"), TiledObjectLayer);
		for (e in _mapObjects.objects) {
			placeEntities(e.xmlData.x, e.gid, _mapObjectId++);
		}

		// Map objects added here
		add(_mapEntities);
		_mapEntities.y = 0; // For some reason this fixes the images being too low -115.

		// Add envirionment collisions
		_levelCollisions = new FlxTilemapExt();
		_levelCollisions.loadMapFromArray(cast(_map.getLayer("collisions"), TiledTileLayer).tileArray, _map.width, _map.height, _collisionImg, _map.tileWidth,
			_map.tileHeight, FlxTilemapAutoTiling.OFF, 1);
		_levelCollisions.follow(); // lock camera to map's edges

		// set slopes
		_levelCollisions.setSlopes([10, 11]);
		_levelCollisions.setGentle([11], [10]);

		// set cloud/special tiles
		_levelCollisions.setTileProperties(5, FlxObject.NONE, fallInClouds);
		_levelCollisions.alpha = 0; // Hide collision objects
		add(_levelCollisions);

		// Level exit
		levelExit = new FlxSprite((_level.width - 1), 0).makeGraphic(1, 720, FlxColor.TRANSPARENT);
		add(levelExit);
	}

	/**
	 * This method creates and adds the HUD to the level.
	 *
	 * @param Score		Player score at time of HUD creation, also used for `saveGame` method.
	 * @param Health	Player health value at time of HUD creation.
	 */
	public function createHUD(Score:Int, Health:Float) {
		_levelScore = Score;
		grpHud = new HUD(Score, Health);
		add(grpHud);
	}

	/**
	 * Adds player
	 *
	 * @param X Player X position
	 * @param Y Player Y position
	 */
	public function createPlayer(X:Int, Y:Int, FacingLeft = false):Void {
		player = new Player(X, Y);
		if (FacingLeft)
			player.facing = FlxObject.LEFT;
		add(player);
	}

	/**
	 * Saves the game.
	 *
	 * @param GameSave	Save game data from level.
	 */
	public function saveGame(GameSave:FlxSave):FlxSave {
		GameSave.data.levelName = levelName;
		GameSave.data.playerScore = _levelScore;
		GameSave.data.collectablesMap = _collectablesMap;
		// @todo Add player position to game save
		GameSave.flush();
		return GameSave;
	}

	/**
	 * Sets up and plays level music
	 *
	 * @param LevelMusic	String of music location
	 */
	public function playMusic(LevelMusic:String):Void {
		FlxG.sound.playMusic(LevelMusic, 0.4, true);
	}

	/**
	 * What happens when the player and the enemy collide
	 */
	public function hitEnemy(Player:Player, Enemy:Enemy):Void {
		if (Player.health > 1) {
			if (Player.isTouching(FlxObject.FLOOR)) {
				Player.hurt(1);
				Enemy.sndHit.play();
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
					Enemy.sndEnemyKill.play();
					Enemy.kill();
				} else { // when rolling animation is NOT playing
					Player.hurt(1);
					Enemy.sndHit.play();
					FlxSpriteUtil.flicker(Player);
				}
			}
		} else {
			// @todo play death animation
			var _pauseMenu:PauseMenu = new PauseMenu(true);
			openSubState(_pauseMenu);
		}

		grpHud.decrementHealth(Player.health);
	}

	/**
	 * Place entities from Tilemap.
	 * This method just converts strings to integers.
	 */
	function placeEntities(EntityData:Xml, ObjectId:Int, MapObjId:Int):Void {
		var x:Int = Std.parseInt(EntityData.get("x")); // Parse string to int
		var y:Int = Std.parseInt(EntityData.get("y"));
		var width:Int = Std.parseInt(EntityData.get("width"));
		var height:Int = Std.parseInt(EntityData.get("height"));

		var hideCollectable:Int = -1; // Default collecatlbe ID -1 means no collecatble
		if (_collectablesMap[levelName].length != 0) {
			// The line below checks if the number in the array matches the object ID.
			// If it does it returns an array with that number, if it doesn't, it returns an empty array.
			var _hideColVal:Array<Int> = _collectablesMap[levelName].filter(collectable -> collectable == MapObjId);
			hideCollectable = (_hideColVal.length == 0) ? -1 : _hideColVal[0];
		}
		createEntity(x, y, width, height, ObjectId, MapObjId, hideCollectable);
	}

	/**
	 * Makes object to colider with `Player` in level.
	 */
	function createEntity(X:Int, Y:Int, Width:Int, Height:Int, ObjectId:Int, MapObjId:Int, HideCollectable:Int):Void {
		// @see https://code.haxe.org/category/beginner/maps.html
		var layerImage:Map<Int, String> = [
			226 => "assets/images/rock-1.png",
			227 => "assets/images/tree-1.png",
			228 => "assets/images/tree-2.png"
		];
		if (ObjectId == 229) { // 229 means it's a collectable
			if (HideCollectable == -1) {
				var bug:CollectableBug = new CollectableBug(X, (Y - Height), Width, Height, MapObjId);
				_grpCollectables.add(bug);
			}
		} else {
			var _object:FlxSprite = new FlxSprite(X, (Y - Height)).loadGraphic(layerImage[ObjectId], false, Width, Height);
			_object.immovable = true;
			_mapEntities.add(_object);
		}
	}

	/** Special tiles **/
	function fallInClouds(Tile:FlxObject, Object:FlxObject):Void {
		if (_controls.down.check()) {
			Tile.allowCollisions = FlxObject.NONE;
		} else if (Object.y >= Tile.y) {
			Tile.allowCollisions = FlxObject.CEILING;
		}
	}

	function getCollectable(Collectable:CollectableBug, Player:FlxSprite):Void {
		if (Collectable.alive && Collectable.exists) {
			grpHud.incrementScore();
			_sndCollect.play(true);
			_collectablesMap[levelName].push(Collectable.uniqueID);
			Collectable.kill();
		}
	}
}