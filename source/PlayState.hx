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
	var _player:Player;
	var _grpBugs:FlxTypedGroup<CollectableBug>;
	var _justDied:Bool = false; // Will be used later
	var _enemy:Enemy;
	var _grpHud:FlxTypedGroup<FlxSprite>;
	// Vars for NPC
	var _dialoguePrompt:DialoguePrompt;
	var _grpDialogueBox:DialogueBox;
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
	var startingConvo:Bool = false;
	var ePressed:Bool = false;

	override public function create():Void {
		FlxG.mouse.visible = true; // Hide the mouse cursor
		bgColor = 0xffc7e4db; // Game background color

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

		// Add friend
		// Want the friend behind the rocks
		_friend = new FlxSprite(820, 510).makeGraphic(150, 50, 0xff205ab7);
		add(_friend);

		// Friend Dialogue Bubble
		_dialoguePrompt = new DialoguePrompt(120, 820 + (150 / 2), 390, "Press Z");
		add(_dialoguePrompt);

		// Friend dialogue box
		var testText:Array<String> = [
			'Hey friend slow down!',
			'Wow, I"ve never seen a Pangolin run so fast before.',
			'Maybe you could do me a favour?'
		];
		_grpDialogueBox = new DialogueBox(testText);
		add(_grpDialogueBox);

		// Add enemy
		_enemy = new Enemy(1570, 600);
		add(_enemy);

		// Add player
		_player = new Player(60, 600);
		add(_player);

		// HUD!!!
		// Show score text
		_grpHud = new FlxTypedGroup<FlxSprite>();
		_txtScore = new FlxText(FlxG.width / 2, 40, 0, updateScore());
		_txtScore.setFormat(null, 24, 0xFF194869, FlxTextAlign.CENTER);
		_txtScore.scrollFactor.set(0, 0);
		_grpHud.add(_txtScore);

		// Hearts
		_hearts = new FlxSpriteGroup();
		_hearts.scrollFactor.set(0, 0);
		createHearts();
		_grpHud.add(_hearts);

		// Add Hud
		add(_grpHud);

		// Player Camera
		FlxG.camera.follow(_player, PLATFORMER, 1);

		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// Reset the game if the player goes higher/lower than the map
		if (_player.y > _level.height) {
			_justDied = true;
			FlxG.resetState();
		}

		// _grpDialogueBox.dialogueControls();
		// Collisions

		FlxG.collide(_player, _levelCollisions);

		// Overlaps
		FlxG.overlap(_player, _enemy, hitEnemy);
		FlxG.overlap(_grpBugs, _player, getBug);

		if (!FlxG.overlap(_player, _friend, initConvo)) {
			ePressed = false;
			_dialoguePrompt.hidePrompt();
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
			if (!ePressed) {
				// show press e prompt
				_dialoguePrompt.showPrompt();
			}

			if (FlxG.keys.anyPressed([Z])) {
				ePressed = true;
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
					_grpHud.forEach((member:FlxSprite) -> {
						member.alpha = 0;
					});
				} else {
					// show dialogue bubble
					FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {
						onComplete: (_) -> startingConvo = false
					});
					// hide dialogue box
					_grpDialogueBox.hideBox();

					// prevent character movement
					Player.preventMovement = false;
					// show HUD
					_grpHud.forEach((member:FlxSprite) -> {
						member.alpha = 1;
					});
				}
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
