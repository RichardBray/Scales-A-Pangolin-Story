package levels;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.FlxG;
import characters.ZenMonkey;

// Internal
import states.LevelState;

// Typedefs
import Hud.GoalData;


class LevelThree extends LevelState {
  var _goalData:Array<GoalData>;
	var _gameSave:FlxSave;
	var _monkeySprite:ZenMonkey;
	var _monkeyNPC:NPC;
	var _monkeyDialogueImage:FlxSprite;
	var _spokentoNPC:Int = 0;

  final _bugsGoal:Int = 14;
  final _allMidCheckpoints:Array<Array<Float>> = [
    [1822.46, 1110.25],
		[6117.78, 1425.01]
  ];	

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
					if (startingConvo) _spokentoNPC++;
					return _spokentoNPC > 0;
				}
			}            
		]; 

  }

  override public function create() {
    levelName = "Level-3-0";

    createLevel("level-3-0", "SCALES_BACKGROUND-01.png", "level_three");
		createMidCheckpoints(_allMidCheckpoints);

		// Add NPC Text
		var monkeyText:Array<String> = [
			"Hello young pangolin!",
			"I've never seen one of your kind move so fast before, truly remarkable.",
			"A word of warning. I saw an angry <pt>large boar<pt> just come by here.",
			"I have a feeling she isn't very happy with her children being jumped on.",
			"You would be wise to take care when running around."
		];

		// Add NPC
		var npcXPos:Int = 11255; // 11265
		var npcYPos:Int = 790;
	
		_monkeyDialogueImage = new FlxSprite(0, 0);
		_monkeyDialogueImage.loadGraphic("assets/images/characters/dialogue/MONKEY.png", false, 486, 432);
		_monkeyDialogueImage.offset.set(-40, 4);
		_monkeySprite = new ZenMonkey(npcXPos, npcYPos);
		_monkeyNPC = new NPC(
			npcXPos, 
			npcYPos, 
			monkeyText, 
			_monkeySprite, this, [3, 3], 
			_monkeyDialogueImage, 
			"monkey_dialogue"
		);
		add(_monkeyNPC);		

		// Add player
		createPlayer(180, 1470); 
		
    // Add HUD
    createHUD(0, player.health, _goalData); 

		createProximitySounds("level-3-0");

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
		FlxG.switchState(new LevelFour(_gameSave));
	}	

	function monkeyTalking(Player:Player, Friend:FlxSprite) {
		_monkeySprite.toggleTalkingAnim(startingConvo);
		_monkeyNPC.initConvo(Player, Friend);
	}
  
  override public function update(Elapsed:Float) {
    super.update(Elapsed);

		// Overlaps
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, fadeOut)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);

		FlxG.overlap(player, _monkeyNPC.npcSprite.npcBoundary, monkeyTalking);
		if (!FlxG.overlap(player, _monkeyNPC.npcSprite.npcBoundary, monkeyTalking)) {
			_monkeyNPC.dialoguePrompt.hidePrompt();
		};				    
  }
}