package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxText;


class DialoguePrompt extends FlxTypedGroup<FlxSprite> {
	var _dialogueBubble:FlxSprite;
	var _dialogueText:FlxText;
	var _dialogueXPos:Float;
	var _dialogueYPos:Float;
	var _dialogueTextYPos:Float;
	var _vertices:Array<FlxPoint>;
	var _w:Float;
	var _h:Float;

	/**
	 * Created the box and text elements for a dialogue prompt.
	 *
	 * @param		DialogueWidth		Width of the whole dialogue box.
	 * @param		X								X positions.
	 * @param		Y								Y position.
	 * @param		DialogueText 		Text that will go in the box, this will change to string for image.
	 */
	public function new(?DialogueWidth:Null<Float> = 120, ?X:Float = 0, ?Y:Float = 0, DialogueText:String) {
		super();

		// Center dialogue bubble if larger than 145
		final centerPadding = DialogueWidth >= 145 ? ((DialogueWidth - 145) / 2) : 0;

		_dialogueXPos = X + (DialogueWidth / 2);
		_dialogueYPos = Y;
		_dialogueTextYPos = Y + 22;

		// Create the speech bubble
		_dialogueBubble = new FlxSprite((_dialogueXPos + centerPadding), Y);
		_dialogueBubble.makeGraphic(Std.int(DialogueWidth), Std.int(DialogueWidth / 4 * 3), FlxColor.TRANSPARENT);

		_w = 145; //  _dialogueBubble.width
		_h = Std.int(_w / 4 * 3); // _dialogueBubble.height

		_vertices = new Array<FlxPoint>();
		_vertices = [
			new FlxPoint(0, 0),
			new FlxPoint(_w, 0),
			new FlxPoint(_w, _w / 2),
			new FlxPoint(_h, _w / 2),
			new FlxPoint(_w / 2, _h),
			new FlxPoint(_w / 4, _w / 2),
			new FlxPoint(0, _w / 2)
		];
		FlxSpriteUtil.drawPolygon(_dialogueBubble, _vertices, Constants.primaryColor);
		add(_dialogueBubble);

		// Create dialogue text
		_dialogueText = new FlxText(_dialogueXPos, _dialogueTextYPos, DialogueWidth);
		_dialogueText.text = DialogueText;
		_dialogueText.setFormat(Constants.squareFont, Constants.hudFont, FlxColor.WHITE, CENTER);
		add(_dialogueText);

		// Hide the members
		hidePrompt();
	}

	public function showPrompt() {
		this.forEach((_member:FlxSprite) -> _member.alpha = 1);
	}

	public function hidePrompt() {
		this.forEach((_member:FlxSprite) -> _member.alpha = 0);
	}
}
