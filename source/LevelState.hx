package;

// - Flixel
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tile.FlxBaseTilemap;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.tile.FlxTilemapExt;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
// - Tiled
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;

import HUD.GoalData;

typedef CollMap = Map<String, Array<Int>>;

class LevelState extends GameState {
	var _levelBg:FlxSprite;
	var _mapEntities:FlxSpriteGroup;
	var _grpCollectables:FlxTypedGroup<CollectableBug.Bug>;
	var _grpEnemies:FlxTypedGroup<Enemy>;
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

	override public function create() {
		bgColor = 0xffc7e4db; // Game background color

		// Continue music if it's already playing
		if (FlxG.sound.music == null) {
			playMusic("assets/music/music.ogg");
		}

		/**
		 * By default flixel only processes what it initally sees, so collisions won't
		 * work until can process the whole level.
		 */
		FlxG.worldBounds.set(0, 0, _map.fullWidth, _map.fullHeight);
	
		FlxG.camera.setScrollBoundsRect(0, 0, _map.fullWidth, _map.fullHeight);
		FlxG.camera.antialiasing = false;

		// Camera follows Player
		FlxG.camera.follow(player, PLATFORMER, 1);
		_sndCollect = FlxG.sound.load("assets/sounds/collect.wav");

		// Intialise controls
		_controls = new Controls();

		super.create();
	}

	override public function update(Elapsed:Float) {
		super.update(Elapsed);

		// Reset the game if the player goes higher/lower than the map
		if (player.y > _map.fullHeight) {
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
		FlxG.overlap(_grpEnemies, player, hitStandingEnemy);
		FlxG.overlap(_grpCollectables, player, getCollectable);
	}

	/**
	 *
	 * @param 	MapFile 		Comtains the name of the tmx data file used for the map.
	 * @param 	Background 		Parallax background image name.
	 * @param 	CollectablesMap	List of already collected collectables if revisiting a level.
	 */
	public function createLevel(MapFile:String, Background:String, CollectablesMap:CollMap) {
		_collisionImg = "assets/images/collisions.png";
		_collectablesMap = CollectablesMap;

		/**
		 * Code for adding the environment and collisions
		 */

		// Code for parallax background
		_levelBg = new FlxSprite(0, 1280, 'assets/images/$Background.png');

		_levelBg.scale.set(4.5, 4.5);
		_levelBg.alpha = 0;
		_levelBg.scrollFactor.set(0.3, 1);
		add(_levelBg);
		// Load custom tilemap
		_map = new TiledMap('assets/data/$MapFile.tmx');

		// Map objects initiated here.
		_mapEntities = new FlxSpriteGroup();

		// Add bugs group
		_grpCollectables = new FlxTypedGroup<CollectableBug.Bug>();

		// Add enemies
		_grpEnemies = new FlxTypedGroup<Enemy>();
		add(_grpEnemies);		

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


		// Looping over `objects` layer
		_mapObjects = cast(_map.getLayer("objects"));
		for (e in _mapObjects.objects) {
			placeEntities(e.xmlData.x, e.gid, _mapObjectId++);
		}

		// Map objects added here
		add(_mapEntities);
		add(_grpCollectables);

		// Add envirionment collisions
		var firstTile:Int = 13;
		_levelCollisions = new FlxTilemapExt();
		_levelCollisions.loadMapFromArray(
			cast(_map.getLayer("collisions"), TiledTileLayer).tileArray, 
			_map.width, 
			_map.height,
			_collisionImg, 
			_map.tileWidth,
			_map.tileHeight, 
			FlxTilemapAutoTiling.OFF, 
			firstTile
		);

		_levelCollisions.follow(); // lock camera to map's edges

		// set slopes
		_levelCollisions.setSlopes([firstTile + 7, firstTile + 8]);
		_levelCollisions.setGentle([firstTile + 8], [firstTile + 7]);

		// set cloud/special tiles
		_levelCollisions.setTileProperties(firstTile + 2, FlxObject.NONE, fallInClouds);
		_levelCollisions.alpha = 0; // Hide collision objects
		add(_levelCollisions);

		// Level exit
		levelExit = new FlxSprite((_map.fullWidth - 20), 0).makeGraphic(20, _map.fullHeight, FlxColor.TRANSPARENT);
		levelExit.immovable = true;
		add(levelExit);
	}

	/**
	 * This method creates and adds the HUD to the level.
	 *
	 * @param Score		Player score at time of HUD creation, also used for `saveGame` method.
	 * @param Health	Player health value at time of HUD creation.
	 */

	public function createHUD(Score:Int, Health:Float, Goals:Array<GoalData>) {
		_levelScore = Score;
		grpHud = new HUD(Score, Health, Goals);
		add(grpHud);
	}

	/**
	 * Adds player
	 *
	 * @param X 				Player X position
	 * @param Y 				Player Y position
	 * @param FacingLef If the player is facine left
	 */
	public function createPlayer(X:Int, Y:Int, FacingLeft = false) {
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
	public function playMusic(LevelMusic:String) {
		FlxG.sound.playMusic(LevelMusic, 0, true); // .4
	}

	/**
	 * Place entities from Tilemap.
	 * This method just converts strings to integers.
	 */
	function placeEntities(EntityData:Xml, ObjectId:Int, MapObjId:Int) {
		var x:Int = Std.parseInt(EntityData.get("x")); // Parse string to int
		var y:Int = Std.parseInt(EntityData.get("y"));
		var width:Int = Std.parseInt(EntityData.get("width"));
		var height:Int = Std.parseInt(EntityData.get("height"));
		var name:String = EntityData.get("name");
		var type:String = EntityData.get("type");
		var hideCollectable:Int = -1; // Default collecatlbe ID -1 means no collecatble

		if (_collectablesMap[levelName].length != 0) {
			// The line below checks if the number in the array matches the object ID.
			// If it does it returns an array with that number, if it doesn't, it returns an empty array.
			var _hideColVal:Array<Int> = _collectablesMap[levelName].filter(collectable -> collectable == MapObjId);
			hideCollectable = (_hideColVal.length == 0) ? -1 : _hideColVal[0];
		}
		createEntity(x, y, width, height, name, type, ObjectId, MapObjId, hideCollectable);
	}

	/**
	 * Makes object to colider with `Player` in level.
	 */
	function createEntity(
		X:Int, 
		Y:Int, 
		Width:Int, 
		Height:Int, 
		Name:String,
		Otype:String, // Object type
		ObjectId:Int, 
		MapObjId:Int, 
		HideCollectable:Int
	) {
		var newY:Int = (Y - Height);
		// @see https://code.haxe.org/category/beginner/maps.html
		var layerImage:Map<Int, String> = [
			1 => "assets/images/L1_ROCK_01.png",
			2 => "assets/images/L1_ROCK_02.png",
			3 => "assets/images/L1_ROCK_03.png",
			4 => "assets/images/L1_ROCK_04.png",
			5 => "assets/images/L1_TREE_01.png",
			6 => "assets/images/L1_TREE_02.png",
			7 => "assets/images/L1_TREE_03.png",
			8 => "assets/images/L1_GROUND_01.png"
		];
		if (ObjectId >= 9 && ObjectId <=11) {
			if (HideCollectable == -1) {
				var bug:CollectableBug.Bug = null;
				if (ObjectId == 9) bug = new CollectableBug.StagBeetle(X, newY, Name, Otype, MapObjId);
				if (ObjectId == 10) bug = new CollectableBug.Beetle(X, newY, Name, Otype, MapObjId);
				if (ObjectId == 11) bug = new CollectableBug.Caterpillar(X, newY, Name, Otype, MapObjId);
				_grpCollectables.add(bug);
			}

		} else if (ObjectId == 12) { // Fire
			var enemy:Enemy = null;
			enemy = new Enemy.Fire(X, newY);
			_grpEnemies.add(enemy);

		} else {
			var _object:FlxSprite = new FlxSprite(X, newY).loadGraphic(layerImage[ObjectId], false, Width, Height);
			_object.immovable = true;
			_mapEntities.add(_object);
		}
	}

	/** Special tiles **/
	function fallInClouds(Tile:FlxObject, Object:FlxObject) {
		if (_controls.down.check()) {
			var timer = new FlxTimer();
			Tile.allowCollisions = FlxObject.NONE;
			timer.start(.1, (_) -> player.isGoindDown = true);	
		} else if (Object.y >= Tile.y) {
			Tile.allowCollisions = FlxObject.CEILING;
			player.isGoindDown = false;
		}
	}

	function getCollectable(Collectable:CollectableBug.Bug, Player:Player) {
		if (Collectable.alive && Collectable.exists) {
			grpHud.incrementScore();
			_sndCollect.play(true);
			_collectablesMap[levelName].push(Collectable.uniqueID);
			Collectable.kill();
		}
	}


	/**
	 * What happens when the player and the enemy collide
	 */
	function hitEnemy(Enemy:Enemy, Player:Player) {
		/**
		* Animations and positions for when player hits enemy
		*/
		function playerAttackedAnims(?LastLife:Null<Bool> = false) {
			// Player is on the ground
			if (Player.isTouching(FlxObject.FLOOR)) {
				if (!LastLife) Player.hurt(1);
				Enemy.sndHit.play();
				FlxSpriteUtil.flicker(Player);
				Player.animJump(Player.flipX); 
			} else { // Player is in the air
				// Player bounce
				Player.velocity.y = -900;
				// when rolling animation is playing
				if (Player.animation.curAnim.name == 'jump' || Player.animation.curAnim.name == 'jumpLoop') {
					Enemy.sndEnemyKill.play();
					// Enemy.kill();
				} else { // when rolling animation is NOT playing
					if (!LastLife) Player.hurt(1);
					Enemy.sndHit.play();
					FlxSpriteUtil.flicker(Player);
				}
			}		
			grpHud.decrementHealth((LastLife) ? 0 : Player.health);
		}

		// Player is alive
		if (Enemy.alive && Player.health > 1) {
			playerAttackedAnims();
		} else { // Player is dead
			playerDeathASequence(Player, playerAttackedAnims);
		}
	}	


	/**
	 * Reaction for player if hitting a stading enemy i.e. spikes or fire.
	 * Player shoudl lose health no matter how enemy is hit/overlapped.
	 * Behavior is sort of hacked to temporarily trigger the enemy aliver property
	 * so flixel knows which enemy has been hit.
	 *
	 * @param Enemy		Enemy Sprite
	 * @param Player	Player Sprite
	 */
	function hitStandingEnemy(Enemy:Enemy, Player:Player) {

		/**
		 * Player animations in separate function.
		 *
		 * @param LastLife Used to prolongue death of character.
		 */
		function playerAttackedAnims(?LastLife:Null<Bool> = false) {
			Enemy.kill(); // Change enemy alive variable temporarily
			Enemy.sndHit.play(); // Play sound for when player is hurt

			// Reduce player health
			if (!LastLife) Player.hurt(1);
			grpHud.decrementHealth((LastLife) ? 0 : Player.health);
			FlxSpriteUtil.flicker(Player); // Turn on flicker animation

			Player.isTouching(FlxObject.FLOOR)
				? Player.animJump(Player.flipX)
				:	Player.velocity.y = -400;
		}

		if (Enemy.alive) { // Prevents enemy from dying
			(Player.health > 1) 
				? playerAttackedAnims() 
				: playerDeathASequence(Player, playerAttackedAnims);
		} 
	}

	/**
	 * Sequeence of events that need to happen when plaher dies.
	 *

	 */
	function playerDeathASequence(Player:Player, AttackAnims:Bool->Void) {
		var timer = new FlxTimer();
		// @todo play death animation
		Player.preventMovement = true;
		AttackAnims(true);
		timer.start(0.4, showGameOverMenu, 1);
	}

	function showGameOverMenu(_) {
		var _pauseMenu:PauseMenu = new PauseMenu(true);
		openSubState(_pauseMenu);
	}
}
