package levels;


import flixel.util.FlxSave;
import states.LevelState;

import Hud.GoalData;

class LevelFive extends LevelState {
  var _gameSave:FlxSave;
  var _goalData:Array<GoalData>;

  public function new(?GameSave:Null<FlxSave>) {
    super();
    _gameSave = GameSave;

		_goalData = [
			{
				goal: "Save the pangolin",
				func: (_) -> false
			}
		];    
  }

  override public function create() {
    levelName = "Level-5-0";

    // TODO: Make music for level five
    createLevel("level-5-0", "SCALES_BACKGROUND-01.png", "level_one");

		// Add player
		createPlayer(172, 1439);  

    createHUD(0, player.health, _goalData);  

    // Save game on load
    // if (_gameSave != null) _gameSave = saveGame(_gameSave);
    super.create();
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
  }
}