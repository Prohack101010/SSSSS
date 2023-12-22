/* KNNOWN ISSUE:
    - Null Object Refrence while copying .ttf, .otf
   TODO: 
    - Figure out a way to calculate the ammount files in FileSystem directory to get the exact ammount of files that should be copied
*/
package mobile.states;

import openfl.utils.Assets as OpenflAssets;
import lime.utils.Assets as LimeAssets;
import flixel.addons.util.FlxAsyncLoop;
import openfl.utils.ByteArray;
import states.MainMenuState;
import states.TitleState;
#if (target.threaded)
import sys.thread.Thread;
#end
import haxe.io.Path;

class CopyState extends MusicBeatState {
    public static var filesToCopy:Array<String>;
    public var loadingImage:FlxSprite;
    public var bottomBG:FlxSprite;
    public var loadedText:FlxText;
    public var copyLoop:FlxAsyncLoop;
    var loopTimes:Int = 0;
    var maxLoopTimes:Int = 0;
    var failedFiles:Int = 0;
    var failedFilesStr:String = '';
    var shouldCopy:Bool = false;
    var to:String = '';
    var toto:String = '';
	public function new(?to:String =  '') {
        this.toto = to;
        if(to != '' && !to.endsWith('/'))
			to += '/';
        this.to = to;
        super();
    }
    
    override function create() {
        if(!SUtil.filesExists(toto)){
            shouldCopy = true;
			FlxG.stage.application.window.alert(
			"Seems like you have some missing files that are necessary to run the game\nPress OK to begin the copy process",
			"Notice!");
            filesToCopy = LimeAssets.list();
            // removes unwanted paths
            var assets = filesToCopy.filter(folder -> folder.startsWith('assets/'));
            var mods = filesToCopy.filter(folder -> folder.startsWith('mods/'));
            var allPaths = assets.concat(mods);
            filesToCopy = allPaths;

            maxLoopTimes = filesToCopy.length;
            loadingImage = new FlxSprite(0, 0, Paths.image('funkin'));
            loadingImage.scale.set(0.8, 0.8);
            loadingImage.screenCenter();
            add(loadingImage);

            bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		    bottomBG.alpha = 0.6;
		    add(bottomBG);

            loadedText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, '', 16);
            loadedText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
            add(loadedText);
    
            #if (target.threaded) Thread.create(() -> {#end
            copyLoop = new FlxAsyncLoop(maxLoopTimes, copyAsset, 17);
            add(copyLoop);
            copyLoop.start();
            #if (target.threaded) }); #end
        } else
            MusicBeatState.switchState(new TitleState()); trace('going back to titlestate');

        super.create();
    }

    override function update(elapsed:Float) {
        if(shouldCopy){
            if(copyLoop.finished){
                if(failedFiles > 0)
                    FlxG.stage.application.window.alert(failedFilesStr, 'Failed To Copy $failedFiles File.');
                FlxG.switchState(new TitleState());
            }
            loadedText.text = '$loopTimes/$maxLoopTimes';
        }
        super.update(elapsed);
    }

    public function copyAsset() {
        var file = filesToCopy[loopTimes];
	    ++loopTimes; 
		if(!FileSystem.exists(to + file)) {
			var directory = Path.directory(to + file);
		    if(!FileSystem.exists(directory))
					SUtil.mkDirs(directory);
            try {
                if(getFileBytes(getFile(file)).length == 0 && (Path.extension(file) == 'txt' || Path.extension(file) == 'lua' || Path.extension(file) == 'json' || Path.extension(file) == 'hx' || Path.extension(file) == 'xml'))
                    SUtil.saveContent(Path.withoutExtension(to + file), Path.extension(file), Std.string(CoolUtil.listFromString(LimeAssets.getText(getFile(file))).join('')), false);
                else
                    if(LimeAssets.exists(getFile(file)))
                        File.saveBytes(to + file, getFileBytes(getFile(file)));
                    else {
                        --loopTimes;
                        ++failedFiles;
                        failedFilesStr += getFile(file) + "(File Dosen't exist)\n";
                    }
            }catch(e:Dynamic){
                --loopTimes;
                ++failedFiles;
                failedFilesStr += '${getFile(file)}($e)\n';
            }
		}
	}

    public static function getFileBytes(file:String):ByteArray {
		switch(Path.extension(file)) {
			case 'otf' | 'ttf':
				return cast LimeAssets.getAsset(file, FONT, false);
			default:
				return OpenflAssets.getBytes(file);
		}
	}
	public static function getFile(file:String):String {
		for(index in 1...8)
			if(file.contains('/week$index/'))
				return 'week_assets:$file';
		if(file.contains('/videos/'))
			return 'videos:$file';
		else if(file.contains('/songs/'))
			return 'songs:$file';
		else if(file.contains('/shared/'))
			return 'shared:$file';
		else
			return file;
	}
}
