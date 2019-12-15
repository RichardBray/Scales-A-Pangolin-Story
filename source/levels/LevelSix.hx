package levels;

import states.LevelState;
import flixel.util.FlxSave;

import components.MovingCage;

import Hud.GoalData;

class LevelSix extends LevelState {
  var _gameSave:FlxSave;
  var _goalData:Array<GoalData>;
  var _movingCage1:MovingCage;


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

    // Pango should be attached by this level
    player.pangoAttached = true;

    // Reset after falling through level or getting caught in cage  
    player.resetPosition = [465, 1447];

    _movingCage1 = new MovingCage(
      3993, 
      1368, 
      null, 
      player, 
      playerFeetCollision);
    add(_movingCage1);
    // Add HUD
    createHUD(0, player.health, _goalData);  

    // Save game on load
		_gameSave = new FlxSave(); // initialize
		_gameSave.bind("AutoSave"); // bind to the named save slot  
    _gameSave = saveGame(_gameSave);  

    super.create();       
 }  

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
  } 
}