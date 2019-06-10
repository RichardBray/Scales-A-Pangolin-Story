package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;

class Menu extends FlxTypedGroup<FlxSprite> {
	var _pointer:FlxSprite;
	var _choices:Array<FlxText>;

	public function new(X:Float, Y:Float, Spacing:Int, Data:Map<String, Void->Void>):Void {
		super();
		// Text Choices
		_choices.push(new FlxText(X, Y + 200, 0, "Restart", 22));
		_choices.push(new FlxText(X, Y + 250, 0, "Quit", 22));
	}
}
