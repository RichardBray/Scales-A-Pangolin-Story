package levels;


import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxSave;
import flixel.FlxG;

import states.IntroState;
import states.LevelState;
import characters.CagedPangolin;
import characters.PurplePango;

import Hud.GoalData;

class LevelFive extends LevelState {
  var _gameSave:FlxSave;
  var _goalData:Array<GoalData>;
  var _teleport:FlxObject;
  var _bonusLevel:FlxObject;
  var _bonusLevelExit:FlxObject;
	var _seconds:Float = 0;

  // Instructions
  var _instructionsBox:FlxObject;  
  var _showInstrucitons:Bool = false;
  var _instructionsViewed:Bool = false;

  // Cave
  var _caveForeground:FlxSprite;
  var _caveBackground:FlxSprite;

  // Caged Pango
  var _cagedPangolin:CagedPangolin;
  var _cagedPangoCollision:FlxObject;
  var _pangoNPC:NPC;
  var _purplePango:PurplePango;
  var _pangoDialogueImage:FlxSprite;
  var _pangoFreed:Bool = false; //Var to pause collision so pango can roll through branch

  final _bugsGoal:Int = 20; 
  final _allMidCheckpoints:Array<Array<Float>> = [
    [4771.08, 856.85],
    [4755.69, 1215.27],
    [5327.93, 1426.64]
  ];

  public function new(?GameSave:Null<FlxSave>, ShowInstructions:Bool = false) {
    super();
    _gameSave = GameSave;
    _gameSave.data.introTwoSeen = true;
    _showInstrucitons = ShowInstructions;
    var savePangoGoalOption:Array<GoalData>;
    var standardGoals:Array<GoalData>;

    savePangoGoalOption = [{
      goal: "Save the pangolin",
      func: (_) -> player.pangoAttached
    }];
  
		standardGoals = [
			{
				goal: 'Collect over $_bugsGoal bugs',
				func: (GameScore:Int) -> GameScore > _bugsGoal
      }      
    ]; 
    
    // Remove save pagolin goal if purple pango has already been saved
    _goalData = _gameSave.data.pangosDelivered != null ? standardGoals : standardGoals.concat(savePangoGoalOption);
  }

  override public function create() {
    levelName = "Level-5-0";

    _caveBackground = new FlxSprite(14174, 718).loadGraphic(
      "assets/images/environments/L2_Cave-01.png", false, 1920, 1080);
    add(_caveBackground);
  
    // TODO: Make music for level five
    createLevel("level-5-0", "SCALES_BACKGROUND-01.png", "level_five");
    createMidCheckpoints(_allMidCheckpoints);

    _caveForeground = new FlxSprite(14176, 720).loadGraphic(
      "assets/images/environments/L2_Cave-02.png", false, 1920, 1080);

    _teleport = new FlxObject(3362, 1718, 193, 184);
    add(_teleport);

    _bonusLevel = new FlxObject(14174, (1920 - 718), 1920, 1080);
    add(_bonusLevel); 

    _bonusLevelExit = new FlxObject(16066, 1065, 27, 183);
    add(_bonusLevelExit);

    _cagedPangoCollision = new FlxSprite(12243, 1139).makeGraphic(115, 180, FlxColor.TRANSPARENT);
    _cagedPangoCollision.immovable = true;

    _cagedPangolin = new CagedPangolin(12145, (1415 - 416));   

		_pangoDialogueImage = new FlxSprite(0, 0);
		_pangoDialogueImage.loadGraphic(Constants.purpleBabyPango, false, 415, 254);

    _purplePango = new PurplePango(12270, 1250);
    _purplePango.alpha = 0;

    _instructionsBox = new FlxObject(3199.82, 324.99, 104.77, 1111.82);

		// Add NPC Text
		var pangoText:Array<String> = [
			"Thanks for freeing me from the cage. ",
			"I was careless and got caught in this poacher's trap. ",
			"Will you please take me to my <pt>mother<pt>? ",
			"I hope you don't mind if I hitch a ride on your tail. "
		]; 

		_pangoNPC = new NPC(
			12300, 
			1500, 
			pangoText, 
			_purplePango, 
			this, 
      [2, 1],
			_pangoDialogueImage,
			"mama_dialogue",
      true      
		);  
    
    if (_gameSave.data.pangosDelivered == null) {
    add(_cagedPangoCollision);
    add(_cagedPangolin);
    add(_pangoNPC);	
  }     
  
  	// Add player
		createPlayer(368, 1470, _gameSave);  

		// Proximity sounds
		createProximitySounds(); 

    add(_caveForeground);

    // Add HUD
    createHUD(0, player.health, _goalData);  
  
    // Save game on load    
              
    if (_gameSave != null) _gameSave = saveGame(_gameSave);
    super.create();

    // Restrict level width to hide bonus level on load
    updateMapDimentions(FlxG.width + 10, 0);
  }

  function playerJumpAnim():String {
    return player.pangoAttached
      ? "jumpLoop_pp"
      : "jumpLoop";
  }

  /**
   * Teleport to the bonus part of the level
   */
  function moveToBonus(Player:Player, Teleport:FlxObject) {
    updateMapDimentions(0, 0);
    // Player jumps down hole
    player.setPosition(14974, 842);
    player.animation.play(playerJumpAnim());
    playMusic(Constants.caveMusic);
    // Follow level not plauer
    FlxG.camera.follow(_bonusLevel, PLATFORMER, 1);
    // Hide all background images
    levelBgs.forEach((Member:FlxSprite) -> Member.alpha = 0);
  }

  function pangoTalking(Player:Player, Pango:PurplePango) {
    _pangoNPC.initConvo(Player, Pango);
  }

  function exitBouns(_, _) {
    updateMapDimentions(FlxG.width + 10, 0);
    player.setPosition(3362, 1525);
    player.animation.play(playerJumpAnim());
    player.velocity.y = -800;
    player.sndWee.play();
    FlxG.camera.follow(player, PLATFORMER, 1);
    playMusic(Constants.jungleMusic);
    // Show all background images
    levelBgs.forEach((Member:FlxSprite) ->  Member.alpha = 1);
  }

  function killCageAndCollision(_, _) {
    if (!player.isAscending && player.animation.name == "jumpLoop") {
      player.velocity.y = 450; // Bounce player
      _cagedPangolin.kill();
      _cagedPangolin.sndCrash.play();
      _cagedPangoCollision.kill();
      _purplePango.enableGravity = true;
      haxe.Timer.delay(() -> _purplePango.alpha = 1, 150);
      haxe.Timer.delay(() -> _pangoFreed = true, 300);
    }
  }

	function fadeOut(Player:FlxSprite, Exit:FlxSprite) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}	

	function changeState() {
		_gameSave = endOfLevelSave(_gameSave, grpHud.gameScore, killedEmenies);
		FlxG.switchState(new LevelSix(_gameSave));
	}	

	/**
	 * Show instructions specific to this level unless they have already been viewed
	 */
	function showInstructions(_, _) {
    if (_showInstrucitons && !_instructionsViewed) {
      var _instructions:Instructions = new Instructions(2, 2, true, false);
      if (!_instructions.menuViewed) openSubState(_instructions);
      _instructionsViewed = true;
    }
	}	

  function showAbilityHelp() {
    if (
        !player.enableQuickJump // To make sure loading a saved game with ability will prevent this prompt
      ) {
      var _instructions:Instructions = new Instructions(3, 3, true, false);
      _instructions.sndAbility.play();
      if (!_instructions.menuViewed) openSubState(_instructions);
      // Save ability
      _gameSave.data.quickJumpEnabled = true;
      player.enableQuickJump = true;      
    }
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    _seconds += Elapsed;

		// Overlaps
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, fadeOut)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);  

    FlxG.overlap(player, _teleport, moveToBonus);
    FlxG.overlap(player, _bonusLevelExit, exitBouns);
    FlxG.overlap(player, _cagedPangoCollision, killCageAndCollision);
    FlxG.overlap(player, _instructionsBox, showInstructions);

    if (_pangoFreed) {
      FlxG.collide(_purplePango, _levelCollisions);
      FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, pangoTalking);
      if (!FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary)) {
        _pangoNPC.dialoguePrompt.hidePrompt();
      };	 
    }

    if (_pangoNPC.finishedConvo && _pangoNPC.alive) {
      _purplePango.jumpToPlayer(player.facing);
      haxe.Timer.delay(() -> {
        _pangoNPC.kill();
        player.pangoAttached = true;
        _gameSave.data.playerHasPango = "purple";
      }, 400);

      haxe.Timer.delay(() -> showAbilityHelp(), 800);
    }

    if (startingConvo) {
      // Face opposite direction to player
      _purplePango.facing = player.facing == FlxObject.LEFT
        ? FlxObject.RIGHT
        : FlxObject.LEFT;
    }   
  }
}

class IntroFive extends IntroState {

	/**
	 * Runs the intro sequence for the first level.
	 *
	 * @param GameSave Game save from `MainMenu.hx`
	 */
	public function new(GameSave:FlxSave) {
		super();
		_gameSave = GameSave;
		facts = [
			"So our hero continued to travel through the jungle.",
			"Avoiding predetars and obstacles in search of captured pangolins to save."
		];		
	}

	override public function startLevel() {
		FlxG.switchState(new LevelFive(_gameSave, true));
	}
}
