package;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;

class Enemy extends FlxSprite {
	public var sndHit:FlxSound;
	public var sndEnemyKill:FlxSound;

	public function new(X:Float = 0, Y:Float = 0):Void {
		super(X, Y);
		makeGraphic(50, 50, 0xffff0000); // temporary
		sndHit = FlxG.sound.load("assets/sounds/hurt.wav");
		sndEnemyKill = FlxG.sound.load("assets/sounds/drop.wav");		
	}

	// override public function kill():Void {
		// exists = false;
		// FlxTween.tween(this, {alpha: 0, y: y + 50}, .5, {ease: FlxEase.quadOut, onComplete: finishKill});
  //}

	// function finishKill(_):Void {
	// 	exists = false;
	// }
	
}

class Fire extends Enemy {
	var _timer:FlxTimer;

	public function new(X:Float = 0, Y:Float = 0):Void {
		super(X, Y + 40); // to make up for offset
		_timer = new FlxTimer();
		loadGraphic("assets/images/L1_FIRE_01.png", true, 178, 206);
		setGraphicSize(138, 166);
		updateHitbox();
		offset.set(20, 40);
		scale.set(1, 1);

		animation.add("burning", [for (i in 0...7) i], 12, true);		
	}

	override public function update(Elapsed:Float):Void {
		animation.play("burning");
		super.update(Elapsed);
	}	

	override public function kill():Void {
		alive = false;
		_timer.start(.5, (_) -> alive = true, 1);
	}	
}
