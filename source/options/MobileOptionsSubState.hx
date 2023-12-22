package options;

class MobileOptionsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Mobile Options';
		rpcTitle = 'Mobile Options Menu'; //for Discord Rich Presence, fuck it

		var option:Option = new Option('Mobile Controls',
		'Choose The Best Mobile Control For You!',
		'guh',
		'string',
		['']);
		addOption(option);

        #if !web
		var option:Option = new Option('Extra Controls', //Name
			'Select how many extra buttons you prefere to have\nThey can be used for mechanics with LUA or HScript.', //Description
			'extraButtons', //Save data variable name
			'string',
			["NONE", "ONE", "TWO"]); //Variable type
		addOption(option);

        var option:Option = new Option('Hitbox Position', //Name
			'If checked, the hitbox will be put at the bottom of the screen, otherwise will stay at the top.', //Description
			'hitbox2', //Save data variable name
			'bool'); //Variable type
		addOption(option);
                #end

		var option:Option = new Option('Dynamic Controls Color',
		'If checked, the mobile controls color will be set to the notes color in your settings.\n(have effect during gameplay only)',
		'dynamicColors',
		'bool');
		addOption(option);

		var option:Option = new Option('Mobile Controls Opacity',
			'How much transparent should the Mobile Controls be.',
			'controlsAlpha',
			'percent');
		option.scrollSpeed = 1;
		option.minValue = 0.001;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = function(){
			if (curOption.getValue() != virtualPad.alpha)
				virtualPad.alpha = curOption.getValue();
		};
		addOption(option);

		super();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if(curOption.name == 'Mobile Controls' && controls.ACCEPT)
			openSubState(new MobileControlsSubState());
		#if mobileC
		if(virtualPad.anyJustPressed(virtualPad.buttons))
			persistentUpdate = true;
			controls.isInSubstate = true;
		#end

	}

	override function closeSubState() {
		removeVirtualPad();
		addVirtualPad(LEFT_FULL, A_B_C);
		super.closeSubState();
	}
}
