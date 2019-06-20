package;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
// NPC
import flixel.util.FlxColor;
// Typedefs
import LevelState.CollMap;

using Lambda;

class LevelOne extends LevelState {
	var _enemy:Enemy;
	var _score:Int;
	var _playerHealth:Float;
	var _playerReturning:Bool;
	var _levelCollectablesMap:CollMap;
	var _gameSave:FlxSave;
	var _npcSprite:FlxSprite;
	var _testNPC:NPC;

	/**
	 * Level 1-0
	 *
	 * @param Score 			Player score
	 * @param Health 			Player health
	 * @param CollectablesMap	Collecables map from other parts of the level
	 * @param PlayerReturning 	Player coming from a previous level
	 * @param GameSave			Loaded game save
	 */
	public function new(Score:Int = 0, Health:Float = 3, ?CollectablesMap:Null<CollMap>, PlayerReturning:Bool = false, ?GameSave:Null<FlxSave>):Void {
		super();
		_score = Score;
		_playerHealth = (Health != 3) ? Health : 3;
		_playerReturning = PlayerReturning;
		_levelCollectablesMap = (CollectablesMap == null) ? ["Level-1-0" => [], "Level-1-A" => []] : CollectablesMap;
		_gameSave = GameSave;
	}

	override public function create():Void {
		levelName = 'Level-1-0';

		createLevel("level-1-2", "mountains", _levelCollectablesMap);

		// Add NPC Text
		var testText:Array<String> = [
			"Hello friend!",
			"Welcome to a spuer early build of the Pangolin game.",
			"Nothing is finalised, the art assets, gameplay mechanics, even the sound effects.",
			"Right now all you can do is collect <pt>purple bugs<pt>, but we're hoping to have loads more done soon.",
			"Until then, have fun :)"
		];

		// Add NPC
		_npcSprite = new FlxSprite(870, 510).makeGraphic(50, 50, 0xff205ab7);
		_testNPC = new NPC(870, 510, testText, _npcSprite, this);
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

		if (_playerReturning) {
			_gameSave = saveGame(_gameSave);
		};

		super.create();
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);

		// Overlaps
		FlxG.overlap(player, _enemy, hitEnemy);
		FlxG.overlap(levelExit, player, fadeOut);

		if (!FlxG.overlap(player, _testNPC.npcSprite.npcBoundary, _testNPC.initConvo)) {
			actionPressed = false;
			_testNPC.dialoguePrompt.hidePrompt();
		};
	}

	function fadeOut(Player:FlxSprite, Exit:FlxSprite):Void {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}

	function changeState() {
		FlxG.switchState(new LevelOneA(grpHud.gameScore, player.health, _levelCollectablesMap, _gameSave));
	}
}

class Intro extends GameState {
	var _facts:Array<String>;
	var _factText:FlxText;
	var _factNumber:Int = 0;
	var _gameSave:FlxSave;
	var _timer:FlxTimer;

	/**
	 * Runs the intro sequence for the first level.
	 *
	 * @param GameSave	Game save from `MainMenu.hx`
	 */
	public function new(GameSave:FlxSave):Void {
		super();
		_gameSave = GameSave;
	}

	override public function create():Void {
		bgColor = FlxColor.BLACK;
		_timer = new FlxTimer();
		_facts = [
			'While they are a potent defence against predators, their scales are useless against poachers.',
			'and all eight species in Asia and Africa are now under threat'
		];
		_factText = new FlxText(0, 0, 600, _facts[0], 33);
		add(_factText);	
		_factText.alpha = 0;		
	}	

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);

		_facts.map((Fact:String) -> {
			showFact();
		});

		if (_factNumber == _facts.length) {
			FlxG.switchState(new LevelOne(0, 3, null, false, _gameSave));
		}
	}

	function showFact():Void {
		FlxTween.tween(_factText, {alpha: 1}, 2, {onComplete: hideAndIncrementFact });
	}

	function hideAndIncrementFact(_) {
		FlxTween.tween(_factText, {alpha: 0}, 2, {onComplete: (_) -> 	{
				trace(_factNumber);
				_factText.text = _facts[_factNumber];
				// _factNumber++;
			}
		});		
	}
}
