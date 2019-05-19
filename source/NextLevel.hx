package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class NextLevel extends GameLevel {
	var _score:Int;
	var _playerHealth:Float;
	var _levelEntry:FlxSprite;

	/**
	 * New level
	 *
	 * @param Score player score
	 * @param Health player health
	 */
	public function new(Score:Int, Health:Float):Void {
		super();
		_score = Score;
		_playerHealth = Health;
	}

	override public function create():Void {
		bgColor = 0xffc7e4db; // Game background color
		createLevel("level-1-3", "mountains", true);

		// Add player
		createPlayer(60, 600);

		// Add HUD
		js.Browser.console.log(_score, '_score');
		createHUD(_score, _playerHealth);              


		super.create();
	}

	override public function update(Elapsed:Float):Void {
		super.update(Elapsed);
		FlxG.overlap(levelExit, player, goToMainMenu);
	}

	function goToMainMenu(Player:FlxSprite, Exit:FlxSprite) {
		// @todo create main menu
		FlxG.switchState(new MainMenu(grpHud.gameScore, player.health));
	}	
}
