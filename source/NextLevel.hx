package;


class NextLevel extends GameLevel {
	// var _score:Int
	// public function new(Score:Int):Void {
	// 	_score = Score;
	// }

	override public function create():Void {
		bgColor = 0xffc7e4db; // Game background color
		createLevel("level-1-3", "mountains");

		// Add player
		createPlayer(60, 600);

		// Add HUD
		createHUD(overallScore, 3);

		super.create();
	}
}
