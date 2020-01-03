package levels;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;

import states.LevelState;
import characters.PinkPango;

class LevelHome extends LevelState {
  var _gameSave:FlxSave;
  var _pangoSprite:PinkPango;
  var _pangoNPC:NPC;
	var _pangoDialogueImage:FlxSprite;
    
  public function new(?GameSave:Null<FlxSave>) {
    super();
    _gameSave = GameSave;
  }

  override public function create() { 
    levelName = "Level-h-0";
    createLevel("level-h-0", "SCALES_BACKGROUND-01.png", "level_four");
  
		var pangoText:Array<String> = [
			"Please bring all my babies back to me. "
		]; 

		// Add NPC
		var npcXPos:Int = 1599;
		var npcYPos:Int = 1066;

		_pangoDialogueImage = new FlxSprite(0, 0);
		_pangoDialogueImage.loadGraphic("assets/images/characters/dialogue/PANGO.png", false, 415, 254);
		_pangoSprite = new PinkPango(npcXPos, npcYPos);
    _pangoSprite.unwravel();
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
		createPlayer(153, 1413, _gameSave);

    // Add HUD
    createHUD(0, player.health, []); 
      
    if (_gameSave != null) _gameSave = saveGame(_gameSave);
    super.create(); 
  }

  function mamaPangoTalking(Player:Player, Friend:PinkPango) {
    _pangoNPC.initConvo(Player, Friend);
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);

    FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, mamaPangoTalking);
    if (!FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, mamaPangoTalking)) {
      _pangoNPC.dialoguePrompt.hidePrompt();
    };   
  }
}