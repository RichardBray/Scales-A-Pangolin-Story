package levels;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;

// Internal
import states.LevelState;

// Typedefs
import Hud.GoalData;

class LevelTwo extends LevelState {
  var _goalData:Array<GoalData>;
	var _gameSave:FlxSave;

  final _bugsGoal:Int = 14;
  final _allMidCheckpoints:Array<Array<Float>> = [
    [1569.77, 1424.09],
		[8603.50, 1425.26]
  ];
	
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
		_gameSave = GameSave;

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
    levelName = "Level-2-0";

    createLevel("level-2-0", "SCALES_BACKGROUND-01.png", "level_two");
		createMidCheckpoints(_allMidCheckpoints);

		// Add player
		createPlayer(180, 1470);

    // Add HUD
    createHUD(0, player.health, _goalData);  

		// Proximity sounds
		createProximitySounds(); 

		// Save game on load
		_gameSave = new FlxSave(); // initialize
		_gameSave.bind("AutoSave"); // bind to the named save slot  		
		_gameSave = saveGame(_gameSave);

		super.create(); 
  }

	function fadeOut(Player:FlxSprite, Exit:FlxSprite) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}	

	function changeState() {
		_gameSave = endOfLevelSave(_gameSave, grpHud.gameScore, killedEmenies);
		FlxG.switchState(new LevelThree(_gameSave));
	}	 


  override public function update(Elapsed:Float) {
    super.update(Elapsed);

		// Overlaps
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, fadeOut)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);		
  }
}