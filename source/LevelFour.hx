package;

import flixel.util.FlxSave;

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
			}           
		]; 

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
  }
}