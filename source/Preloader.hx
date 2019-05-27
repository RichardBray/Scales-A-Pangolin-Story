package;

import flash.text.Font;
import flash.text.TextFormat;
import flash.text.TextField;
import flixel.system.FlxBasePreloader;

@:font("assets/images/preloader/corners.png")
private class CustomFont extends Font {}

class Preloader extends FlxBasePreloader {
	var _text:TextField;

	override public function new(MinDisplayTime:Float = 0, ?AllowedURLs:Array<String>):Void {
		super(MinDisplayTime, AllowedURLs);
	}

	/**
	 * This class is called as soon as the FlxPreloaderBase has finished initializing.
	 * Override it to draw all your graphics and things - make sure you also override update
	 * Make sure you call super.create()
	 */
	override function create():Void {
		// Loading text

		_text = new TextField();
		super.create();
	}

	/**
	 * Cleanup your objects!
	 * Make sure you call super.destroy()!
	 */
	override function destroy():Void {
		super.destroy();
	}

	/**
	 * Update is called every frame, passing the current percent loaded. Use this to change your loading bar or whatever.
	 * @param	Percent	The percentage that the project is loaded
	 */
	override public function update(Percent:Float):Void {}
}
