package levels;

import states.LevelState;
import flixel.util.FlxSave;

import Hud.GoalData;

class LevelSix extends LevelState {
  var _gameSave:FlxSave;
  var _goalData:Array<GoalData>;

	public function new(?GameSave:Null<FlxSave>) {
		super();
		_gameSave = GameSave;

		_goalData = [
			{
				goal: "Collect 7 bugs",
				func: (_) -> false
			}
		];
	}

 override public function create() {
    levelName = "Level-6-0";

    // TODO: Make music for level six
    createLevel("level-6-0", "SCALES_BACKGROUND-01.png", "level_one");   

    // Add player
    createPlayer(465, 1447);

    // Add HUD
    createHUD(0, player.health, _goalData);  

    // Save game on load
		_gameSave = new FlxSave(); // initialize
		_gameSave.bind("AutoSave"); // bind to the named save slot  
    if (_gameSave != null) _gameSave = saveGame(_gameSave);  

    super.create();  

    // Pango should be attached by this level
    player.pangoAttached = true;       
 }  

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
  } 
}