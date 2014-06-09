package ;

import flash.Lib;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
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
	var coins : FlxGroup;
	override public function create() {
		super.create();
		FlxG.log.redirectTraces = true;
		
		player = new Player(100, 100);
		add(player);
		
		map = new FlxTilemap();
		map.loadMap(Assets.getText("assets/data/map.tmx"), "assets/images/tiles.png", 16, 16, 0, 1);
		add(map);
		
		coins = new FlxGroup();
		add(coins);
		
		placeStuff(Assets.getText("assets/data/stuff.tmx"));
		
		//FlxG.camera.follow(player); // ??
	}
	
	public function collectCoin(player : Player, coin : Coin) {
		coin.animation.play("take");
		coin.solid = false;
	}
	
	override public function update() {
		super.update();
		FlxG.collide(player, map);
		FlxG.collide(player, coins, collectCoin);
				
		FlxG.camera.scroll.x = player.x - FlxG.camera.width/2;
		
		if (FlxG.keys.pressed.RIGHT) {
			player.facingRight = true;
			player.velocity.x = 150;
		} else if (FlxG.keys.pressed.LEFT) {
			player.velocity.x = -150;
			player.facingRight = false;
		}
		
		if (FlxG.keys.justPressed.UP && player.isTouching(FlxObject.FLOOR)) {
			player.velocity.y = -250;
		}
		if (FlxG.keys.justReleased.UP && player.velocity.y < 0) {
			player.velocity.y  = 0;
			player.animation.frameIndex = 2;
		}
	}
	
	function placeStuff(Stuff:String) {
		var ids:Array<String>;
		var entities:Array<String> = Stuff.split("\n");   
		for (posY in 0...(entities.length)) {
			ids = entities[posY].split(",");  
			for (posX in 0...(ids.length)) {
				if (Std.parseInt(ids[posX]) == 40) {
					coins.add(new Coin(16*posX, 16*posY));
				}
			}
		}
	}
}