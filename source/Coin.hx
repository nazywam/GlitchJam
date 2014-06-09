package ;

import flixel.FlxSprite;
import openfl.Assets;
/**
 * ...
 * @author Michael
 */
class Coin extends FlxSprite {

	public function new(X:Float, Y:Float) {
		super(X, Y);
		loadGraphic("assets/images/stuff.png", true, 32, 32);
		
		animation.add("default", [0, 1, 2, 3, 4, 5], 6);
		animation.add("take", [6, 7, 8, 9, 10, 11], 25, false);
		animation.play("default");
		//animation.frameIndex = Std.random(6); //TODO
		
		immovable = true;
		
		
		y -= height / 2;
		width = 28;
		height = 28;
		offset.x = 2;
		offset.y = 2;
	}
	override public function update() {
		super.update();
		if (animation.name == "take" && animation.frameIndex == 11) {
			alpha = 0;
		}
	}
}