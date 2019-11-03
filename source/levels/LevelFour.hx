package levels;

import screens.LevelComplete;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;

// Internal
import states.LevelState;
import characters.PinkPango;

// Typedefs
import HUD.GoalData;


class LevelFour extends LevelState {
  var _goalData:Array<GoalData>;
  var _gameSave:FlxSave;
  var _pangoSprite:FlxSprite;
  var _pangoNPC:NPC;
	var _spokentoNPC:Int = 0;

  public function new(?GameSave:Null<FlxSave>) {
    super();
    _gameSave = GameSave;
  	_goalData = [
			{
				goal: "Defeat the Panther",
				func: (_) -> killedEmenies > 0
			},
			{
				goal: "Talk to pangolin",
				func: (_) -> {
					if (startingConvo) _spokentoNPC++;
					return _spokentoNPC > 0;
				}
			}                 
		]; 
  }

  override public function create() {
    levelName = "Level-4-0";

    createLevel("level-4-0", "jungle.jpg");

		// Add NPC Text
		var pangoText:Array<String> = [
			"Oh man you saved my life. Thank you so much.",
			"So swift, so agile, you have to be the fastest pangolin I've ever seen.",
			"There are <pt>three<pt> other pangolins around that could use your help.",
			"Not just from panthers but <pt>human traps<pt> and <pt>other predators<pt>",
      "Please do what you can to help them."
		]; 

		// Add NPC
		var npcXPos:Int = 2307;
		var npcYPos:Int = 1018;

		_pangoSprite = new PinkPango(npcXPos, npcYPos);
		_pangoNPC = new NPC(npcXPos, npcYPos, pangoText, _pangoSprite, this, [5, 2.5]);
		add(_pangoNPC);	       

		// Add player
		createPlayer(180, 1044);

    // Add HUD
    createHUD(0, player.health, _goalData); 

		// Save game on load
		_gameSave = saveGame(_gameSave);

    super.create();        
  }

	function levelComplete(Player:FlxSprite, Exit:FlxSprite) {
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

		if (killedEmenies > 0) { // Only talk when leopard has been defeated
			FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, _pangoNPC.initConvo);
			if (!FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, _pangoNPC.initConvo)) {
				_pangoNPC.dialoguePrompt.hidePrompt();
			};
		}
  }
}