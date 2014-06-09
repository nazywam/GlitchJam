package ;
import flixel.FlxSprite;
/**
 * ...
 * @author Michael
 */
class Actor extends FlxSprite {

	public var facingRight : Bool;
	public function new(x : Float, y : Float) {
		super(x, y);
		facingRight = true;
	}
	
}