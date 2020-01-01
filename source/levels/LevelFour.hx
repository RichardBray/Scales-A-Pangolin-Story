package levels;

import screens.LevelComplete;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;

// Internal
import states.LevelState;
import characters.PinkPango;

// Typedefs
import Hud.GoalData;


class LevelFour extends LevelState {
  var _goalData:Array<GoalData>;
  var _gameSave:FlxSave;
  var _pangoSprite:PinkPango;
  var _pangoNPC:NPC;
	var _spokentoNPC:Int = 0;
	var _pangoDialogueImage:FlxSprite;

  public function new(?GameSave:Null<FlxSave>) {
    super();
    _gameSave = GameSave;
  	_goalData = [
			{
				goal: "Defeat the Big Boar",
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

    createLevel("level-4-0", "SCALES_BACKGROUND-01.png", "level_four");

		// Add NPC Text
		var pangoText:Array<String> = [
			"You saved my life!!",
			"You are the fastest, strongest pangolin I have ever seen... \nplease, you have to help me!",
			"I have lost my <pt>four<pt> babies. Sob Sob",
			"Some have been trapped by <pt>predators<pt> and \nothers have been caught by <pt>poachers<pt>",
      "I need to see my babies again, please do everything \nyou can to bring them back to me!."
		]; 


		// Add NPC
		var npcXPos:Int = 2327;
		var npcYPos:Int = 1111;

		_pangoDialogueImage = new FlxSprite(0, 0);
		_pangoDialogueImage.loadGraphic("assets/images/characters/dialogue/PANGO.png", false, 415, 254);
		_pangoSprite = new PinkPango(npcXPos, npcYPos);
		_pangoNPC = new NPC(
			npcXPos, 
			npcYPos, 
			pangoText, 
			_pangoSprite, 
			this, 
			[5, 1], 
			_pangoDialogueImage,
			"mama_dialogue"
		);
		add(_pangoNPC);	       

		// Add player
		createPlayer(180, 1044, _gameSave);

    // Add HUD
    createHUD(0, player.health, _goalData); 

		// Save game on load 			
#if debug
_gameSave = new FlxSave(); // initialize
_gameSave.bind("AutoSave"); // bind to the named save slot 
#end   									
		if (_gameSave != null) _gameSave = saveGame(_gameSave);
    super.create();  
		    
  }

	function levelComplete(Player:FlxSprite, Exit:FlxSprite) {
		_gameSave = endOfLevelSave(_gameSave, grpHud.gameScore, killedEmenies);
		var _levelCompleteState:LevelComplete = new LevelComplete(_gameSave, 0);
		openSubState(_levelCompleteState);			
	}

	function pinkPangoUnwravel(Player:Player, Friend:FlxSprite) {
		haxe.Timer.delay(() -> {
			_pangoSprite.unwravel();
			_pangoNPC.initConvo(Player, Friend);
		}, 2000);	
	}

  override public function update(Elapsed:Float) {
    super.update(Elapsed);

		// Overlaps
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, levelComplete)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);  

		if (killedEmenies > 0) { // Only talk when boss has been defeated
			FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, pinkPangoUnwravel);
			if (!FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, pinkPangoUnwravel)) {
				_pangoNPC.dialoguePrompt.hidePrompt();
			};
		}
  }
}