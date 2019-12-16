package levels;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSave;

import states.LevelState;
import components.MovingCage;

import Hud.GoalData;

class LevelSix extends LevelState {
  var _gameSave:FlxSave;
  var _goalData:Array<GoalData>;
  var _allCages:FlxTypedGroup<MovingCage>;

  final _allMovingCages:Array<Array<Dynamic>> = [
    [3993, 1368, false],
    [8106, 1369, false],
    [9773, 887, true],
    [10559, 1292, false]
  ];


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

    _allCages = new FlxTypedGroup<MovingCage>();
    
    add(_allCages);

    _allMovingCages.map((movingCage:Array<Dynamic>) -> {
      var _movingCage:MovingCage = new MovingCage(
        movingCage[0], 
        movingCage[1], 
        movingCage[2], 
        player, 
        playerFeetCollision);
  
      _allCages.add(_movingCage);
    });

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