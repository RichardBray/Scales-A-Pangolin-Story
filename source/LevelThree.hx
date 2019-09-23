package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.FlxG;
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

		_goalData = [
			{
				goal: 'Collect over $_bugsGoal bugs',
				func: (GameScore:Int) -> GameScore > _bugsGoal
			},
			{
				goal: "Talk to friend",
				func: (_) -> killedEmenies > 1
			}            
		]; 

  }

  override public function create() {
    levelName = "Level-3-0";

    createLevel("level-3-0", "mountains");
	
		// Add player
		// createPlayer(180, 1470);
		createPlayer(10936, 1480);

    // Add HUD
    createHUD(0, player.health, _goalData);   

		// Add NPC Text
		var monkeyText:Array<String> = [
			"Hello friend!",
			"Welcome to a spuer early build of the Pangolin game.",
			"Nothing is finalised, the art assets, gameplay mechanics, even the sound effects.",
			"Right now all you can do is collect <pt>purple bugs<pt>, but we're hoping to \nhave loads more done soon.",
			"Until then, have fun :)"
		];

		// Add NPC
		var npcXPos:Int = 11315;
		var npcYPos:Int = 775;

		_monkeySprite = new FlxSprite(npcXPos, npcYPos).makeGraphic(176, 168, 0xff205ab7);
		_monkeyNPC = new NPC(npcXPos, npcYPos, monkeyText, _monkeySprite, this);
		add(_monkeyNPC);		

    super.create(); 
  }

	function fadeOut(Player:FlxSprite, Exit:FlxSprite) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}	

	function changeState() {
		FlxG.switchState(new LevelThree(_gameSave));
	}	
  
  override public function update(Elapsed:Float) {
    super.update(Elapsed);

		// Overlaps
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, fadeOut)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);

		FlxG.overlap(player, _monkeyNPC.npcSprite.npcBoundary, _monkeyNPC.initConvo);
		if (!FlxG.overlap(player, _monkeyNPC.npcSprite.npcBoundary, _monkeyNPC.initConvo)) {
			actionPressed = false;
			_monkeyNPC.dialoguePrompt.hidePrompt();
		};				    
  }
}