package;

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

	override public function kill():Void {
		alive = false;
		FlxTween.tween(this, {alpha: 0, y: y + 50}, .5, {ease: FlxEase.quadOut, onComplete: finishKill});
	}

	function finishKill(_):Void {
		exists = false;
	}
}
