package levels;

import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;

// Internal
import states.GameState;
import states.LevelState;
import characters.PinkPango;
import characters.PurplePango;

class LevelHome extends LevelState {
  var _gameSave:FlxSave;
  var _pangoSprite:PinkPango;
  var _pangoNPC:NPC;
  var _pangoDialogueImage:FlxSprite;
  // - Custscene
  var _mamaSeen:FlxObject;
  var _babyDialogueBox:DialogueBox;
  var _babyDialogueImage:String = "";
  var _babyDialogueImageSprite:FlxSprite;
  var _babyLeftPlayer:Bool = false;
  var _whiteBg:FlxSprite;
  // - Exits
  var _leftExit:FlxObject;
  var _rightExit:FlxObject;
  // - Baby pangos
  var _purplePango:PurplePango;
    
  public function new(?GameSave:Null<FlxSave>) {
    super();
    _gameSave = GameSave;
  }

  override public function create() { 
    levelName = "Level-h-0";
    createLevel("level-h-0", "SCALES_BACKGROUND-01.png", "level_four");

		// Add NPC
		final npcXPos:Int = 1971;
    final npcYPos:Int = 1066;
    
    // Mama seen box
    _mamaSeen = new FlxObject(1113, 469, 212, 1103);
    add(_mamaSeen);

    // Exits
    final EXIT_WIDTH:Int = 120;
    _leftExit = new FlxObject(0, 0, EXIT_WIDTH, _map.fullHeight);  
    _rightExit = new FlxObject(_map.fullWidth - EXIT_WIDTH, 0, EXIT_WIDTH, _map.fullHeight);  
    add(_leftExit);
    add(_rightExit);

    // Purple Pango sprite
    _purplePango = new PurplePango(2058, 809);
    _purplePango.animation.play("idle");
    _purplePango.keepIdle = true;
    _purplePango.alpha = 0;
    add(_purplePango);    
  
		// Add player
    createPlayer(326, 1463, _gameSave);

    if (_gameSave.data.pangosDelivered != null) displayDeliveredPangos();
      
    // Needs to be after player has been created
    checkIfPlayerHasPango();

    // Baby dialogue box
    if (_gameSave.data.playerHasPango != null) {
      _babyDialogueImageSprite = new FlxSprite(0, 0);
      _babyDialogueImageSprite.loadGraphic(_babyDialogueImage, false, 415, 254);
      _babyDialogueBox = new DialogueBox(["Mama!"], this, _babyDialogueImageSprite, "mama_dialogue", true);
      add(_babyDialogueBox); 
    }

    // Add HUD
    createHUD(0, player.health, []); 

    // Mama Pangolin
		_pangoDialogueImage = new FlxSprite(0, 0);
		_pangoDialogueImage.loadGraphic(Constants.mamaPangolin, false, 415, 254);
		_pangoSprite = new PinkPango(npcXPos, npcYPos, true);
    _pangoSprite.unwravel();
		_pangoNPC = new NPC(
			npcXPos, 
			npcYPos, 
			mamaPangolinDialogue(player), 
			_pangoSprite, 
			this, 
			[5, 1], 
			_pangoDialogueImage,
			"mama_dialogue"
		);
    add(_pangoNPC);	   
      
    // Whte bg above all!!!
    _whiteBg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
    _whiteBg.scrollFactor.set(0, 0);
    _whiteBg.alpha = 0;
    add(_whiteBg);

    if (_gameSave != null) _gameSave = saveGame(_gameSave);

    super.create(); 
  }

  /**
   * Checks if player has baby pangolin for encouter with mother cutscene so that
   * pango dialogue image can be set.
   */
  function checkIfPlayerHasPango() {
    if (_gameSave.data.playerHasPango != null) {
      final pangoColor:String = _gameSave.data.playerHasPango;
      switch(pangoColor) {
        case "purple":
          player.pangoAttached = true;
          _babyDialogueImage = Constants.purpleBabyPango;
          saveDelieveredPango("purple", 0);
        default:
          player.pangoAttached = false; // Maybe this should reset all pango attached settings
      }
    }
  }

  /**
   * Method to check what pangos have been delivered already and display them.
   */
  function displayDeliveredPangos() {
    final splitDeliveredPangos:Array<String> = _gameSave.data.pangosDelivered.split("/");
    for (pango in splitDeliveredPangos) {
      switch(pango) {
        case "purple":
          _purplePango.alpha = 1;
      }
    }
  }

  /**  
   * Method to add newly delivered pango to save state.
   *
   * @param PangoColor The color of the pango to save
   * @param SavePos The position in the save slot
   */
  function saveDelieveredPango(PangoColor:String, SavePos:Int) {
    if (_gameSave.data.pangosDelivered != null) {
      final splitDeliveredPangos:Array<String> = _gameSave.data.pangosDelivered.split("/");
      splitDeliveredPangos[SavePos] = PangoColor;
      _gameSave.data.pangosDelivered = splitDeliveredPangos.join("/"); 
    } else {
      _gameSave.data.pangosDelivered = PangoColor;
    }
  }

  /**
   * This method returns a piece of text to return for the mother pangolin based on the situation
   */
  function mamaPangolinDialogue(Player:Player):Array<String> {
		final pangoText:Array<String> = [
			"Please bring my son back to me. "
    ]; 
    
    final returnedPangoText:Array<String> = [
      "Thank you so much for bringing my sone back to me. ",
      "You have united a family that was once forced apart. "
    ];

    return Player.pangoAttached ? returnedPangoText : pangoText;
  }

  function mamaPangoTalking(Player:Player, Friend:PinkPango) {
    _pangoNPC.initConvo(Player, Friend);
  }

	function fadeOut(Player:FlxSprite, Exit:FlxObject) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}	 

	function changeState() {
    if (_babyLeftPlayer) {
      FlxG.switchState(new EndScreen(_gameSave));
    } else {
      FlxG.switchState(new levels.LevelSelect(_gameSave));
    }
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
        // Place baby in position on tree
        _purplePango.alpha = 1;
        _gameSave.data.playerHasPango = null;
      }, 2500);
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

class EndScreen extends GameState {
  var _controls:Controls;
  var _gameSave:FlxSave;
  var _titleText:FlxText;
  var _subText:FlxText;
  var _controlsText:FlxText;

  /**
   * End of game. Whoop Whoop!!
   */
  public function new(GameSave:FlxSave) {
    super();
    _gameSave = GameSave;
  }

  override public function create() {
    super.create();
    bgColor = FlxColor.BLACK;
    _controls = new Controls();

    FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // Screen fades in

    _titleText = new FlxText(870, 460, 0, "The End!!!");
    _titleText.setFormat(Constants.squareFont, Constants.lrgFont, FlxColor.WHITE, CENTER);
    add(_titleText);	

    _subText = new FlxText(800, 540, 0, "Thanks for playing :)");
    _subText.setFormat(Constants.squareFont, Constants.medFont, FlxColor.WHITE, CENTER);
    add(_subText);    

    final cross:String = Constants.cross;
    _controlsText = new FlxText(835, 990, 0, 'Press $cross to continue');
    _controlsText.setFormat(Constants.squareFont, Constants.smlFont, FlxColor.WHITE, CENTER);
    add(_controlsText);      
  }

	function goToLevelSelect() {
		FlxG.switchState(new levels.LevelSelect(_gameSave, 1));
  } 
  
  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    if (_controls.cross.check() || _controls.start.check()) goToLevelSelect();
  }
}