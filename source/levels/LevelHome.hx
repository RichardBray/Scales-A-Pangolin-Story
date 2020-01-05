package levels;

import flixel.util.FlxColor;
import flixel.FlxObject;
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

  // Exits
  var _leftExit:FlxObject;
  var _rightExit:FlxObject;
    
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
		var npcXPos:Int = 1971;
		var npcYPos:Int = 1066;

		_pangoDialogueImage = new FlxSprite(0, 0);
		_pangoDialogueImage.loadGraphic("assets/images/characters/dialogue/PANGO.png", false, 415, 254);
		_pangoSprite = new PinkPango(npcXPos, npcYPos, true);
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

    // Exits
    final EXIT_WIDTH:Int = 120;
    _leftExit = new FlxObject(0, 0, EXIT_WIDTH, _map.fullHeight);  
    _rightExit = new FlxObject(_map.fullWidth - EXIT_WIDTH, 0, EXIT_WIDTH, _map.fullHeight);  
    add(_leftExit);
    add(_rightExit);
  
		// Add player
		createPlayer(326, 1463, _gameSave);

    // Add HUD
    createHUD(0, player.health, []); 
      
    if (_gameSave != null) _gameSave = saveGame(_gameSave);
    super.create(); 
  }

  function mamaPangoTalking(Player:Player, Friend:PinkPango) {
    _pangoNPC.initConvo(Player, Friend);
  }

	function fadeOut(Player:FlxSprite, Exit:FlxObject) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}	 

	function changeState() {
		FlxG.switchState(new levels.LevelSelect(_gameSave));
	}	   

  override public function update(Elapsed:Float) {
    super.update(Elapsed);

    FlxG.overlap(player, _leftExit, fadeOut);
    FlxG.overlap(player, _rightExit, fadeOut);

    FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, mamaPangoTalking);
    if (!FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, mamaPangoTalking)) {
      _pangoNPC.dialoguePrompt.hidePrompt();
    };   
  }
}