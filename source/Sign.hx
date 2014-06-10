package ;
import flixel.FlxSprite;
import openfl.Assets;
/**
 * ...
 * @author Michael
 */
class Sign extends FlxSprite {
	
	var text : String;
	public function new(X : Float, Y : Float, t : String) {
		super(X, Y);
		text = t;
		loadGraphic(Assets.getBitmapData("assets/images/tiles.png"), false, 16, 16);
		animation.add("default", [36]);
		animation.play("default");
	}
	
}