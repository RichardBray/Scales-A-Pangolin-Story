package levels;

import flixel.tweens.FlxTween;
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
  // - Custscene
  var _mamaSeen:FlxObject;
  var _babyDialogueBox:DialogueBox;
  var _babyDialogueImage:String;
  var _babyDialogueImageSptite:FlxSprite;
  var _babyLeftPlayer:Bool = false;
  var _whiteBg:FlxSprite;
  // - Exits
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
    
    // Mama seen box
    _mamaSeen = new FlxObject(1113, 469, 212, 1103);
    add(_mamaSeen);

    // Mama Pangolin
		_pangoDialogueImage = new FlxSprite(0, 0);
		_pangoDialogueImage.loadGraphic(Constants.mamaPangolin, false, 415, 254);
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

    // Needs to be after player has been created
    checkIfPlayerHasPango(_gameSave);

    // Baby dialogue box
    _babyDialogueImageSptite = new FlxSprite(0, 0);
    _babyDialogueImageSptite.loadGraphic(_babyDialogueImage, false, 415, 254);
    _babyDialogueBox = new DialogueBox(["Mama!"], this, _babyDialogueImageSptite, "mama_dialogue", true);
		add(_babyDialogueBox);    

    // Add HUD
    createHUD(0, player.health, []); 
      
    // Whte bg above all!!!
    _whiteBg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
    _whiteBg.scrollFactor.set(0, 0);
    _whiteBg.alpha = 0;
    add(_whiteBg);

    if (_gameSave != null) _gameSave = saveGame(_gameSave);
    super.create(); 
  }

  /**
   * Checks if player has baby pangolin for encouter with mother cutscene
   */
  function checkIfPlayerHasPango(GameSave:FlxSave) {
    if (_gameSave.data.playerHasPango != null) {
      final pangoColor:String = _gameSave.data.playerHasPango;
      switch(pangoColor) {
        case "purple":
          player.pangoAttached = true;
          _babyDialogueImage = Constants.purpleBabyPango;
        default:
          player.pangoAttached = false; // Maybe this should reset all pango attached settings
      }
    }
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
  
  function reunitedCutscene(Player:Player, MamaSeen:FlxObject) {
    if (!_babyLeftPlayer) {
      // Show baby dialogue box
      _babyDialogueBox.showBox();
      haxe.Timer.delay(() -> {
        _babyDialogueBox.hideBox();
        // Fade camera out to white
        FlxTween.tween(_whiteBg, {alpha: 1}, .5);    
      }, 1000);
      // Fade in from white
      haxe.Timer.delay(() -> {
        FlxTween.tween(_whiteBg, {alpha: 0}, .5); 
        _babyLeftPlayer = true;
        Player.pangoAttached = false;
      }, 2500);
      // Place baby in position on tree
    }
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);

    // - Overlaps
    FlxG.overlap(player, _leftExit, fadeOut);
    FlxG.overlap(player, _rightExit, fadeOut);
    if (player.pangoAttached) FlxG.overlap(player, _mamaSeen, reunitedCutscene);

    FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, mamaPangoTalking);
    if (!FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, mamaPangoTalking)) {
      _pangoNPC.dialoguePrompt.hidePrompt();
    };   
  }
}