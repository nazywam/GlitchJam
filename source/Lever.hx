package ;

import flixel.FlxSprite;
import openfl.Assets;
/**
 * ...
 * @author Michael
 */
class Lever extends FlxSprite {
	
	public var state : Bool;
	public var opens : Int;
	public function new(X:Float=0, Y:Float=0, o : Int){
		super(X, Y);
		opens = o;
		
		loadGraphic(Assets.getBitmapData("assets/images/tiles.png"), false, 16, 16);
		animation.add("true", [32]);
		animation.add("false", [33]);
		state = true;
		width = 28;
		offset.x = -6;
		x -= 6;
	}
	override public function update() {
		super.update();
		animation.play(Std.string(state));
	}
	
}