package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxPoint;
// NPC
import flixel.util.FlxColor;
// Imports for map
// - Tiled
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledObjectLayer;
// - Flixel
import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.graphics.frames.FlxTileFrames;

class PlayState extends FlxState {
	var _txtScore:FlxText;
	var _score:Int = 0;
	var _grpBugs:FlxTypedGroup<CollectableBug>;
	var _justDied:Bool = false; // Will be used later
	var _enemy:Enemy;
	// Vars for NPC
	var _dialoguePrompt:DialoguePrompt;
	var _grpDialogueBox:DialogueBox;
	var _npcBoundary:FlxSprite;
	var _npc:FlxSprite;
	// Vars for map
	var _level:FlxTilemap;
	var _levelCollisions:FlxTilemapExt;
	var _map:TiledMap;
	var _mapObjects:TiledObjectLayer;
	var _mapTrees:TiledObjectLayer;
	var _mapEntities:FlxSpriteGroup;
	var _actionPressed:Bool = false;
	var _mountains:FlxSprite;
	// Pause menue
	var _pauseMenu:PauseMenu;

	public var startingConvo:Bool = false;
	public var player:Player;
	public var grpHud:HUD;

	override public function create():Void {
		FlxG.mouse.visible = true; // Hide the mouse cursor
		bgColor = 0xffc7e4db; // Game background color

		/**
		 * Code for adding the environment and collisions
		 */

		_mountains = new FlxSprite(0, 400, "assets/images/mountains.png");
		_mountains.scale.set(4.5, 4.5);
		_mountains.alpha = 0.75;
		_mountains.scrollFactor.set(.2, 1);
		add(_mountains);

		// Load custom tilemap
		_map = new TiledMap("assets/data/level-1-2.tmx");

		// Map objects initiated here.
		_mapEntities = new FlxSpriteGroup();

		// Add bugs group
		_grpBugs = new FlxTypedGroup<CollectableBug>();

		_level = new FlxTilemap();
		_level.loadMapFromArray(cast(_map.getLayer("ground"), TiledTileLayer).tileArray, _map.width, _map.height, "assets/images/ground-collisions.png",
			_map.tileWidth, _map.tileHeight, FlxTilemapAutoTiling.OFF, 1);

		// tile tearing problem fix on Mac
		// @see https://github.com/HaxeFlixel/flixel-demos/blob/master/Platformers/FlxTilemapExt/source/PlayState.hx#L48
		var levelTiles = FlxTileFrames
			.fromBitmapAddSpacesAndBorders("assets/images/ground-collisions.png", new FlxPoint(10, 10), new FlxPoint(2, 2), new FlxPoint(2, 2));
		_level.frames = levelTiles;
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
		_levelCollisions.follow(); // lock camera to map's edges

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
		FlxG.camera.antialiasing = true;

		// CHARACRERS!!!

		// NPC start
		// Want the npc behind the rocks
		_npcBoundary = new FlxSprite(820, 510).makeGraphic(150, 50, FlxColor.TRANSPARENT);
		add(_npcBoundary);
		_npc = new FlxSprite(870, 510).makeGraphic(50, 50, 0xff205ab7);
		add(_npc);

		// Friend Dialogue Bubble
		_dialoguePrompt = new DialoguePrompt(120, 820 + (150 / 2), 390, "Press Z");
		add(_dialoguePrompt);

		// Friend dialogue box
		var testText:Array<String> = [
			"Hey friend slow down!",
			"Wow, I've never seen a Pangolin run and jump as fast as you before.",
			"Say–maybe you could do me a favour?",
			"If you bring me <pt>14 tasty bugs<pt>, I could give you some interesintg things I've found around the jungle."
		];
		_grpDialogueBox = new DialogueBox(testText, this);
		add(_grpDialogueBox);
		// NPC end

		// Add enemy
		_enemy = new Enemy(1570, 600);
		add(_enemy);

		// Add player
		player = new Player(60, 600);
		add(player);

		// Add Hud
		grpHud = new HUD(this);
		add(grpHud);

		// Add pause menu
		_pauseMenu = new PauseMenu();
		add(_pauseMenu);

		// Player Camera
		FlxG.camera.follow(player, PLATFORMER, 1);

		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// Reset the game if the player goes higher/lower than the map
		if (player.y > _level.height) {
			_justDied = true;
			FlxG.resetState();
		}

		// Pause button
		if (FlxG.keys.anyJustReleased([ESCAPE])) {
			_pauseMenu.gamePaused ? _pauseMenu.toggle(0) : _pauseMenu.toggle(1);
			js.Browser.console.log('Pause menu');
		}
		// Collisions
		FlxG.collide(player, _levelCollisions);

		// Overlaps
		FlxG.overlap(player, _enemy, hitEnemy);
		FlxG.overlap(_grpBugs, player, getBug);

		if (!FlxG.overlap(player, _npcBoundary, initConvo)) {
			_actionPressed = false;
			_dialoguePrompt.hidePrompt();
		};
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

		grpHud.decrementHealth();
	}

	private function initConvo(Player:Player, Friend:FlxSprite):Void {
		if (Player.isTouching(FlxObject.FLOOR)) {
			if (!_actionPressed) {
				// show press e prompt
				_dialoguePrompt.showPrompt();
			}

			if (FlxG.keys.anyPressed([Z])) {
				_actionPressed = true;
				if (!startingConvo) {
					// hide dialogue bubble
					_dialoguePrompt.hidePrompt(true);
					// zoom camera
					FlxTween.tween(FlxG.camera, {zoom: 1.1}, 0.2, {
						onComplete: (_) -> {
							startingConvo = true;
							// show dialogue box
							_grpDialogueBox.showBox();
						}
					});
					// prevent character movement
					Player.preventMovement = true;

					// hide HUD
					grpHud.toggleHUD(0);
				} else {
					// unzoom camera
					FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {
						onComplete: (_) -> startingConvo = false
					});
					// hide dialogue box
					_grpDialogueBox.hideBox();

					// allow character movement
					Player.preventMovement = false;
					// show HUD
					grpHud.toggleHUD(1);
				}
			}
		}
	}

	private function getBug(Bug:FlxObject, Player:FlxObject):Void {
		if (Bug.alive && Bug.exists) {
			grpHud.incrementScore();
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
