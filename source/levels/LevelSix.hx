package levels;

import flixel.FlxG;
import flixel.util.FlxColor;
import screens.LevelComplete;
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

  final _bugsGoal:Int = 7; 

  final _allMovingCages:Array<Array<Int>> = [
    [3993, 1368, 0],
    [8106, 1369, 0],
    [9773, 887, 1],
    [10559, 1292, 0]
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
				goal: 'Collect over $_bugsGoal bugs',
				func: (GameScore:Int) -> GameScore > _bugsGoal
			}
		];
	}

 override public function create() {
    levelName = "Level-6-0";

    // TODO: Make music for level six
    createLevel("level-6-0", "dessert-bg.jpg", "level_one");
    createMidCheckpoints(_allMidCheckpoints);   

    // Add player
    createPlayer(465, 1447);

    // Pango should be attached by this level
    player.pangoAttached = true;

		// Proximity sounds
		createProximitySounds();     

    _allCages = new FlxTypedGroup<MovingCage>();
    
    add(_allCages);

    _allMovingCages.map((movingCage:Array<Int>) -> {
      var _movingCage:MovingCage = new MovingCage(
        movingCage[0], 
        movingCage[1], 
        movingCage[2] == 1, 
        player, 
        playerFeetCollision);
  
      _allCages.add(_movingCage);
    });

    // Add HUD
    createHUD(0, player.health, _goalData);  

    // Save game on load
    if (_gameSave != null) _gameSave = saveGame(_gameSave); 

    super.create();   

    bgColor = 0xffF2E1BF;    
 }  

	function levelComplete(Exit:FlxSprite, Player:FlxSprite) {
		_gameSave = endOfLevelSave(_gameSave, grpHud.gameScore, killedEmenies);
		var _levelCompleteState:LevelComplete = new LevelComplete(_gameSave);
		openSubState(_levelCompleteState);			
	}
 

  override public function update(Elapsed:Float) {
    super.update(Elapsed);

		// Overlaps
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, levelComplete)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);      
  } 
}