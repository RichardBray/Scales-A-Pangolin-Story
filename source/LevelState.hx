package;

// - Flixel
import flixel.tile.FlxTile;
import flixel.util.FlxTimer;
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
	var _grpKillableEnemies:FlxTypedGroup<Enemy>;
	var _levelCollisions:FlxTilemapExt;
	var _map:TiledMap;
	var _mapObjects:TiledObjectLayer;
	var _collisionImg:String;
	var _mapObjectId:Int = 0; // Unique ID added for loading level and hiding collected collectable
	var _collectablesMap:CollMap; // Private collectables map for comparison
	var _levelScore:Int; // This is used for the game save
	var _firstTile:Int = 14; // ID of first collision tile, for some reason Tiled changes this
	var _controls:Controls;
	// Player
	var _secondsOnGround:Float; // Used for feet collisions to tell how
	var _playerFeetCollision:FlxObject;
	var _playerPushedByFeet:Bool; // Checl if player collisions are off because of feet
	var _upOnSlope:Bool = false; // Keep feet collisions up from ground when on slope
	var _playerTouchMovingEnemy:Bool = false; // Hacky way to prevent player for losing two lives on one hit
	var _playerJustHitEnemy:Bool = false;
	// HUD
	var _enemyDeathCounterExecuted:Bool = false; // Used to count enemy detahs for goals
	// Enemies
	var _grpEnemyAttackBoundaries:FlxTypedGroup<FlxObject>;

	public var grpHud:HUD;
	public var player:Player; // used by HUD for health
	public var levelExit:FlxSprite; // used by LevelOne
	public var startingConvo:Bool = false; // Used for toggling view for convo with NPC
	public var actionPressed:Bool = false; // Used for NPC conversation
	public var levelName:String; // Give level unique name
	public var killedEmenies:Int = 0; // Tells level how many enemies have died for goals

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

		// Intialise controls
		_controls = new Controls();

		super.create();
	}

	/** PUBLIC FUNCTIONS **/

	/**
	 * Method for creating a level
	 *
	 * @param 	MapFile 		Comtains the name of the tmx data file used for the map.
	 * @param 	Background 		Parallax background image name.
	 * @param 	CollectablesMap	List of already collected collectables if revisiting a level.
	 */
	public function createLevel(MapFile:String, Background:String, ?CollectablesMap:CollMap) {
		_collisionImg = "assets/images/collisions.png";
		if (CollectablesMap != null) {
			_collectablesMap = CollectablesMap;
		} else {
			_collectablesMap = Constants.initialColMap();
		}

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

		// Add standing enemies
		_grpEnemies = new FlxTypedGroup<Enemy>();	

		// Add killable enemies
		_grpKillableEnemies = new FlxTypedGroup<Enemy>();
		_grpEnemyAttackBoundaries = new FlxTypedGroup<FlxObject>();

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
		add(_grpEnemies);	
		add(_grpKillableEnemies);	
		add(_grpEnemyAttackBoundaries);			


		// Add envirionment collisions
		_levelCollisions = new FlxTilemapExt();
		_levelCollisions.loadMapFromArray(
			cast(_map.getLayer("collisions"), TiledTileLayer).tileArray, 
			_map.width, 
			_map.height,
			_collisionImg, 
			_map.tileWidth,
			_map.tileHeight, 
			FlxTilemapAutoTiling.OFF, 
			_firstTile
		);

		_levelCollisions.follow(); // lock camera to map's edges

		// set slopes
		_levelCollisions.setSlopes([_firstTile + 7, _firstTile + 8]);
		_levelCollisions.setGentle([_firstTile + 8], [_firstTile + 7]);

		// set cloud/special tiles
		_levelCollisions.setTileProperties(_firstTile + 2, FlxObject.NONE, fallInClouds);
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
	 * Adds player and the feet collisions
	 *
	 * @param X 				Player X position
	 * @param Y 				Player Y position
	 * @param FacingLeft If the player is facine left
	 */
	public function createPlayer(X:Int, Y:Int, FacingLeft = false) {
		player = new Player(X, Y);
		_playerFeetCollision = new FlxObject(X, Y, 10, 72);
		_playerFeetCollision.acceleration.y = Constants.worldGravity;
	
		if (FacingLeft) player.facing = FlxObject.LEFT;
		add(player);
		add(_playerFeetCollision);
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
		FlxG.sound.playMusic(LevelMusic, 0.2, true); // .4
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
			var enemy:Enemy;
			enemy = new Enemy.Fire(X, newY);
			_grpEnemies.add(enemy);

		} else if (ObjectId == 13) { // Boar
			var boar:Enemy;
			boar = new Enemy.Boar(X, newY, Name, Otype);
			_grpKillableEnemies.add(boar);

		} else if (ObjectId == 29) { // Snake
			var snake:Enemy;
			var snakeAttackBox:Enemy;
			var snakeAttackBoundary:Enemy.Boundaries;

			snake = new Enemy.Snake(X, newY, Name, Otype);
			snakeAttackBox = new Enemy.SnakeAttackBox(X, newY + 20, Name, snake);
			snakeAttackBoundary = new Enemy.Boundaries(
				X, newY + 20, // 20 so snake doesn't attack as soon as player enters boundary
				snake.width, 
				snake.height - 20, // 20 so snake doesn't attack as soon as player enters boundary
				snake); 

			_grpKillableEnemies.add(snake);
			_grpEnemies.add(snakeAttackBox);
			_grpEnemyAttackBoundaries.add(snakeAttackBoundary);
		
		} else {
			var _object:FlxSprite = new FlxSprite(X, newY).loadGraphic(layerImage[ObjectId], false, Width, Height);
			_object.immovable = true;
			_mapEntities.add(_object);
		}
	}

	/** Special tiles **/
	/**
	 * Method to dication what should happen when player interacts weith a special tile.
	 * 
	 * @param FallThroughTile	Tile that should be affected by action
	 * @param	Player					Player sprite (I'm not 100% sure if this is true)
	 */
	function fallInClouds(FallThroughTile:FlxObject, Player:FlxObject) {
		if (_controls.down.check()) {
			var timer = new FlxTimer();
			FallThroughTile.allowCollisions = FlxObject.NONE;
			timer.start(.1, (_) -> player.isGoindDown = true);	
		} else if (Player.y >= FallThroughTile.y) {
			FallThroughTile.allowCollisions = FlxObject.CEILING;
			player.isGoindDown = false;
		}
	}

	function getCollectable(Collectable:CollectableBug.Bug, Player:Player) {
		if (Collectable.alive && Collectable.exists) {
			grpHud.incrementScore();
			_collectablesMap[levelName].push(Collectable.uniqueID);
			Collectable.kill();
		}
	}


	/**
	 * What happens when the player and the enemy collide
	 */
	function hitEnemy(Enemy:Enemy, Player:Player) {
		var playerAttacking:Bool = 
			(Player.animation.name == "jump" || Player.animation.name == "jumpLoop")
			&& (!Player.isAscending || _playerJustHitEnemy);

		/**
		 * Things to do when player get's hurt.
		 * Sets `_playerTouchMovingEnemy` true if player gets hurt. Prevents loosing two hearts on one hit.
		 *
		 * @param LastLife Used to prolongue death of character.
		 */
		function playerHurt(LastLife:Bool) {
			if (!LastLife && !_playerTouchMovingEnemy) {
				Player.hurt(1);
				_playerTouchMovingEnemy = true;
			}
			Enemy.sndHit.play();
			FlxSpriteUtil.flicker(Player);
		}

		/**
		* Animations and positions for when player hits enemy
		*
		* @param LastLife Used to prolongue death of character.
		*/	
		function playerAttackedAnims(?LastLife:Null<Bool> = false) {
			// Player is on the ground
			if (Player.isTouching(FlxObject.FLOOR)) {
				playerHurt(LastLife);
				Player.animJump(Player.flipX); 
			} else { // Player is in the air
				// when rolling animation is playing
				if (playerAttacking) {
					// Player bounce
					Player.velocity.y = Enemy.push;					
					Enemy.sndEnemyKill.play();
					_playerJustHitEnemy = true; // true for half a second, false when touch ground
					Enemy.kill();
					FlxG.camera.shake(0.00150, 0.25);
					incrementDeathCount();
				} else { // when rolling animation is NOT playing
					if (Player.animation.name == "jump" || Player.animation.name == "jumpLoop") {
						Player.animJump(Player.flipX);
					} else {
						Player.velocity.y = (Enemy.push / 3) * 2;
					}
					playerHurt(LastLife);
				}
			}	
			grpHud.decrementHealth(LastLife ? 0 : Player.health);	
		}

		// Fix player dying on last life when they attack
		(Player.health == 1 && !playerAttacking && !_playerTouchMovingEnemy) 
			? playerDeathASequence(Player, playerAttackedAnims)
			: playerAttackedAnims();
	}	

	/**
	 * Method used to count enemy deaths. Time used to make sure boolean is set one.
	 * Would be set multiple times otherwise because of update.
	 */
	function incrementDeathCount() {
		if (!_enemyDeathCounterExecuted) {
			killedEmenies++;
			_enemyDeathCounterExecuted = true;
			haxe.Timer.delay(() -> _enemyDeathCounterExecuted = false, 1000);
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
			Enemy.sndHit.play(true); // Play sound for when player is hurt

			// Reduce player health
			if (!LastLife) Player.hurt(1);
			grpHud.decrementHealth((LastLife) ? 0 : Player.health);
			FlxSpriteUtil.flicker(Player); // Turn on flicker animation

			Player.isTouching(FlxObject.FLOOR)
				? Player.animJump(Player.flipX)
				:	Player.velocity.y = Enemy.push;
		}

		if (Enemy.alive) { // Prevents enemy from dying
			(Player.health > 1) 
				? playerAttackedAnims() 
				: playerDeathASequence(Player, playerAttackedAnims);
		} 
	}


	/**
	 * Cause enemy to attack when player enters their boundary
	 */
	function initEnemyAttack(Boundary:Enemy.Boundaries, Player:Player) {
		Boundary.enemy.attacking = true;
	}	

	/**
	 * Sequence of events that need to happen when player dies.
	 */
	function playerDeathASequence(Player:Player, AttackAnims:Bool->Void) {
		var timer = new FlxTimer();
		// @todo play death animation
		Player.preventMovement = true;
		AttackAnims(true);
		timer.start(0.4, showGameOverMenu, 1);
	}

	function showGameOverMenu(_) {
		var _pauseMenu:PauseMenu = new PauseMenu(true, levelName);
		openSubState(_pauseMenu);
	}

	/**
	* This method updates the player of the feet collisions with the players.
	*/
	function updateFeetCollisions() {
		var xOffset:Int = player.facing == FlxObject.LEFT ? 80 : 25;
		var playerIsOnGround:Bool = player.isTouching(FlxObject.FLOOR);
		var feetCollisionIsOnGround:Bool = _playerFeetCollision.isTouching(FlxObject.FLOOR);

		// Conditions
		var playerTouchingButNotFeet:Bool = playerIsOnGround && _secondsOnGround > 0.2;
		var playerIsInTheAir:Bool = !playerIsOnGround && !_playerPushedByFeet || _upOnSlope;

		// Positions the feet colisions higher when jumping so that the player touches the ground first
		var yOffset:Int = playerIsInTheAir ? -30 : 20;

		// Make sure feet collisions always hits floor before player when being pushed down by feet
		yOffset	= _playerPushedByFeet ? 30 : yOffset;

		if (playerTouchingButNotFeet && !feetCollisionIsOnGround) {
			// Activate gravity and disable player collisions
			player.acceleration.y = Constants.worldGravity;
			player.allowCollisions = FlxObject.NONE;
			_playerPushedByFeet = true;

		} else if (playerIsInTheAir || feetCollisionIsOnGround) {
			_secondsOnGround = 0; // Reset this because their in the air
			player.allowCollisions = FlxObject.ANY;
			if (feetCollisionIsOnGround) _playerPushedByFeet = false;
		}

		// Update feet coliison position at bottom 
		_playerFeetCollision.setPosition(player.x + xOffset, player.y + yOffset);	
	}

	/**
	 * This method prevents the player from colliding with slopes.
	 * The slope and the feetCollisions don't work well together.
	 */
	function preventSlopeCollisions(SlopeTile:FlxObject, _) {
		var convertedSlope:FlxTile;
		convertedSlope = cast SlopeTile; // Changes FlxObject to FlxTile
		if (convertedSlope.index == _firstTile + 7) { 
			_playerPushedByFeet = false; 
			_upOnSlope = true;
		}
		_upOnSlope = false;
		return true;
	}

	override public function update(Elapsed:Float) {
		_secondsOnGround += Elapsed;
		updateFeetCollisions();
		super.update(Elapsed);

		if (_playerTouchMovingEnemy) {
			haxe.Timer.delay(() -> _playerTouchMovingEnemy = false, 250);
		}

		// Reset the game if the player goes higher/lower than the map
		if (player.y > _map.fullHeight) {
			var _pauseMenu:PauseMenu = new PauseMenu(true, levelName);
			openSubState(_pauseMenu);
		}
		// Paused game state
		if (_controls.start.check()) {
			// SubState needs to be recreated here as it will be destroyed
			FlxG.sound.music.pause();
			var _pauseMenu:PauseMenu = new PauseMenu(false, levelName);
			openSubState(_pauseMenu);
		}

		// Collisions
		FlxG.collide(player, _levelCollisions);
		FlxG.collide(_playerFeetCollision, _levelCollisions);

		// Overlaps
		FlxG.overlap(_grpEnemies, player, hitStandingEnemy);
		FlxG.overlap(_grpKillableEnemies, player, hitEnemy);
		FlxG.overlap(_grpCollectables, player, getCollectable);
		FlxG.overlap(_grpEnemyAttackBoundaries, player, initEnemyAttack);

		if (!FlxG.overlap(_grpEnemyAttackBoundaries, player, initEnemyAttack)) {
			_grpEnemyAttackBoundaries.forEach((Boundary:FlxObject) -> {
				var bound:Enemy.Boundaries = cast Boundary;
				bound.enemy.attacking = false;
			});
		};		

		_levelCollisions.overlapsWithCallback(player, preventSlopeCollisions);
	}	
}
