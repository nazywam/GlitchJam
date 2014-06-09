package ;

import flash.Lib;
import flixel.addons.effects.FlxGlitchSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.util.FlxMath;
import openfl.Assets;
import flixel.FlxCamera;
class PlayState extends FlxState
{
	
	var map : FlxTilemap;
	var background : FlxTilemap;
	var coins : FlxGroup;
	
	var player : Player;
	
	var cat : Cat;
	var catGlitch : FlxGlitchSprite;
	override public function create() {
		super.create();
		FlxG.worldBounds.set(800, 320);
		FlxG.log.redirectTraces = true;
		
		background = new FlxTilemap();
		background.loadMap(Assets.getText("assets/data/background.tmx"), "assets/images/background_bw.png", 128, 128, 0, 1);
		add(background);
		
		map = new FlxTilemap();
		map.loadMap(Assets.getText("assets/data/map.tmx"), "assets/images/tiles.png", 16, 16, 0, 1);
		add(map);
		
		coins = new FlxGroup();
		add(coins);
		
		placeStuff(Assets.getText("assets/data/stuff.tmx"));
		
		catGlitch = new FlxGlitchSprite(cat);
		add(catGlitch);
		cat.visible = false;
		
		FlxG.camera.setBounds(0, 0, FlxG.worldBounds.x, FlxG.worldBounds.y, true);
		FlxG.camera.follow(player, FlxCamera.STYLE_PLATFORMER);
	}
	
	public function collectCoin(player : Player, coin : Coin) {
		coin.animation.play("take");
		coin.solid = false;
	}
	public function collectCat(player : Player, cat : Cat) {
		
	}
	
	override public function update() {
		super.update();
		if (FlxMath.distanceBetween(cat, player) < 100) {
			catGlitch.strength = Std.int(Math.max(10 - FlxMath.distanceBetween(cat, player) / 20, 0));
		} else {
			catGlitch.strength = 0;
		}
		
		background.scrollFactor.x = FlxG.camera.scroll.x/background.width*1.2;
		FlxG.collide(player, map);
		FlxG.collide(player, coins, collectCoin);
		FlxG.collide(player, cat, collectCat);
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
				if (Std.parseInt(ids[posX]) == 39) {
					cat = new Cat(16 * posX, 16 * posY);
					add(cat);
				}
				if (Std.parseInt(ids[posX]) == 38) {
					player = new Player(16 * posX, 16 * posY);
					add(player);
				}
			}
		}
	}
}