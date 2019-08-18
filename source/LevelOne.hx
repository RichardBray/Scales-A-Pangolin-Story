package;

import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.FlxSprite;
// NPC
import flixel.util.FlxColor;
// Typedefs
import HUD.GoalData;


class LevelOne extends LevelState {
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
				goal: "Collect all 26 bugs",
				func: (GameScore:Int) -> GameScore > 25
			}
		];
	}

	override public function create() {
		levelName = "Level-1-0";

		createLevel("level-1-0", "mountains");

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

		// Adds Hud
		// If no socre has been bassed then pass 0
		createHUD(0, player.health, _goalData);

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
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, fadeOut)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);

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
		// FlxG.switchState(new LevelEnd(grpHud.gameScore, levelName, _gameSave));
		FlxG.switchState(new LevelTwo.IntroTwo(_gameSave));
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
