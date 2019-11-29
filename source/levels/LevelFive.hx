package levels;


import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxSave;
import flixel.FlxG;
import states.LevelState;
import characters.CagedPangolin;

import Hud.GoalData;

class LevelFive extends LevelState {
  var _gameSave:FlxSave;
  var _goalData:Array<GoalData>;
  var _teleport:FlxObject;
  var _bonusLevel:FlxObject;

  // Caged Pango
  var _cagedPangolin:characters.CagedPangolin;
  var _cagedPangoCollision:FlxObject;
  var _freedPangolin:FlxSprite;

  public function new(?GameSave:Null<FlxSave>) {
    super();
    _gameSave = GameSave;

		_goalData = [
			{
				goal: "Save the pangolin",
				func: (_) -> false
      }
		];    
  }

  override public function create() {
    levelName = "Level-5-0";

    // TODO: Make music for level five
    createLevel("level-5-0", "SCALES_BACKGROUND-01.png", "level_one");

		// Add player
		createPlayer(172, 1439);  

    createHUD(0, player.health, _goalData);  

    _teleport = new FlxObject(3362, 1674, 193, 227);
    add(_teleport);

    _bonusLevel = new FlxObject(14174, (1920 - 718), 1920, 1080);
    add(_bonusLevel);

    _cagedPangoCollision = new FlxObject(12517, 1321, 315, 20);
    add(_cagedPangoCollision);

    _cagedPangolin = new CagedPangolin(12517, 840);
    add(_cagedPangolin);

    _freedPangolin = new FlxSprite(0, 0);
    _freedPangolin.alpha = 0;
    add(_freedPangolin);
  
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

  function exitBouns() {
    // Put level dimentions back
    // Follow the player
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);

    FlxG.overlap(player, _teleport, moveToBonus);
    FlxG.collide(player, _cagedPangoCollision, (_, _) -> _cagedPangolin.kill());
  }
}