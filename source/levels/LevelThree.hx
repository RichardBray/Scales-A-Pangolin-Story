package levels;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.FlxG;

// Internal
import states.LevelState;

// Typedefs
import HUD.GoalData;


class LevelThree extends LevelState {
  var _goalData:Array<GoalData>;
	var _gameSave:FlxSave;
	var _monkeySprite:FlxSprite;
	var _monkeyNPC:NPC;
  var _bugsGoal:Int = 15; // How many bugs to collect in order to complete level  

  public function new(?GameSave:Null<FlxSave>) {
    super();
		_gameSave = GameSave;
		_goalData = [
			{
				goal: 'Collect over $_bugsGoal bugs',
				func: (GameScore:Int) -> GameScore > _bugsGoal
			},
			{
				goal: "Talk to monkey",
				func: (_) -> {
					var spokentoNPC:Int = 0;
					if (startingConvo) spokentoNPC++;
					return spokentoNPC > 0;
				}
			}            
		]; 

  }

  override public function create() {
    levelName = "Level-3-0";

    createLevel("level-3-0", "jungle.jpg");

		// Add NPC Text
		var monkeyText:Array<String> = [
			"Hello friend!",
			"Wow, I've never seen a pangolin move so fast before, that's incredible.",
			"Anyway I saw a <pt>black panther<pt> just come by here.",
			"You might want to be carful when you're running around the jungle."
		];

		// Add NPC
		var npcXPos:Int = 11315;
		var npcYPos:Int = 775;

		_monkeySprite = new FlxSprite(npcXPos, npcYPos).makeGraphic(176, 168, 0xff205ab7);
		_monkeyNPC = new NPC(npcXPos, npcYPos, monkeyText, _monkeySprite, this, [3, 3]);
		add(_monkeyNPC);		

		// Add player
		createPlayer(180, 1470); 
		
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
		FlxG.switchState(new LevelFour(_gameSave));
	}	
  
  override public function update(Elapsed:Float) {
    super.update(Elapsed);

		// Overlaps
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, fadeOut)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);

		FlxG.overlap(player, _monkeyNPC.npcSprite.npcBoundary, _monkeyNPC.initConvo);
		if (!FlxG.overlap(player, _monkeyNPC.npcSprite.npcBoundary, _monkeyNPC.initConvo)) {
			_monkeyNPC.dialoguePrompt.hidePrompt();
		};				    
  }
}