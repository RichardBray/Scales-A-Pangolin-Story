package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
// Typedefs
import GameLevel.CollMap;

class NextLevel extends GameLevel {
	var _score:Int;
	var _playerHealth:Float;
	var _levelEntry:FlxSprite;
	var _levelCollectablesMap:CollMap;

	/**
	 * Level 1-1
	 *
	 * @param Score player score
	 * @param Health player health
	 */
	public function new(Score:Int, Health:Float, CollectablesMap:CollMap):Void {
		super();
		_score = Score;
		_playerHealth = Health;
		_levelCollectablesMap = CollectablesMap;
	}

	override public function create():Void {
		bgColor = 0xffc7e4db; // Game background color
		levelName = 'Level-1-1';

		createLevel("level-1-3", "mountains", _levelCollectablesMap);

		// Block to take you back to previous level
		_levelEntry = new FlxSprite(1, 0).makeGraphic(1, 720, FlxColor.TRANSPARENT);
		add(_levelEntry);

		// Add player
		createPlayer(60, 600);
		// Update the player helth from the previous level
		player.health = _playerHealth;

		// Add HUD
		createHUD(_score, _playerHealth);

		super.create();
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);
		FlxG.overlap(levelExit, player, goToMainMenu);
		FlxG.overlap(_levelEntry, player, fadeOut);
	}

	function goToMainMenu(Player:FlxSprite, Exit:FlxSprite) {
		// @todo create main menu
		FlxG.switchState(new LevelEnd(grpHud.gameScore));
	}

	function fadeOut(Player:FlxSprite, Exit:FlxSprite):Void {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}

	function changeState() {
		FlxG.switchState(new PlayState(grpHud.gameScore, player.health, _levelCollectablesMap, true));
	}
}
