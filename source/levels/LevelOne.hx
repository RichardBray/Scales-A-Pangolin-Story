package levels;

import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxObject;

// Internal
import states.LevelState;
import states.IntroState;
// Typedefs
import Hud.GoalData;


class LevelOne extends LevelState {
	var _gameSave:FlxSave;
	var _seconds:Float = 0;
	var _goalData:Array<GoalData>;
	var _instructionsViewed:Bool = false;
	var _showInstrucitons:Bool;
	// Level complete goal
	var _levelComplete:FlxObject;
	var _playerCompletedLevel:Bool = false;

  final _bugsGoal:Int = 10;

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
				goal: 'Collect over $_bugsGoal bugs',
				func: (GameScore:Int) -> GameScore > _bugsGoal
			},
			{
				goal: 'Keep running right',
				func: (_) -> _playerCompletedLevel
			}			
		];
	}

	override public function create() {
		levelName = "Level-1-0";
	
		createLevel("level-1-0", "SCALES_BACKGROUND-01.png", "level_one");

		// Add player
		createPlayer(240, 1472, _gameSave);

		// Adds Hud
		// If no socre has been passed then pass 0
		createHUD(0, player.health, _goalData);

		// Proximity sounds
		createProximitySounds(); 		

		// Save game on load
		_gameSave = saveGame(_gameSave);

		_levelComplete = new FlxObject(11033, _map.fullHeight, 257, _map.fullHeight);
		add(_levelComplete);

		super.create();
	}

	function fadeOut(Player:FlxSprite, Exit:FlxSprite) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}

	function changeState() {
		_gameSave = saveGame(_gameSave, [grpHud.gameScore, 0]);
		FlxG.switchState(new LevelTwo(_gameSave));
	}

	/**
	 * Show instructions specific to this level unless they have already been viewed
	 */
	function showInstructions() {
		var _instructions:Instructions = new Instructions(1, 2, true, false);
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
		FlxG.overlap(_levelComplete, player, (_,_) -> _playerCompletedLevel = true);
	
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, fadeOut)
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
			"Pangolins are the most trafficked mammal in the world.",
			"Tens of thousands of them are poached and killed every year for their meat and scales.",
			"They love to eat bugs and are often called, 'the scaly anteater'. We join our hero doing – just that..."
		];		
	}

	override public function startLevel() {
		FlxG.switchState(new LevelOne(_gameSave, true));
	}
}
