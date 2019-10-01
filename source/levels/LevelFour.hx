package levels;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.util.FlxSave;

// Internal
import states.LevelState;

// Typedefs
import HUD.GoalData;


class LevelFour extends LevelState {
  var _goalData:Array<GoalData>;
  var _gameSave:FlxSave;

  public function new(?GameSave:Null<FlxSave>) {
    super();
    _gameSave = GameSave;
  _goalData = [
			{
				goal: "Defeat the Leopard",
				func: (_) -> true
			},
			{
				goal: "Talk to saved pangolin",
				func: (_) -> true
			}                 
		]; 
  }

	function fadeOut(Player:FlxSprite, Exit:FlxSprite) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}	

	function changeState() {
		FlxG.switchState(new MainMenu());
	}	  

  override public function create() {
    levelName = "Level-4-0";

    createLevel("level-4-0", "jungle.jpg");

		// Add player
		createPlayer(118, 1004);

    // Add HUD
    createHUD(0, player.health, _goalData); 

    super.create();        
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);

		// Overlaps
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, fadeOut)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);    
  }
}