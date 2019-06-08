package;

import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
// NPC
import flixel.util.FlxColor;
// Typedefs
import GameLevel.CollMap;

class LevelOne extends GameLevel {
	var _enemy:Enemy;
	var _score:Int;
	var _playerHealth:Float;
	var _playerReturning:Bool;
	var _levelCollectablesMap:CollMap;
	var _gameSave:FlxSave;
	var _testNPC:NPC;

	/**
	 * Level 1-0
	 *
	 * @param Score player score
	 * @param Health player health
	 * @param PlayerReturning player coming from a previous level
	 */
	public function new(Score:Int = 0, Health:Float = 3, ?CollectablesMap:Null<CollMap>, PlayerReturning:Bool = false, ?GameSave:FlxSave):Void {
		super();
		_score = Score;
		_playerHealth = (Health != 3) ? Health : 3;
		_playerReturning = PlayerReturning;
		_levelCollectablesMap = (CollectablesMap == null) ? ["Level-1-0" => [], "Level-1-A" => []] : CollectablesMap;
		_gameSave = GameSave;
	}

	override public function create():Void {
		levelName = 'Level-1-0';

		gameMusic = FlxG.sound.load("assets/music/music.ogg");
		gameMusic.looped = true;
		gameMusic.persist = true;
		gameMusic.volume = 0; // @todo remove in release
		gameMusic.play(false, 0, 60000);

		createLevel("level-1-2", "mountains", _levelCollectablesMap);

		// Add NPC
		// Friend dialogue box
		var testText:Array<String> = [
			"Hello friend!",
			"Welcome to a spuer early build of the Pangolin game.",
			"Nothing is finalised, the art assets, gameplay mechanics, even the sound effects.",
			"Right now all you can do is collect <pt>purple bugs<pt>, but we're hoping to have loads more done soon.",
			"Until then, have fun :)"
		];		
		_testNPC = new NPC(870, 510, testText, this);
		add(_testNPC);
	
		// Add enemy
		_enemy = new Enemy(1570, 600);
		add(_enemy);

		// Add player
		_playerReturning ? createPlayer(Std.int(_level.width - 150), 680, true) : createPlayer(60, 600);
		// Update the player helth from the previous level
		player.health = _playerHealth;

		// Adds Hud
		// If no socre has been bassed then pass 0
		createHUD(_score == 0 ? 0 : _score, player.health);

		if (_gameSave != null && _playerReturning) saveGame(_gameSave);

		super.create();
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);

		// Overlaps
		FlxG.overlap(player, _enemy, hitEnemy);
		FlxG.overlap(levelExit, player, fadeOut);

		if (!FlxG.overlap(player, _testNPC, _testNPC.initConvo)) {
			actionPressed = false;
			_testNPC.dialoguePrompt.hidePrompt();
		};
	}

	function fadeOut(Player:FlxSprite, Exit:FlxSprite):Void {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}

	function changeState() {
		FlxG.switchState(new LevelOneA(grpHud.gameScore, player.health, _levelCollectablesMap, gameMusic, _gameSave));
	}
}
