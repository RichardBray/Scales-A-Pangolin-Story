package characters;

import flixel.FlxSprite;
import flixel.FlxG;

class PinkPango extends FlxSprite
{
  public function new(X:Float = 0, Y:Float = 0) {
    super(X, Y);

    loadGraphic("assets/images/characters/scales_pinkpango72.png", true, 282, 298);

    // Animations
    animation.add("hanging", [for (i in 0...3) i], 8, true);
    animation.add("unwravelling", [for (i in 4...17) i], 8, true); 
    animation.add("standing", [for (i in 18...23) i], 8, true);   
  }

  override public function update(Elapsed:Float) {
    super.update(Elapsed);
    animation.play("hanging");
  }
}