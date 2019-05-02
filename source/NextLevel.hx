package;

import flixel.FlxG;
import flixel.FlxState;

class NextLevel extends FlxState {
	public var player:Player;

	override public function create():Void {
		bgColor = 0xff00fff7; // Game background color

		// Add player
		player = new Player(60, 100);
		add(player);
		js.Browser.console.log(player, 'player');

		super.create();
	}
}
