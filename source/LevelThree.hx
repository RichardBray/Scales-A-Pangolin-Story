package;

import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.FlxG;
// Typedefs
import HUD.GoalData;


class LevelThree extends LevelState {
  var _goalData:Array<GoalData>;
	var _gameSave:FlxSave;
  var _bugsGoal:Int = 15; // How many bugs to collect in order to complete level  

  public function new(?GameSave:Null<FlxSave>) {
    super();

		_goalData = [
			{
				goal: 'Collect over $_bugsGoal bugs',
				func: (GameScore:Int) -> GameScore > _bugsGoal
			},
			{
				goal: "Jump on 3 enemies",
				func: (_) -> killedEmenies > 2
			}      
		]; 

  }

  override public function create() {
    levelName = "Level-3-0";

    createLevel("level-3-0", "mountains");

		// Add player
		createPlayer(180, 1470);

    // Add HUD
    createHUD(0, player.health, _goalData);   
    super.create(); 
  }

  override public function update(elapsed:Float) {
    super.update(elapsed);
  }
}