package;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.addons.display.shapes.FlxShapeBox;

// Internal
import states.LevelState;

class DialogueBox extends FlxTypedGroup<FlxSprite> {
	var _dialogueBox:FlxShapeBox;
	var _dialogueBoxText:FlxText;
	var _continueText:FlxText;
	var _dialogueArray:Array<String>;
	var _arrTextNum:Int = 0;
	var _parentState:LevelState;
	var _primaryText:FlxTextFormat;
	var _controls:Controls;
	var _dialogueImage:FlxSprite;
	var _sndDialogue:Null<FlxSound>;

	public var finishedConvo:Bool = false;

	final _heightFromBase:Int = 340;

	// vars for spacing
	final _spacingWidth:Int = 150;
	final _spacingHeight:Int = 55;
	final _distanceFromTop:Int = 30;	

	/**
	 * Dialogue Box component. Hidden when first created, sort of goes hand in hand with the NPC compoennt
	 *
	 * @param DialogueText 		Text that the NPC/Player will give.
	 * @param ParentState	The parent state of the dialoge, needed to hide the HUD and prevent Player movement.
	 * @param DialogueImage NPC image for doalopgue box
	 * @param DialogueSound Sound to play when dialogue box is up
	 * @param DialogueBoxScreenTop If the dialogue box should be displayed at the top or bottom of the screen.
	 */
	public function new(
		DialogueText:Array<String>, 
		ParentState:LevelState, 
		?DialogueImage:Null<FlxSprite>, 
		?DialogueSound:Null<String>,
		DialogueBoxScreenTop:Bool = false
	) {
		super();

		// Assign these to variables to use in other methods
		_dialogueArray = DialogueText;
		_parentState = ParentState;
		_dialogueImage = DialogueImage;

		if (DialogueSound != null) _sndDialogue = FlxG.sound.load('assets/sounds/npcs/$DialogueSound.ogg', .8, true);

		// Markup styles for text
		_primaryText = new FlxTextFormat(Constants.secondaryColor, false, false);

		// Create the box
	 
		_dialogueBox = new FlxShapeBox(
			_spacingWidth,
			dialogueHeights(DialogueBoxScreenTop).dialogueBoxYPos,
			FlxG.width - (_spacingWidth * 2),
			_heightFromBase - _spacingHeight,
			{ thickness:8, color:Constants.primaryColorLight }, 
			Constants.primaryColor			
		);		
		add(_dialogueBox);

		// Create the text
		_dialogueBoxText = new FlxText(
			_spacingWidth + 20, 
			dialogueHeights(DialogueBoxScreenTop).dialogeBoxTextYPos, 
			FlxG.width - (_spacingWidth * 2), 
			_dialogueArray[_arrTextNum]
		);
		_dialogueBoxText.setFormat(Constants.squareFont, Constants.medFont, FlxColor.WHITE, LEFT);
		add(_dialogueBoxText);

		// Space to continue text
		final cross:String = Constants.cross;
		_continueText = new FlxText(
			_spacingWidth + 20, 
			dialogueHeights(DialogueBoxScreenTop).continueTextYPos, 
			FlxG.width - 400, 
			'Press $cross to continue'
		);
		_continueText.setFormat(Constants.squareFont, Constants.smlFont, FlxColor.WHITE, LEFT);
		add(_continueText);

		_dialogueImage.setPosition(
			(FlxG.width - 154) - _dialogueImage.width, 
			dialogueHeights(DialogueBoxScreenTop).dialougeImageYPos
		);
		add(_dialogueImage);

		// Hide and fix the members to the screen
		this.forEach((_member:FlxSprite) -> {
			_member.alpha = 0;
			_member.scrollFactor.set(0, 0);
		});
		this.visible = false;

		// Intialise controls
		_controls = new Controls();		
	}

	function dialogueHeights(BoxAtTop:Bool) {
		final boxAtTop = {
			continueTextYPos: (_spacingWidth * 2) + 50,
			dialogeBoxTextYPos: 20 + (_spacingHeight * 2),
			dialogueBoxYPos: 0 + (_spacingHeight * 2),
			dialougeImageYPos: -4 + (_dialogueImage.height / 2)  
		}

		final boxAtBottom = {
			continueTextYPos: FlxG.height - 150,
			dialogeBoxTextYPos: FlxG.height - (_heightFromBase + _distanceFromTop),
			dialogueBoxYPos: FlxG.height - (_heightFromBase + _spacingHeight),
			dialougeImageYPos: (FlxG.height - 110) - _dialogueImage.height
		}

		return BoxAtTop ? boxAtTop : boxAtBottom;
	}

	public function showBox() {
		this.visible = true;
		this.forEach((_member:FlxSprite) -> {
			FlxTween.tween(_member, {alpha: 1}, .1);
		});

		if (_sndDialogue != null) _sndDialogue.play();
	}

	public function hideBox() {
		this.visible = false;
		this.forEach((_member:FlxSprite) -> {
			_member.alpha = 0;
		});

		if (_sndDialogue != null) _sndDialogue.stop();
	}

	function revertUI() {
		this.hideBox();
		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {
			onComplete: (_) -> {
				_parentState.startingConvo = false;
				_parentState.player.preventMovement = false;
				_parentState.grpHud.toggleHUD(1);
			}
		});
	}

	override public function update(Elapsed:Float) {
		// Press jump button to move to next bit of text
		if (visible && _controls.cross.check()) {
			// This is used to keep running the `revertUI` method on the last array number.
			_arrTextNum == _dialogueArray.length ? _arrTextNum : _arrTextNum++;

			if (_arrTextNum == _dialogueArray.length) {
				this.revertUI();
				finishedConvo = true;
			} else {
				_dialogueBoxText.text = _dialogueArray[_arrTextNum];
				_dialogueBoxText.applyMarkup(_dialogueArray[_arrTextNum], [new FlxTextFormatMarkerPair(_primaryText, "<pt>")]);
			}
		}

		super.update(Elapsed);
	}	
}
