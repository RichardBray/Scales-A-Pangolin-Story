package states;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxSave;

class IntroState extends GameState {
	var _factText:FlxText;
	var _factNumber:Int = 0;
	var _gameSave:FlxSave;
	var _seconds:Float = 0;
	var _controls:Controls;
	var _textWidth:Int = 600;
	var _skipText:FlxText;
	var _sndGong:FlxSound;
	var _sndClose:FlxSound;

	public var facts:Array<String>;


	override public function create() {
		super.create();
		bgColor = 0xff04090C; // 04090C

		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		_factText = new FlxText(
			(FlxG.width / 2) - (_textWidth / 2), 
			(FlxG.height / 2) - 100, 
			_textWidth, 
			facts[_factNumber]
		);
		_factText.setFormat(Constants.squareFont, Constants.lrgFont, FlxTextAlign.CENTER);

		FlxG.cameras.fade(FlxColor.BLACK, 0.5, true); // Level fades in
		add(_factText);	
		_factText.alpha = 0;
		_controls = new Controls();	

		final jump = Constants.cross;
		// Skip text
		_skipText = new FlxText(
			FlxG.width - 300,
			FlxG.height - 80,
			0,
			'Press $jump to skip'
		);	
		_skipText.setFormat(Constants.squareFont, Constants.hudFont);
		_skipText.alpha = 0;
		add(_skipText);

		_sndGong = FlxG.sound.load("assets/sounds/sfx/fact_gong.ogg");
		_sndClose = FlxG.sound.load(Constants.sndMenuClose);
		_sndGong.play();
	}	

	override public function update(Elapsed:Float) {
		super.update(Elapsed);
		_seconds += Elapsed;	
	
		// Starts level when all the facts have been looped through
		(_factNumber == facts.length) ? startLevel() : showFacts();

		// Show skip text a second later
		haxe.Timer.delay(() -> FlxTween.tween(_skipText, {alpha: 1}, .5), 3000);

		// Start level if player presses start
		if ( _controls.cross.check()) {
			_sndClose.play(); 
			haxe.Timer.delay(startLevel, 200);
		}
	}

	function showFacts() {
		_factText.text = facts[_factNumber];
		var showFor:Int = 4; // How many seconds the text should show for
	 
		if (_seconds < showFor) {
			FlxTween.tween(_factText, { alpha: 1 }, .5);
		} else if (_seconds > (showFor + 1) && _seconds < (showFor + 2)) {
			FlxTween.tween(_factText, { alpha: 0 }, .5);
		} else if (Math.round(_seconds) == (showFor + 3)) {
			_seconds = 0;
			_factNumber++;
			_sndGong.play();
		}				
	}

	public function startLevel() {
		// This should be overriten
	}
}