package levels;

import screens.LevelComplete;
import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

// Internal
import states.LevelState;
import states.IntroState;
// Typedefs
import HUD.GoalData;


class LevelOne extends LevelState {
	var _gameSave:FlxSave;
	var _seconds:Float = 0;
	var _goalData:Array<GoalData>;
	var _instructionsViewed:Bool = false;
	var _showInstrucitons:Bool;

	/**
	 * Level 1-0
	 *
	 * @param GameSave					Loaded game save
	 * @param ShowInstructions	Show level insturctions
	 */
	public function new(
		?GameSave:Null<FlxSave>,
		ShowInstructions:Bool = false
	) {
		super();
		_gameSave = GameSave;
		_showInstrucitons = ShowInstructions;

		_goalData = [
			{
				goal: "Collect over 15 bugs",
				func: (GameScore:Int) -> GameScore > 14
			}
		];
	}

	override public function create() {
		levelName = "Level-1-0";
	
		createLevel("level-1-0", "jungle.jpg");

		// Add player
		createPlayer(240, 1472);

		// Adds Hud
		// If no socre has been bassed then pass 0
		createHUD(0, player.health, _goalData);

		// Save game on load
		_gameSave = saveGame(_gameSave);

		super.create();
	}

	function fadeOut(Player:FlxSprite, Exit:FlxSprite) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}

	function changeState() {
		_gameSave = saveGame(_gameSave, [grpHud.gameScore, 0]);
		FlxG.switchState(new LevelTwo(_gameSave));
	}

	function levelComplete(Player:FlxSprite, Exit:FlxSprite) {
		_gameSave = saveGame(_gameSave, [grpHud.gameScore, 0]);
		var _levelCompleteState:LevelComplete = new LevelComplete(_gameSave);
		openSubState(_levelCompleteState);			
	}	

	/**
	 * Show instructions specific to this level unless they have already been viewed
	 */
	function showInstructions() {
		var _instructions:Instructions = new Instructions(1, 2);
		if (!_instructions.menuViewed) openSubState(_instructions);
		_instructionsViewed = true;
	}	

	override public function update(Elapsed:Float) {
		super.update(Elapsed);
		_seconds += Elapsed;

		// Show instructions at start of level
		if (_showInstrucitons) {
			if (_seconds > 0.5 && !_instructionsViewed) showInstructions();
		}

		// Overlaps
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, levelComplete)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);
	}		
}

class Intro extends IntroState {

	/**
	 * Runs the intro sequence for the first level.
	 *
	 * @param GameSave Game save from `MainMenu.hx`
	 */
	public function new(GameSave:FlxSave) {
		super();
		_gameSave = GameSave;
		facts = [
			"Pangolins are the most trafficked mammal in the world, between 2011 and 2013 around 117 million of them were killed.",
			"They're in high demand from places like China and Vietnam for their meat and scales.",
			"They love to eat bugs and are often called, 'the scaly anteater'. We join our hero doing – just that..."
		];		
	}

	override public function startLevel() {
		FlxG.switchState(new LevelOne(_gameSave, true));
	}
}
