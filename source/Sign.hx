package ;
import flixel.FlxSprite;
import openfl.Assets;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
/**
 * ...
 * @author Michael
 */
class Sign extends FlxSprite {
	
	var t : String;
	public var text : FlxText;
	public var shouldBeVisible : Bool;
	public var tweening : Bool;
	public var glitched : Bool;
	public function new(X : Float, Y : Float, t : String) {
		super(X, Y);
		this.t = t;
		solid = true;
		shouldBeVisible = false;
		tweening = false;
		glitched = false;
		
		loadGraphic(Assets.getBitmapData("assets/images/tiles.png"), false, 16, 16);
		animation.add("default", [36]);
		animation.play("default");
		
		text = new FlxText(X, Y, 0, t);
		text.x -= text.width / 2;
		text.x += 16;
		text.immovable = true;		
		text.solid = false;
		text.visible = false;
		
		//text.= 0xFFFFFF;
		//text.visible = false;
		//text.solid = true;
		
		width = 32;
		offset.x = -8;
	}
	public function show() {
		text.visible = true;
		tweening = true;
		FlxTween.linearMotion(text, text.x, text.y, text.x, text.y - height * 2, 0.75, true, { type : FlxTween.ONESHOT, ease:FlxEase.cubeOut, complete:function(tween:FlxTween) { tweening = false; text.solid = glitched; } } );
	}
	public function hide() {
		tweening = true;
		FlxTween.linearMotion(text, text.x, text.y, text.x, text.y + height * 2, 0.35, true, { type : FlxTween.ONESHOT, ease:FlxEase.cubeIn, complete:function(tween:FlxTween) { text.visible = false; tweening = false; }} );
	}
	override public function update() {
		super.update();
		if (shouldBeVisible && !text.visible) {
			show();
		} else if (!shouldBeVisible && text.visible && !tweening && !text.solid){
			hide();
		}
	}
	
}
