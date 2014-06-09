package ;
import openfl.Assets;
/**
 * ...
 * @author Michael
 */
class Cat extends Actor {

	public var touched : Bool;
	public function new(X : Float, Y : Float) {
		super(X, Y);
		touched = false;
		loadGraphic(Assets.getBitmapData("assets/images/cat.png"), true, 32, 32);
		animation.add("sitting", [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 1, 2, 3], 5);
		animation.play("sitting");
		
		y -= height / 2;
		immovable = true;
	}
	
}