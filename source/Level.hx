package ;
import flixel.addons.effects.FlxGlitchSprite;
import flixel.FlxSprite;
import openfl.Assets;
import flixel.FlxG;
import flash.display.BlendMode;
/**
 * ...
 * @author Michael
 */
class Level extends FlxSprite {
	public var glitch : FlxGlitchSprite;
	public var id : Int;
	public function new(X : Float, Y : Float, i : Int) {
		super(X, Y);
		id = i;
		//color = 0xFFFF00;
		loadGraphic(Assets.getBitmapData("assets/images/levels.png"), false, 45, 45);
		animation.add("default", [id]);
		animation.play("default");
		visible = false;
		glitch = new FlxGlitchSprite(this, 4, 2, 0.01);	
	}
	override public function update() {
		//glitch.strength = 3;
		super.update();
	}
	
}