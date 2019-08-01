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
import HUD.GoalData;


class LevelOne extends LevelState {
	var _score:Int;
	var _playerHealth:Float;
	var _levelCollectablesMap:CollMap;
	var _gameSave:FlxSave;
	var _seconds:Float = 0;
	// var _npcSprite:FlxSprite;
	var _testNPC:NPC;
	var _goalData:Array<GoalData>;
	var _instructionsViewed:Bool = false;
	var _showInstrucitons:Bool;

	/**
	 * Level 1-0
	 *
	 * @param Score 						Player score
	 * @param Health 						Player health
	 * @param CollectablesMap		Collecables map from other parts of the level
	 * @param GameSave					Loaded game save
	 * @param ShowInstructions	Show level insturctions
	 */
	public function new(
		Score:Int = 0, 
		Health:Float = 3, 
		?CollectablesMap:Null<CollMap>, 
		?GameSave:Null<FlxSave>,
		ShowInstructions:Bool = false
	) {
		super();
		_score = Score;
		_playerHealth = (Health != 3) ? Health : 3;
		_levelCollectablesMap = (CollectablesMap == null) ? Constants.initialColMap() : CollectablesMap;
		_gameSave = GameSave;
		_showInstrucitons = ShowInstructions;

		_goalData = [
			{
				goal: "Collect at least 20 bugs",
				func: (GameScore:Int) -> GameScore > 19
			}
		];
	}

	override public function create() {
		levelName = "Level-1-0";

		createLevel("level-1-0", "mountains", _levelCollectablesMap);

		// Add NPC Text
		// var testText:Array<String> = [
		// 	"Hello friend!",
		// 	"Welcome to a spuer early build of the Pangolin game.",
		// 	"Nothing is finalised, the art assets, gameplay mechanics, even the sound effects.",
		// 	"Right now all you can do is collect <pt>purple bugs<pt>, but we're hoping to have loads more done soon.",
		// 	"Until then, have fun :)"
		// ];

		// Add NPC
		// _npcSprite = new FlxSprite(870, 510).makeGraphic(50, 50, 0xff205ab7);
		// _testNPC = new NPC(870, 510, testText, _npcSprite, this);
		// add(_testNPC);

		// Add player
		createPlayer(240, 1472);
		// Update the player helth from the previous level
		player.health = _playerHealth;

		// Adds Hud
		// If no socre has been bassed then pass 0
		createHUD(_score == 0 ? 0 : _score, player.health, _goalData);

		// Save game on load
		// _gameSave = saveGame(_gameSave);

		super.create();
	}

	override public function update(Elapsed:Float) {
		super.update(Elapsed);
		_seconds += Elapsed;

		// Show instructions at start of level
		if (_showInstrucitons) {
			if (_seconds > 0.5 && !_instructionsViewed) showInstructions();
		}

		// Overlaps
		if (grpHud.goalsCompleted) {
			FlxG.overlap(levelExit, player, fadeOut);
		} else {
			FlxG.collide(levelExit, player);
		}

		// if (!FlxG.overlap(player, _testNPC.npcSprite.npcBoundary, _testNPC.initConvo)) {
		// 	actionPressed = false;
		// 	_testNPC.dialoguePrompt.hidePrompt();
		// };
	}

	function fadeOut(Player:FlxSprite, Exit:FlxSprite) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}

	function changeState() {
		// FlxG.switchState(new LevelOneA(grpHud.gameScore, player.health, _levelCollectablesMap, _gameSave));
		FlxG.switchState(new LevelEnd(grpHud.gameScore, levelName, _gameSave));
	}

	/**
	 * Show instructions specific to this level unless they have already been viewed
	 */
	function showInstructions() {
		var _instructions:Instructions = new Instructions(1, 2);
		if (!_instructions.menuViewed) openSubState(_instructions);
		_instructionsViewed = true;
	}		
}

class Intro extends GameState {
	var _facts:Array<String>;
	var _factText:FlxText;
	var _factNumber:Int = 0;
	var _gameSave:FlxSave;
	var _timer:FlxTimer;
	var _seconds:Float = 0;
	var _controls:Controls;
	var _textWidth:Int = 600;

	/**
	 * Runs the intro sequence for the first level.
	 *
	 * @param GameSave	Game save from `MainMenu.hx`
	 */
	public function new(GameSave:FlxSave) {
		super();
		_gameSave = GameSave;
	}

	override public function create() {
		bgColor = FlxColor.BLACK;

		// @todo, this will be passed into the Intro Class as a variable in the future
		_facts = [
			"Pangolins are the most trafficked mammal in the world, between 2011 and 2013 around 117 million of them were killed.",
			"They're in high demand from places like China and Vietnam for their meat and scales.",
			"They love to eat bugs and are often called, 'the scaly anteater'. We join our hero doing – just that..."
		];

		_factText = new FlxText(
			(FlxG.width / 2) - (_textWidth / 2), 
			(FlxG.height / 2) - 100, 
			_textWidth, 
			_facts[_factNumber], 
			33
		);

		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // Level fades in
		add(_factText);	
		_factText.alpha = 0;
		_controls = new Controls();		
	}	

	override public function update(Elapsed:Float) {
		super.update(Elapsed);
		_seconds += Elapsed;	
	
		// Starts level when all the facts have been looped through
		(_factNumber == _facts.length) ? startLevel() : showFacts();

		// Start level if player presses start
		if ( _controls.start.check()) startLevel();
	}

	function showFacts() {
		_factText.text = _facts[_factNumber];
		var showFor:Int = 4; // How many seconds the text should show for
	 
		if (_seconds < showFor) {
			FlxTween.tween(_factText, { alpha: 1 }, .5);
		} else if (_seconds > (showFor + 1) && _seconds < (showFor + 2)) {
			FlxTween.tween(_factText, { alpha: 0 }, .5);
		} else if (Math.round(_seconds) == (showFor + 3)) {
			_seconds = 0;
			_factNumber++;
		}				
	}

	function startLevel() {
		FlxG.switchState(new LevelOne(0, 3, null, _gameSave, true));
	}
}
