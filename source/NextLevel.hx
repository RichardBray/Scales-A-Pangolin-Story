package;

import flixel.FlxG;
import flixel.FlxState;

class NextLevel extends FlxState {
	public var player:Player;
	public var grpHud:HUD;

	override public function create():Void {
		bgColor = 0xff00fff7; // Game background color

		// Add player
		player = new Player(60, 100);
		add(player);
		js.Browser.console.log(player, 'player');

		// Add Hud
		grpHud = new HUD(this);
		add(grpHud);
		
		super.create();
	}
}
