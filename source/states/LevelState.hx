package states;

// - Flixel
import components.TermiteHill;
import flixel.util.FlxTimer;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tile.FlxBaseTilemap;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.tile.FlxTilemapExt;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.system.FlxSound;
// - Tiled
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;

import Hud.GoalData;
// - Components
import components.Lava;


class LevelState extends GameState {
	// Level
	var _mapEntities:FlxSpriteGroup;
	var _termiteHills:FlxSpriteGroup;
	var _map:Null<TiledMap>;
	var _mapObjects:TiledObjectLayer;
	var _mapProximitySounds:TiledObjectLayer;
	var _collisionImg:String;
	var _curTermiteHill:Null<TermiteHill>;
	var _grpMidCheckpoints:FlxTypedGroup<FlxObject>;
	final _firstTile:Int = 14; // ID of first collision tile, for some reason Tiled changes this
	// Player
	var _secondsOnGround:Float; // Used for feet collisions to tell how
	var _playerJumpPoof:Player.JumpPoof; 
	var _playerPushedByFeet:Bool; // Checl if player collisions are off because of feet
	var _upOnSlope:Bool = false; // Keep feet collisions up from ground when on slope
	var _playerTouchMovingEnemy:Bool = false; // Hacky way to prevent player for losing two lives on one hit
	var _playerJustHitEnemy:Bool = false; // Used to check if player just hit the enemy for jumpPoof
	var _enemyJustHit:Bool = false; // To pervent enemy from being hit multiple times per second
	var _playerInvincible:Bool = false; // Make player invincible after they've just been hit
	// HUD
	var _enemyDeathCounterExecuted:Bool = false; // Used to count enemy detahs for goals
	// Enemies
	var _grpEnemyAttackBoundaries:FlxTypedGroup<FlxObject>;
	var _grpCollectables:FlxTypedGroup<CollectableBug.Bug>;
	var _grpEnemies:FlxTypedGroup<Enemy>;
	var _grpKillableEnemies:FlxTypedGroup<Enemy>;
	var _levelCollisions:FlxTilemapExt;	
	// Game saving
	var _levelCompleteSave:Bool = false;
	var _gameSaveForPause:FlxSave;
	// Sounds
	var _sndLevelIntro:FlxSound;
	//Controls
	var _controls:Controls;

	public var grpHud:Hud;
	public var player:Player; // used by HUD for health
	public var playerFeetCollision:FlxObject;
	public var levelExit:FlxSprite; // used by LevelOne
	public var startingConvo:Bool = false; // Used for toggling view for convo with NPC
	public var levelName:String; // Give level unique name
	public var killedEmenies:Int = 0; // Tells level how many enemies have died for goals
	public var levelBgs:FlxTypedGroup<FlxSprite>; // Hide background on bonus levels

	override public function create() {
		bgColor = 0xffBDEDE1; // Game background color
		super.create();
	
		// Continue music if it's already playing
		if (FlxG.sound.music == null) playMusic("assets/music/jungle-sound.ogg");

		if (_map != null) {
			/**
			* By default flixel only processes what it initally sees, so collisions won't
			* work until can process the whole level.
			*/
	
			FlxG.worldBounds.set(0, 0, _map.fullWidth, _map.fullHeight);
			FlxG.camera.setScrollBoundsRect(0, 0, _map.fullWidth, _map.fullHeight);
			FlxG.camera.antialiasing = false;

			// Camera follows Player
			FlxG.camera.follow(player, PLATFORMER, 1);
		}

		// Intialise controls
		_controls = new Controls();
	}

	/** PUBLIC FUNCTIONS **/

	/**
	 * Method for creating a level
	 *
	 * @param 	MapFile 		Comtains the name of the tmx data file used for the map.
	 * @param 	Background 	Parallax background image name.
	 * @param 	IntroMusic	What music to play for the into.
	 */
	public function createLevel(
		MapFile:String, 
		Background:String, 
		?IntroMusic:Null<String>
	) {
		// Tiles for collisions
		_collisionImg = "assets/images/collisions.png";

		// Load custom tilemap (up here because of background)
		if (_map == null) {
			_map = new TiledMap('assets/data/$MapFile.tmx');
		}

		// Code for parallax background

		/**
		 * This method creates the parallax background by dividing the length of the map 
		 * by the length of the sprite image. Then creating sprites for the amount of bg images needed.
		 */
		function renderBgSprites():FlxTypedGroup<FlxSprite> {
			var bgPath:String ='assets/images/backgrounds/$Background'; 
			var bgWidth:Float = new FlxSprite(0, 0, bgPath).width;
			var bgScale:Float = 1;
			var bgSpritesNeeded:Int = Std.int(_map.fullWidth / (bgWidth * bgScale));
			
			levelBgs = new FlxTypedGroup<FlxSprite>();
			// Fix for if level width is smaller than the bg width
			if (bgSpritesNeeded == 0) bgSpritesNeeded = 1;

			for (i in 0...bgSpritesNeeded) {
				var _levelBg:FlxSprite = new FlxSprite(((bgWidth * bgScale) * i), 400, bgPath);
				_levelBg.scale.set(bgScale, bgScale);
				_levelBg.scrollFactor.set(0.3, 1);
				levelBgs.add(_levelBg);
			}
			return levelBgs;
		}

		add(renderBgSprites());

		// Map objects initiated here.
		_mapEntities = new FlxSpriteGroup();
		_termiteHills = new FlxSpriteGroup();

		// Add bugs group
		_grpCollectables = new FlxTypedGroup<CollectableBug.Bug>();

		// Add standing enemies
		_grpEnemies = new FlxTypedGroup<Enemy>();	

		// Add killable enemies
		_grpKillableEnemies = new FlxTypedGroup<Enemy>();
		_grpEnemyAttackBoundaries = new FlxTypedGroup<FlxObject>();

		// Looping over `objects` layer
		_mapObjects = cast(_map.getLayer("objects"));
		for (e in _mapObjects.objects) {
			placeEntities(e.xmlData.x, e.gid);
		}

		// Map objects added here
		add(_mapEntities);
		add(_termiteHills);
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

		// set cloud/special tiles
		_levelCollisions.setTileProperties(_firstTile + 2, FlxObject.NONE, fallInClouds);
		_levelCollisions.alpha = 0; // Hide collision objects
		add(_levelCollisions);

		// Level exit
		levelExit = new FlxSprite((_map.fullWidth - 20), 0).makeGraphic(20, _map.fullHeight, FlxColor.TRANSPARENT);
		levelExit.immovable = true;
		add(levelExit);

		if (IntroMusic != null) {
			_sndLevelIntro = FlxG.sound.load('assets/sounds/intros/$IntroMusic.ogg', .65);
			_sndLevelIntro.play();			
		}
	}

	/**
	 * This method creates and adds the HUD to the level.
	 *
	 * @param Score		Player score at time of HUD creation, also used for `saveGame` method.
	 * @param Health	Player health value at time of HUD creation.
	 */

	public function createHUD(Score:Int, Health:Float, Goals:Array<GoalData>) {
		grpHud = new Hud(Score, Health, Goals);
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
		_playerJumpPoof = new Player.JumpPoof(X, Y);
		playerFeetCollision = new FlxObject(X, Y, 10, 72);
		playerFeetCollision.acceleration.y = Constants.worldGravity;
	
		if (FacingLeft) player.facing = FlxObject.LEFT;
		add(player);
		add(_playerJumpPoof);
		add(playerFeetCollision);
	}


	public function createProximitySounds() {
		final mapFile:String = levelName.toLowerCase();

		if (_map == null) {
			_map = new TiledMap('assets/data/$mapFile.tmx');
		}	
		_mapProximitySounds = cast(_map.getLayer("sounds"));

		for (e in _mapProximitySounds.objects) {
			final data:Xml = e.xmlData.x;
			final x:Float = Std.parseFloat(data.get("x"));
			final y:Float = Std.parseFloat(data.get("y"));
			final name:String = data.get("name");

			Helpers.playProximitySound(name, x, y, player);
		}			
	}

	/**
	 * Saves the game.
	 *
	 * @param GameSave	Save game data from level.
	 * @param EndData		Data to start level with, optional for save
	 */
	public function saveGame(GameSave:FlxSave, ?EndData:Array<Int>):FlxSave {
		grpHud.showSpinner();
		GameSave.data.levelName = levelName;
		if (EndData != null) {
			GameSave.data.totalBugs = EndData[0];
			GameSave.data.totalEnemies = EndData[1];
		}
		GameSave.flush();
		_gameSaveForPause = GameSave;
		return GameSave;
	}

	/**
	 * Adds up the saved bugs and enemis with the ones in the level.
	 * Only useful for levels with bugs and enemies.
	 *
	 * @param GameSave	Save game data from level
	 * @param Bugs	Number of bugs collected by the end of this level
	 * @param Enemies	Number of enemies squashed at the end of this level.
	 */
	public function endOfLevelSave(GameSave:FlxSave, Bugs:Int, Enemies:Int):Null<FlxSave> {
		if (!_levelCompleteSave) {
			var totalLevelScore:Int = GameSave.data.totalBugs + Bugs;
			var totalEnemyKills:Int = GameSave.data.totalEnemies + Enemies;

			// Prevent game from saving twice
			_levelCompleteSave = true;
			return saveGame(GameSave, [totalLevelScore, totalEnemyKills]);
		}	
		return saveGame(GameSave);	
	}

	/**
	 * Sets up and plays level music
	 *
	 * @param LevelMusic	String of music location
	 */
	public function playMusic(LevelMusic:String, Volume:Float = 0.4) {
		FlxG.sound.playMusic(LevelMusic, Volume, true); // .4
		FlxG.sound.music.persist = true;
	}

	/**
	 * Create all the mid checkpoint in levels
	 *
	 * @param MidCheckpoints coordinates from the levels 
	 */
  public function createMidCheckpoints(MidCheckpoints:Array<Array<Float>>) {
		_grpMidCheckpoints = new FlxTypedGroup<FlxObject>();
	
    MidCheckpoints.map((MidCheckpoint:Array<Float>) -> {
      final checkPoint:FlxObject = new FlxObject(MidCheckpoint[0], MidCheckpoint[1], 150, 600); 
      _grpMidCheckpoints.add(checkPoint);
    });

		add(_grpMidCheckpoints);
  }	

	/**
	 * Place entities from Tilemap.
	 * This method just converts strings to integers.
	 */
	function placeEntities(EntityData:Xml, ObjectId:Int) {
		final x:Float = Std.parseFloat(EntityData.get("x"));
		final y:Float = Std.parseFloat(EntityData.get("y"));
		final width:Int = Std.parseInt(EntityData.get("width"));
		final height:Int = Std.parseInt(EntityData.get("height"));
		final name:String = EntityData.get("name");
		final type:String = EntityData.get("type");
		createEntity(x, y, width, height, name, type, ObjectId);
	}

	/**
	 * Update map dimentions and level exit. Useful for bonuse levels.
	 * @param Width	Width amount to reduce from original width
	 * @param Height Height to reduce from original hegight
	 */
	function updateMapDimentions(Width:Float, Height:Float) {
		final newWidth:Float = _map.fullWidth - Width;
		final newHeight:Float = _map.fullHeight - Height;
		levelExit.x = newWidth - 20;
		FlxG.worldBounds.set(0, 0, newWidth, newHeight);
		FlxG.camera.setScrollBoundsRect(0, 0, newWidth, newHeight);
	}

	/**
	 * Utiolity function for returning image strings for level assets.
	 */
	static function createImageString(Image:String):String {
		return 'assets/images/environments/$Image.png';
	}

	/**
	 * Makes object to colider with `Player` in level.
	 */
	function createEntity(
		X:Float, 
		Y:Float, 
		Width:Int, 
		Height:Int, 
		Name:String,
		Otype:String, // Object type
		ObjectId:Int
	) {
		var newY:Float = (Y - Height);
		// @see https://code.haxe.org/category/beginner/maps.html
		var layerImage:Map<Int, String> = [
			1 => "assets/images/L1_ROCK_01.png",
			2 => "assets/images/L1_ROCK_02.png",
			3 => "assets/images/L1_ROCK_03.png",
			4 => "assets/images/L1_ROCK_04.png",
			5 => "assets/images/L1_TREE_01.png",
			6 => "assets/images/L1_TREE_02.png",
			7 => "assets/images/L1_TREE_03.png",
			8 => "assets/images/L1_GROUND_01.png",
			35 => LevelState.createImageString("L2_GROUND"),
			36 => LevelState.createImageString("L2_GROUND_TUNNEL"),
			33 => LevelState.createImageString("L1_LAVAROCK_01"),
			34 => LevelState.createImageString("L1_LAVAROCK_02")
		];
		if (ObjectId >= 9 && ObjectId <=11) {
			var bug:CollectableBug.Bug;
			if (ObjectId == 9) {
				bug = new CollectableBug.StagBeetle(X, newY, Name, Otype);
			} else if (ObjectId == 10) {
				bug = new CollectableBug.Beetle(X, newY, Name, Otype);
			} else { // (ObjectId == 11)
				bug = new CollectableBug.Caterpillar(X, newY, Name, Otype);
			}
			_grpCollectables.add(bug);

		} else if (ObjectId == 12) { // Fire
			var enemy:Enemy;
			enemy = new Enemy.Fire(X, newY);
			_grpEnemies.add(enemy);

		} else if (ObjectId == 32) { // Lava
			var lava:Lava = new Lava(X, newY);
			_mapEntities.add(lava);

		} else if (ObjectId == 13) { // Boar
			var boar:Enemy;
			boar = new Enemy.Boar(X, newY, Name, Otype);
			_grpKillableEnemies.add(boar);

		} else if (ObjectId == 37) { // Termite hill
			var termiteHill:TermiteHill = new TermiteHill(X, newY);
			termiteHill.immovable = true;
			_termiteHills.add(termiteHill);

		} else if (ObjectId == 39) { // Toucan
			var toucan:Enemy;
			toucan = new Enemy.Toucan(X, newY, Name, Otype);			
			_grpKillableEnemies.add(toucan);

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
		
		} else if (ObjectId == 40) { // BossBoar
			var bossBoar:Enemy;
			var bossBoarAttackBoundary:Enemy.Boundaries;

			bossBoar = new characters.BossBoar(X, newY, this);
			bossBoarAttackBoundary = new Enemy.Boundaries(676, 1140, FlxG.width, 430, bossBoar);

			bossBoar.boundaryLeft = new FlxPoint((676 + bossBoar.width), 1545);
			bossBoar.boundaryRight = new FlxPoint(((676 + FlxG.width) + bossBoar.width), 1545);

			_grpKillableEnemies.add(bossBoar);
			_grpEnemyAttackBoundaries.add(bossBoarAttackBoundary);

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
		if (!player.preventMovement) {
			if (_controls.down.check()) {
				player.playGoingDownSound();
				var timer = new FlxTimer();
				FallThroughTile.allowCollisions = FlxObject.NONE;
				timer.start(.1, (_) -> player.isGoindDown = true);	
			} else if (Player.y >= FallThroughTile.y) {
				FallThroughTile.allowCollisions = FlxObject.CEILING;
				player.isGoindDown = false;
			}
		}
	}

	function getCollectable(Collectable:CollectableBug.Bug, Player:Player) {
		if (Collectable.alive && Collectable.exists) {
			grpHud.incrementScore();
			Collectable.kill();
		}
	}

	/**
	 * Update player reset position when they OVERLAP a mid level checkpoint.
	 */
	function updatePlayerResetPos(MidLevelCheck:FlxObject, Player:Player) {
		Player.resetPosition = [MidLevelCheck.x, MidLevelCheck.y];
	}


	/**
	 * What happens when the player collides with moving enemy.
	 */
	function hitEnemy(Enemy:Enemy, Player:Player) {
		var playerAttacking:Bool = 
			Player.animation.name == Player.animationName("jumpLoop") && !Player.isAscending;

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
			Player.playHurtSound();
			FlxSpriteUtil.flicker(Player);
			_playerInvincible = true;
			// Make player invincible for one second
		}	

		/**
		* Animations and positions for when player hits enemy
		*
		* @param LastLife Used to prolongue death of character.
		*/	
		function playerAttackedAnims(?LastLife:Null<Bool> = false) {
			// Player is on the ground
			if (Player.isTouching(FlxObject.FLOOR)) {
				if (!_playerInvincible) playerHurt(LastLife);
				Player.animJump(Player.flipX); 
			} else { // Player is in the air
				if (!_enemyJustHit) {
					// when rolling animation is playing
					if (playerAttacking) {
						// Player bounce
						Player.velocity.y = Enemy.push;										
						_playerJustHitEnemy = true; // prevents smoke poof
						FlxG.camera.shake(0.00150, 0.25);
						Enemy.sndEnemyKill.play();
						Enemy.hurt(1);
						if (Enemy.health < 1) incrementDeathCount();							
					} else {
						// when rolling animation is NOT playing
						(Player.animation.name == Player.animationName("jumpLoop")) 
							? Player.animJump(Player.flipX)
							: Player.velocity.y = (Enemy.push / 3) * 2;
						if (!_playerInvincible) playerHurt(LastLife);
					}
					_enemyJustHit = true; // Prevent multiple hits per second					
				}
			}	
			grpHud.decrementHealth(LastLife ? 0 : Player.health);	
		}	

		if (!_enemyJustHit) {
			// Fix player dying on last life when they attack
			(Player.health == 1 && !playerAttacking && !_playerTouchMovingEnemy && !_playerInvincible) 
				? playerDeathASequence(Player, playerAttackedAnims)
				: playerAttackedAnims();
		}
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
			if (!_playerInvincible) {
				_playerInvincible = true;
				Enemy.kill(); // Change enemy alive variable temporarily
				Player.playHurtSound();
				if (!LastLife) Player.hurt(1);
				grpHud.decrementHealth((LastLife) ? 0 : Player.health);
				FlxSpriteUtil.flicker(Player); // Turn on flicker animation
			}
			Player.isTouching(FlxObject.FLOOR)
				? Player.animJump(Player.flipX)
				:	Player.velocity.y = Enemy.push;
		}

		if (Enemy.alive) { // Prevents enemy from dying
			(Player.health == 1 && !_playerInvincible) 
				? playerDeathASequence(Player, playerAttackedAnims)
				: playerAttackedAnims(); 
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
		Player.preventMovement = true;
		AttackAnims(true);
		timer.start(0.4, showGameOverMenu, 1);
	}

	function showGameOverMenu(_) {
		var _pauseMenu:PauseMenu = new PauseMenu(true, levelName, _gameSaveForPause);
		openSubState(_pauseMenu);
	}

	/**
	* This method updates the player of the feet collisions with the players.
	*/
	function updateFeetCollisions() {
		var xOffset:Int = player.facing == FlxObject.LEFT ? 80 : 25;
		var playerIsOnGround:Bool = player.isTouching(FlxObject.FLOOR);
		var feetCollisionIsOnGround:Bool = playerFeetCollision.isTouching(FlxObject.FLOOR);

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
		playerFeetCollision.setPosition(player.x + xOffset, player.y + yOffset);	
	}

	/**
	 * Controls when to show player jump poof shows and it hides.
	 */
	function handleJumpPoof() {
		var playerGoingUp:Bool = player.velocity.y < 0;

		// Used to check if player hit enemy to not show jump poof. Resets after player 1 second
		if (_playerJustHitEnemy && playerGoingUp) {
			haxe.Timer.delay(() -> _playerJustHitEnemy = false, 1000);
		}

		// Show jump poof when player jumps from the ground and not from an enemy jump
		if (
				(player.animation.name == player.animationName("jumpLoop"))
				&& playerGoingUp 
				&& !_playerJustHitEnemy
			) {
			_playerJumpPoof.show(
				player.jumpPosition[0], 
				player.jumpPosition[1] + player.height // Move lower than player
			);
		} else {
			_playerJumpPoof.hide();
		}
	}

	function digTermiteHill(Player:Player, TermiteHill:TermiteHill) {
		player.facingTermiteHill = TermiteHill.exists;
		_curTermiteHill = TermiteHill;
	}

	override public function update(Elapsed:Float) {
		_secondsOnGround += Elapsed;
		updateFeetCollisions();
		super.update(Elapsed);

		handleJumpPoof();

		// Hacky way to prevent player for losing two lives on one hit
		if (_playerTouchMovingEnemy) {
			haxe.Timer.delay(() -> _playerTouchMovingEnemy = false, 250);
		}

		// Reset player invincibility if it is true			
		if (_playerInvincible) {
			haxe.Timer.delay(() -> _playerInvincible = false, 1000);
		}

		// Hacky way to prevent enemy being hit multiple times per second
		if (_enemyJustHit) {
			var timer:FlxTimer = new FlxTimer();
			timer.start(.4, (_) -> _enemyJustHit = false, 1);
		}

		// Reset player pos to last mid checkpoint
		if (player.y > _map.fullHeight) player.resetPlayer();

		// Paused game state
		if (_controls.start.check()) {
			// SubState needs to be recreated here as it will be destroyed
			var _pauseMenu:PauseMenu = new PauseMenu(false, levelName, _gameSaveForPause);
			openSubState(_pauseMenu);
		}

		// Termite hill statements
		if (player.playerIsDigging == true) {
			_curTermiteHill.playerDigging = true;
		}

		// Collisions
		FlxG.collide(player, _levelCollisions);
		FlxG.collide(player, _termiteHills, digTermiteHill);
		FlxG.collide(playerFeetCollision, _levelCollisions);

		// Only add level collisions to specific enemies
		_grpKillableEnemies.forEach((member:Enemy) -> {
			if (member.hasCollisions) FlxG.collide(member, _levelCollisions);
		});

		// Overlaps
		FlxG.overlap(_grpEnemies, player, hitStandingEnemy);
		FlxG.overlap(_grpKillableEnemies, player, hitEnemy);
		FlxG.overlap(_grpCollectables, player, getCollectable);
		FlxG.overlap(_grpMidCheckpoints, player, updatePlayerResetPos);
		FlxG.overlap(_grpEnemyAttackBoundaries, player, initEnemyAttack);

		if (!FlxG.overlap(_grpEnemyAttackBoundaries, player, initEnemyAttack)) {
			_grpEnemyAttackBoundaries.forEach((Boundary:FlxObject) -> {
				var bound:Enemy.Boundaries = cast Boundary;
				bound.enemy.attacking = false;
			});
		};		
	}	
}
