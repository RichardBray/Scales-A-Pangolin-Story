package;

import flixel.util.FlxSave;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
// Typedefs
import GameLevel.CollMap;

class LevelOneA extends GameLevel {
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
	public function new(Score:Int, Health:Float, CollectablesMap:CollMap, ?LevelMusic:Null<FlxSound>, ?GameSave:Null<FlxSave>):Void {
		super();
		_score = Score;
		_playerHealth = Health;
		_levelCollectablesMap = CollectablesMap;
		_gameSave = GameSave;
	}

	override public function create():Void {
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
		createHUD(_score, _playerHealth);

		// Saves game
		_gameSave = saveGame(_gameSave);
		super.create();
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);
		FlxG.overlap(levelExit, player, goToMainMenu);
		FlxG.overlap(_levelEntry, player, fadeOut);
	}

	function goToMainMenu(Exit:FlxSprite, Player:Player) {
		FlxG.switchState(new LevelEnd(grpHud.gameScore));
	}

	function fadeOut(Exit:FlxSprite, Player:Player):Void {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}

	function changeState() {
		FlxG.switchState(new LevelOne(grpHud.gameScore, player.health, _levelCollectablesMap, true, _gameSave));
	}
}
