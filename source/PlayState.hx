package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
//import flixel.math.FlxMath;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import openfl.Assets;
class PlayState extends FlxState
{
	var player : Player;
	var map : FlxTilemap;
	
	override public function create() {
		super.create();
		
		player = new Player(100, 100);
		add(player);
		
		map = new FlxTilemap();
		map.loadMap(Assets.getText("assets/data/map.tmx"), "assets/images/tiles.png", 16, 16, 0, 1);
		add(map);
	}
	
	override public function update() {
		super.update();
		FlxG.collide(player, map);
		
		if (FlxG.keys.pressed.RIGHT) {
			player.facingRight = true;
			player.velocity.x = 150;
			FlxG.camera.scroll.x += 2;
		} else if (FlxG.keys.pressed.LEFT) {
			player.velocity.x = -150;
			player.facingRight = false;
			FlxG.camera.scroll.x -= 2;
		}
		
		if (FlxG.keys.justPressed.UP && player.isTouching(FlxObject.FLOOR)) {
			player.velocity.y = -250;
		}
		if (FlxG.keys.justReleased.UP && player.velocity.y < 0) {
			player.velocity.y  = 0;
			player.animation.frameIndex = 2;
		}
		
	}
}