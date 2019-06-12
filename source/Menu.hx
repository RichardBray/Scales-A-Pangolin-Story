package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;

using Lambda;

typedef MenuData = {title:String, func:Void->Void};

class Menu extends FlxTypedGroup<FlxSprite> {
	var _selected:Int = 0;
	var _pointer:FlxSprite;
	var _spacing:Int = 50;
	var _menuData:Array<MenuData>;

	public function new(XPos:Float, YPos:Float, MenuWidth:Int = 0, Data:Array<MenuData>):Void {
		super();
		_menuData = Data;

		// Pointer
		_pointer = new FlxSprite(XPos, YPos);
		_pointer.makeGraphic(MenuWidth, _spacing, 0xffdc2de4);
		add(_pointer);

		// Text Choices
		_menuData.mapi((idx:Int, data:MenuData) -> {
			var choice = new FlxText(XPos, YPos + (_spacing * idx), 0, data.title, 22);
			choice.screenCenter(X);
			choice.scrollFactor.set(0, 0);
			add(choice);
		});
	}

	override public function update(Elapsed:Float):Void {
		if (FlxG.keys.anyJustPressed([SPACE, ENTER])) {
			_menuData[_selected].func();
		}

		if (FlxG.keys.anyJustPressed([DOWN, S])) {
			if (_selected != _menuData.length - 1) {
				_pointer.y = _pointer.y + _spacing;
				_selected++;
			}
		}

		if (FlxG.keys.anyJustPressed([UP, W])) {
			if (_selected != 0) {
				_pointer.y = _pointer.y - _spacing;
				_selected--;
			}
		}

		super.update(Elapsed);
	}
}
