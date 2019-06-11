package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;

using Lambda;

typedef MenuData = Array<{title:String, func:Void->Void}>;

class Menu extends FlxTypedGroup<FlxSprite> {
	var _selected:Int = 0;
	var _pointer:FlxSprite;
	var _choices:Array<FlxText>;

	public function new(XPos:Float, YPos:Float, Spacing:Int = 0, Data:MenuData):Void {
		super();
		// Text Choices
		Data.mapi((idx:Int, data:{title:String, func:Void->Void}) -> {
			var choice = new FlxText(XPos, YPos + (Spacing * idx), 0, data.title, 22);
			choice.screenCenter(X);
			choice.scrollFactor.set(0, 0);
			add(choice);
		});
	}
}
