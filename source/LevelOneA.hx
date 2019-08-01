package;

import flixel.util.FlxSave;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
// Typedefs
import LevelState.CollMap;

class LevelOneA extends LevelState {
	var _score:Int;
	var _playerHealth:Float;
	var _levelEntry:FlxSprite;
	var _levelCollectablesMap:CollMap;
	var _gameSave:FlxSave;

	/**
	 * Level 1-1
	 *
	 * @param Score				Player score
	 * @param Health 			Player health
	 * @param CollectablesMap	Collecables map from other parts of the level
	 * @param LevelMusic		Game music if there is some
	 * @param GameSave			Loaded game save
	 */
	public function new(Score:Int, Health:Float, CollectablesMap:CollMap, ?LevelMusic:Null<FlxSound>, ?GameSave:Null<FlxSave>) {
		super();
		_score = Score;
		_playerHealth = Health;
		_levelCollectablesMap = CollectablesMap;
		_gameSave = GameSave;
	}

	override public function create() {
		bgColor = 0xffc7e4db; // Game background color
		levelName = 'Level-1-A';

		createLevel("level-1-3", "mountains", _levelCollectablesMap);

		// Block to take you back to previous level
		_levelEntry = new FlxSprite(1, 0).makeGraphic(1, FlxG.height, FlxColor.TRANSPARENT);
		add(_levelEntry);

		// Add player
		createPlayer(60, 600);
		// Update the player helth from the previous level
		player.health = _playerHealth;

		// Add HUD
		createHUD(_score, _playerHealth, null);

		// Saves game
		_gameSave = saveGame(_gameSave);
		super.create();
	}

	override public function update(Elapsed:Float) {
		super.update(Elapsed);
		FlxG.overlap(levelExit, player, goToMainMenu);
		FlxG.overlap(_levelEntry, player, fadeOut);
	}

	function goToMainMenu(Exit:FlxSprite, Player:Player) {
		FlxG.switchState(new LevelEnd(grpHud.gameScore, levelName, _gameSave));
	}

	function fadeOut(Exit:FlxSprite, Player:Player) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}

	function changeState() {
		FlxG.switchState(new LevelOne(grpHud.gameScore, player.health, _levelCollectablesMap, _gameSave));
	}
}
