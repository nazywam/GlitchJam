package ;

import flash.geom.Point;
import flash.Lib;
import flixel.addons.effects.FlxGlitchSprite;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.util.FlxMath;
import flixel.util.FlxTimer;
import openfl.Assets;
import flixel.FlxCamera;
class PlayState extends FlxState
{
	
	var map : FlxTilemap;
	var background : FlxTilemap;
	var coins : FlxGroup;
	var lasers : FlxGroup;
	var levers : FlxGroup;
	var signs : FlxGroup;
	
	var player : Player;
	var playerSpawn : Point;
	
	var cat : Cat;
	var catGlitch : FlxGlitchSprite;
	
	override public function create() {
		super.create();
		FlxG.worldBounds.set(640, 320);
		FlxG.log.redirectTraces = true;
		FlxG.mouse.visible = false;
		background = new FlxTilemap();
		background.loadMap(Assets.getText("assets/data/background.tmx"), "assets/images/background_bw.png", 128, 128, 0, 1);
		add(background);
		
		map = new FlxTilemap();
		map.loadMap(Assets.getText("assets/data/map.tmx"), "assets/images/tiles.png", 16, 16, 0, 1);
		add(map);
		
		coins = new FlxGroup();
		add(coins);
		
		lasers = new FlxGroup();
		add(lasers);
		
		levers = new FlxGroup();
		add(levers);
		
		signs = new FlxGroup();
		add(signs);
		
		parseMap(Assets.getText("assets/data/map.txt"));
		
		//placeStuff(Assets.getText("assets/data/stuff.tmx"));
		
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
	public function nextLevel(Timer:FlxTimer) {
		//trace("meow");
		FlxG.camera.flash(0xFFFFFF, 0.3);
		cat.visible = false;
		Timer.destroy();
		cat.touched = false;
		cat.exists = false;
	}
	public function collectCat(player : Player, cat : Cat) {
		cat.visible = true;
		cat.touched = true;
		catGlitch.exists = false;
		new FlxTimer(1.5, nextLevel, 1);
	}
	public function spawnPlayer() {
		if(player!=null)remove(player);
		player = new Player(playerSpawn);
		add(player);
		FlxG.camera.follow(player);
		FlxFlicker.flicker(player, 1, 0.1);
	}
	public function killPlayer(player : Player, laser : Laser) {
		if (FlxFlicker.isFlickering(player) || !laser.on) return;
		player.animation.play("die");
		player.dead = true;
		player.acceleration.y = 0;
		player.velocity.y = 0;
		player.solid = false;
		player.facingRight = true;
		new FlxTimer(2, function(Timer:FlxTimer) {player.animation.play("restart");}, 1);
	}
	public function nearLever(player : Player, lever : Lever) {
		if (FlxG.keys.justPressed.SPACE) {
			lever.state = !lever.state;	
			for (l in lasers) {
				if (l.ID == lever.opens) cast(l, Laser).on = !cast(l, Laser).on;
			}
		}
	}
	
	override public function update() {
		super.update();
		var distance = FlxMath.distanceBetween(cat, player);
		if (distance < 100 && !cat.touched && catGlitch.exists) {
			cat.visible = false;
			catGlitch.visible = true;
			var strength = Std.int(Math.max(10 - distance / 20, 0));
			if (distance < 50) {
				strength *= 5;
			}
			catGlitch.strength = strength;
			FlxG.camera.shake(0.001*strength, 0.1);
		} else {
			//catGlitch.strength = 0;
			catGlitch.visible = false;
			cat.visible = true;
		}
		
		background.scrollFactor.x = FlxG.camera.scroll.x/background.width*0.9;
		FlxG.collide(player, map);
		FlxG.overlap(player, coins, collectCoin);
		FlxG.collide(player, cat, collectCat);
		FlxG.overlap(player, lasers, killPlayer);
		FlxG.overlap(player, levers, nearLever);
		
		if (FlxG.keys.justPressed.SPACE && player.dead) {
			spawnPlayer();
		}
		
		if (cat.touched || player.dead) return;
		
		if (FlxG.keys.pressed.RIGHT) {
			player.velocity.x = 125;
			player.facingRight = true;
		} else if (FlxG.keys.pressed.LEFT) {
			player.velocity.x = -125;
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
	function parseMap(map:String) {
		var items = map.split("[]");
		parseTiles(items[0]);
		for (x in 1...items.length) {
			//trace(x + " " + items[x]);
			var ids = items[x].substring(2, items[x].length - 3).split("\n");
			
			var entry = ids[0].split("=");
			var pos4 = ids[1].split("=")[1].substring(0, ids[1].split("=")[1].length - 3);
			var pos2 = pos4.split(",");
			
			var posX = Std.parseInt(pos2[0]);
			var posY = Std.parseInt(pos2[1]) -1;
			var type = entry[1].substring(0, entry[1].length - 1);
			//trace (entry[0] + "X" + entry[1]);
			//trace( + " " + posX + " " + posY);
			switch(type) {
				case "Coin":
					coins.add(new Coin(posX*16, posY*16));
				case "Lever":
					var opens = ids[2].split("=")[1].substr(0, ids[2].split("=")[1].length-1);
					levers.add(new Lever(posX * 16, posY * 16, Std.parseInt(opens)));
				case "Laser":
					var ID = ids[2].split("=")[1].substr(0, ids[2].split("=")[1].length - 1);
					//trace(ID);
					var vertical = ids[3].split("=")[1].substr(0, ids[3].split("=")[1].length - 1);
					//trace(vertical);
					lasers.add(new Laser(posX * 16, posY * 16, Std.parseInt(vertical)==0, Std.parseInt(ID)));
				case "Player":
					playerSpawn = new Point(posX * 16, posY * 16);
					spawnPlayer();
				case "Cat":
					cat = new Cat(posX * 16, posY * 16);
					add(cat);
				case "Sign":
					var text = ids[2].split("=")[1].substr(0, ids[2].split("=")[1].length - 1);
					trace(text);
					signs.add(new Sign(posX * 16, posY * 16, text));
			}
		}
	}
	function parseTiles(tiles:String) {
		
	}
}