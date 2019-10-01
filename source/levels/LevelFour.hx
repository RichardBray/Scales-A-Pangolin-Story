package levels;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.util.FlxSave;

// Internal
import states.LevelState;

// Typedefs
import HUD.GoalData;


class LevelFour extends LevelState {
  var _goalData:Array<GoalData>;
  var _gameSave:FlxSave;
  var _pangoSprite:FlxSprite;
  var _pangoNPC:NPC;

  public function new(?GameSave:Null<FlxSave>) {
    super();
    _gameSave = GameSave;
  _goalData = [
			{
				goal: "Defeat the Leopard",
				func: (_) -> killedEmenies > 0
			},
			{
				goal: "Talk to saved pangolin",
				func: (_) -> {
					var spokentoNPC:Int = 0;
					if (startingConvo) spokentoNPC++;
					return spokentoNPC > 0;
				}
			}                 
		]; 
  }

	function fadeOut(Player:FlxSprite, Exit:FlxSprite) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}	

	function changeState() {
		FlxG.switchState(new MainMenu());
	}	  

  override public function create() {
    levelName = "Level-4-0";

    createLevel("level-4-0", "jungle.jpg");

		// Add NPC Text
		var pangoText:Array<String> = [
			"Oh man you've saved my life!",
			"Thank you so much. You have to be the fastest pangolin I've ever seen",
			"You know, there are <pt>three<pt> of other pangolins that could use your help.",
			"Not just from panthers but <pt>human traps<pt> and <pt>other predators<pt>",
      "Please do what you can to help them."
		]; 

		// Add NPC
		var npcXPos:Int = 2307;
		var npcYPos:Int = 1018;

		_pangoSprite = new FlxSprite(npcXPos, npcYPos).makeGraphic(176, 168, 0xff205ab7);
		_pangoNPC = new NPC(npcXPos, npcYPos, pangoText, _pangoSprite, this, [5, 2.5]);
		add(_pangoNPC);	       

		// Add player
		createPlayer(118, 1004);

    // Add HUD
    createHUD(0, player.health, _goalData); 

    super.create();        
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);

		// Overlaps
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, fadeOut)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);  

  if (killedEmenies > 0) { // Only talk when leopard has been defeated
		FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, _pangoNPC.initConvo);
		if (!FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, _pangoNPC.initConvo)) {
			_pangoNPC.dialoguePrompt.hidePrompt();
		};
  }

  }
}