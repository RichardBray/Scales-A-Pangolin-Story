package characters;

import flixel.FlxObject;
import flixel.FlxSprite;

class PurplePango extends FlxSprite {
  public var enableGravity:Bool = false;
  final GRAVITY:Float = Constants.worldGravity;

  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic("assets/images/characters/L2_BABYPURPLE.png", true, 140, 77);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
      
    animation.add("roll", [for (i in 5...9) i], 8, true);
    animation.add("idle", [for (i in 0...4) i], 8, true);
  }

  function jumpToPlayer(PlayerDirection:Int) {
    velocity.y = -400;
    velocity.x = (PlayerDirection == FlxObject.RIGHT) ? 400 : -400;
    haxe.Timer.delay(() -> kill(), 1000);
  }

  override public function update(Elapsed:Float) {
    (isTouching(FlxObject.FLOOR)) 
    ? animation.play("idle")
    : animation.play("roll");

    super.update(Elapsed);
  
    if (enableGravity) acceleration.y = GRAVITY;
  }
}