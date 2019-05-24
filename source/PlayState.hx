package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxSpriteUtil;
// NPC
import flixel.util.FlxColor;
// Typedefs
import GameLevel.CollMap;

class PlayState extends GameLevel {
	var _enemy:Enemy;
	var _score:Int;
	var _playerHealth:Float;
	var _playerReturning:Bool;
	var _levelCollectablesMap:CollMap;
	// Vars for NPC
	var _dialoguePrompt:DialoguePrompt;
	var _grpDialogueBox:DialogueBox;
	var _npcBoundary:FlxSprite;
	var _npc:FlxSprite;
	var _actionPressed:Bool = false;

	public var startingConvo:Bool = false;

	/**
	 * Level 1-0
	 *
	 * @param Score player score
	 * @param Health player health
	 * @param PlayerReturning player coming from a previous level
	 */
	public function new(Score:Int = 0, Health:Float = 3, CollectablesMap:CollMap = null, PlayerReturning = false):Void {
		super();
		_score = Score;
		_playerHealth = Health;
		_playerReturning = PlayerReturning;
		_levelCollectablesMap = CollectablesMap;
	}

	override public function create():Void {
		bgColor = 0xffc7e4db; // Game background color
		levelName = 'Level-1-0';

		createLevel("level-1-2", "mountains", _levelCollectablesMap);

		// NPC start
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
		_playerReturning ? createPlayer(Std.int(_level.width - 100), 680, true) : createPlayer(60, 600);

		// Adds Hud
		// If no socre has been bassed then pass 0
		createHUD(_score == 0 ? 0 : _score, player.health);
		super.create();
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);

		// Overlaps
		FlxG.overlap(player, _enemy, hitEnemy);
		FlxG.overlap(levelExit, player, fadeOut);

		if (!FlxG.overlap(player, _npcBoundary, initConvo)) {
			_actionPressed = false;
			_dialoguePrompt.hidePrompt();
		};
	}

	/**
	 * What happens when the player and the enemy collide
	 */
	function hitEnemy(Player:FlxSprite, Enemy:FlxObject):Void {
		if (Player.health > 1) {
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
		} else {
			// @todo play death animation
			var _pauseMenu:PauseMenu = new PauseMenu(true);
			openSubState(_pauseMenu);
		}

		grpHud.decrementHealth(Player.health);
	}

	function initConvo(Player:Player, Friend:FlxSprite):Void {
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

	function fadeOut(Player:FlxSprite, Exit:FlxSprite):Void {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}

	function changeState() {
		FlxG.switchState(new NextLevel(grpHud.gameScore, player.health, _levelCollectablesMap));
	}
}
