package levels;

import flixel.FlxG;
import flixel.util.FlxColor;
import screens.LevelComplete;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSave;
import flixel.FlxSprite;

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

  final _allMidCheckpoints:Array<Array<Float>> = [
    [3479.92, 1424.54],
    [6990.96, 1421.96]
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
    createMidCheckpoints(_allMidCheckpoints);   

    // Add player
    createPlayer(465, 1447);

    // Pango should be attached by this level
    player.pangoAttached = true;

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
    _gameSave = saveGame(_gameSave);  

    super.create();       
 }  

	function fadeOut(Player:FlxSprite, Exit:FlxSprite) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}	

	function changeState() {
		_gameSave = endOfLevelSave(_gameSave, grpHud.gameScore, killedEmenies);
		var _levelCompleteState:LevelComplete = new LevelComplete(_gameSave);
		openSubState(_levelCompleteState);	
	}	
 

  override public function update(Elapsed:Float) {
    super.update(Elapsed);

		// Overlaps
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, fadeOut)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);      
  } 
}