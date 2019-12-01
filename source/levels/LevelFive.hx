package levels;


import states.IntroState;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxSave;
import flixel.FlxG;
import states.LevelState;
import characters.CagedPangolin;
import characters.PurplePango;

import Hud.GoalData;

class LevelFive extends LevelState {
  var _gameSave:FlxSave;
  var _goalData:Array<GoalData>;
  var _teleport:FlxObject;
  var _bonusLevel:FlxObject;

  // Caged Pango
  var _cagedPangolin:CagedPangolin;
  var _cagedPangoCollision:FlxObject;
  var _pangoNPC:NPC;
  var _purplePango:PurplePango;
  var _pangoDialogueImage:FlxSprite;
  var _pangoFreed:Bool = false; //Var to pause collision so pango can roll through branch

  public function new(?GameSave:Null<FlxSave>) {
    super();
    _gameSave = GameSave;

		_goalData = [
			{
				goal: "Save the pangolin",
				func: (_) -> player.pangoAttached
      },
			{
				goal: "Wait for the next part of the level",
				func: (_) -> false
      }      
		];    
  }

  override public function create() {
    levelName = "Level-5-0";

    // TODO: Make music for level five
    createLevel("level-5-0", "SCALES_BACKGROUND-01.png", "level_one");

    _teleport = new FlxObject(3362, 1674, 193, 227);
    add(_teleport);

    _bonusLevel = new FlxObject(14174, (1920 - 718), 1920, 1080);
    add(_bonusLevel);

    _cagedPangoCollision = new FlxSprite(12612, 1086).makeGraphic(115, 20, FlxColor.TRANSPARENT);
    _cagedPangoCollision.immovable = true;
    add(_cagedPangoCollision);

    _cagedPangolin = new CagedPangolin(12517, 840);
    add(_cagedPangolin);

		_pangoDialogueImage = new FlxSprite(0, 0);
		_pangoDialogueImage.loadGraphic("assets/images/characters/dialogue/PANGO.png", false, 415, 254);

    _purplePango = new PurplePango(12651, 1214);
    _purplePango.alpha = 0;

		// Add NPC Text
		var pangoText:Array<String> = [
			"You saved my life!!",
			"You are the fastest, strongest pangolin I have ever seen... \nplease, you have to help me!",
			"I have lost my <pt>four<pt> babies. Sob Sob",
			"Some have been trapped by <pt>predators<pt> and \nothers have been caught by <pt>poachers<pt>",
      "I need to see my babies again, please do everything \nyou can to bring them back to me!."
		]; 

		_pangoNPC = new NPC(
			12651, 
			1500, 
			pangoText, 
			_purplePango, 
			this, 
      [3, 1],
			_pangoDialogueImage,
			"mama_dialogue",
      true      
		);
		add(_pangoNPC);	    
  
  		// Add player
		// createPlayer(172, 1439);  
    createPlayer(12042, 1369);
    createHUD(0, player.health, _goalData);  
  
    // Save game on load
    // if (_gameSave != null) _gameSave = saveGame(_gameSave);
    super.create();

    // Restrict level width to hide bonus level on load
    updateMapDimentions(FlxG.width + 10, 0);
  }

  /**
   * Teleport to the bonus part of the level
   */
  function moveToBonus(Player:Player, Teleport:FlxObject) {
    updateMapDimentions(0, 0);
    player.setPosition(14974, 842);
    player.animation.play("jumpLoop");
    FlxG.camera.follow(_bonusLevel, PLATFORMER, 1);
  }

  function pangoTalking(Player:Player, Pango:PurplePango) {
    _pangoNPC.initConvo(Player, Pango);
  }

  function exitBouns() {
    // Put level dimentions back
    // Follow the player
  }

  function killCageAndCollision(_, _) {
    if (!player.isAscending) {
      player.velocity.y = 450; // Bounce player
      _cagedPangolin.kill();
      _cagedPangoCollision.kill();

      haxe.Timer.delay(() -> {
        _purplePango.alpha = 1;
        _purplePango.enableGravity = true;
      }, 200);

      haxe.Timer.delay(() -> _pangoFreed = true, 300);
    }
  }

	function fadeOut(Player:FlxSprite, Exit:FlxSprite) {
		FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, changeState);
	}	

	function changeState() {
		_gameSave = endOfLevelSave(_gameSave, grpHud.gameScore, killedEmenies);
		FlxG.switchState(new LevelFour(_gameSave));
	}	

  override public function update(Elapsed:Float) {
    super.update(Elapsed);

		// Overlaps
		grpHud.goalsCompleted
			? FlxG.overlap(levelExit, player, fadeOut)
			: FlxG.collide(levelExit, player, grpHud.goalsNotComplete);  

    FlxG.overlap(player, _teleport, moveToBonus);
    FlxG.overlap(player, _cagedPangoCollision, killCageAndCollision);

    if (_pangoFreed) {
      FlxG.collide(_purplePango, _levelCollisions);
      FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary, pangoTalking);
      if (!FlxG.overlap(player, _pangoNPC.npcSprite.npcBoundary)) {
        _pangoNPC.dialoguePrompt.hidePrompt();
      };	 
    }

    if (_pangoNPC.finishedConvo) {
      _purplePango.jumpToPlayer(player.facing);
      haxe.Timer.delay(() -> {
        _pangoNPC.kill();
        player.pangoAttached = true;
      }, 500);
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
		FlxG.switchState(new LevelFive(_gameSave));
	}
}
