package;

import flixel.util.FlxSave;
import flixel.FlxG;
// Typedefs
import HUD.GoalData;
class LevelTwo extends LevelState {
  var _goalData:Array<GoalData>;
  
  /**
  * Level 2-0
  *
	* @param GameSave					Loaded game save
	* @param ShowInstructions	Show level insturctions  
  */
  public function new(
		?GameSave:Null<FlxSave>,
		ShowInstructions:Bool = false    
  ) {
    super();

		_goalData = [
			{
				goal: "Collect over 15 bugs",
				func: (GameScore:Int) -> GameScore > 1
			},
			{
				goal: "Jump on 3 enemies",
				func: (GameScore:Int) -> GameScore > 1
			}      
		];    
  }

  override public function create() {
    levelName = "Level-2-0";

    createLevel("level-2-0", "mountains");

		// Add player
		createPlayer(180, 1470);

    // Add HUD
    createHUD(0, player.health, _goalData);   
    super.create(); 
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
  }
}

class IntroTwo extends IntroState {
  
  public function new(GameSave:FlxSave) {
    super();
    _gameSave = GameSave;
		facts = [
			"Pangolin's are covered with hard, brown scales made of keratin the same substance as human nails.",
			"Their scales cover their whole body except their forehead, belly and the inner side of their legs.",
			"Curling into a ball exposing a pangolin's sharp scales defending it against predators."
		];
  }

	override public function startLevel() {
		FlxG.switchState(new LevelTwo(_gameSave, true));
	}  
}