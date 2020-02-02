// ====================================================================
//  Class:  XInterface.Tab_IForceSettings
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_IForceSettings extends UT2K3TabPanel;

var moCheckBox AutoAim;
var moCheckBox AutoSlope;
var moCheckBox InvertMouse;
var moCheckBox MouseSmooth;
var moCheckBox MouseLag;
var moCheckBox UseJoystick;
var moFloatEdit MouseSens;
var moFloatEdit MenuSens;
var moCheckBox ifWeapon;
var moCheckBox ifPickup;
var moCheckBox ifDamage;
var moCheckBox ifGUI;

var moFloatEdit MouseSmoothStr;
var moFloatEdit MouseThreshold;
var moFloatEdit DoubleClick;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	local int i;
    local string s;
	Super.Initcomponent(MyController, MyOwner);

	for (i=0;i<Controls.Length;i++)
		Controls[i].OnChange=InternalOnChange;

	AutoAim  	= moCheckBox(Controls[1]);  AutoAim.Checked(PlayerOwner().Level.Game.AutoAim==1);
	AutoSlope	= moCheckBox(Controls[2]);  AutoSlope.Checked(PlayerOwner().bSnapToLevel);
	InvertMouse = moCheckBox(Controls[3]);  InvertMouse.Checked(class'PlayerInput'.default.bInvertMouse);
	MouseSmooth = moCheckBox(Controls[4]);  MouseSmooth.Checked(class'PlayerInput'.default.MouseSmoothingMode>0);
	UseJoystick = moCheckBox(Controls[5]);  UseJoystick.Checked(bool(PlayerOwner().ConsoleCommand("get ini:Engine.Engine.ViewportManager UseJoystick")));

	MouseLag    = moCheckBox(Controls[19]);

	s = PlayerOwner().ConsoleCommand("get ini:Engine.Engine.RenderDevice ReduceMouseLag");
    MouseLag.Checked(bool(s));

	MouseSens = moFloatEdit(Controls[7]); MouseSens.SetValue(class'PlayerInput'.default.MouseSensitivity);
    MenuSens  = moFloatEdit(Controls[9]); MenuSens.SetValue(Controller.MenuMouseSens);

	ifWeapon = moCheckBox(Controls[11]); ifWeapon.Checked(class'PlayerController'.default.bEnableWeaponForceFeedback );
	ifPickup = moCheckBox(Controls[12]); ifPickup.Checked(class'PlayerController'.default.bEnablePickupForceFeedback );
	ifDamage = moCheckBox(Controls[13]); ifDamage.Checked(class'PlayerController'.default.bEnableDamageForceFeedback );
	ifGUI	 = moCheckBox(Controls[14]); ifGUI.Checked(class'PlayerController'.default.bEnableGUIForceFeedback );

    MouseSmoothStr = moFloatEdit(Controls[16]); MouseSmoothStr.SetValue(class'PlayerInput'.Default.MouseSmoothingStrength);
    MouseThreshold = moFloatEdit(Controls[17]); MouseThreshold.SetValue(class'PlayerInput'.Default.MouseAccelThreshold);
    DoubleClick    = moFloatEdit(Controls[18]); DoubleClick.SetValue(class'PlayerInput'.Default.DoubleClickTime);
}

function InternalOnChange(GUIComponent Sender)
{
	if (!Controller.bCurMenuInitialized)
		return;

	if (PlayerOwner().Level.Game !=None && Sender==AutoAim)
	{
		if ( AutoAim.IsChecked() )
			PlayerOwner().Level.Game.AutoAim = 1.0;
		else
			PlayerOwner().Level.Game.AutoAim = 0;

		PlayerOwner().Level.Game.SaveConfig();
	}

    if (Sender==MouseLag)
    	PlayerOwner().ConsoleCommand("set ini:Engine.Engine.RenderDevice ReduceMouseLag "$MouseLag.IsChecked());

	if (Sender==AutoSlope)
	{
		PlayerOwner().bSnapToLevel = AutoSlope.IsChecked();
		PlayerOwner().SaveConfig();
	}

	if (Sender==InvertMouse)
	{
		PlayerOwner().ConsoleCommand("set PlayerInput bInvertMouse "$InvertMouse.IsChecked());
		class'PlayerInput'.default.bInvertMouse = InvertMouse.IsChecked();
		class'PlayerInput'.static.StaticSaveConfig();
	}

	if (Sender==MouseSmooth)
	{
		if ( MouseSmooth.IsChecked() )
			class'PlayerInput'.default.MouseSmoothingMode = 1;
		else
			class'PlayerInput'.default.MouseSmoothingMode = 0;
	}

	if (Sender==UseJoystick)
	{
		PlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager UseJoystick"@UseJoystick.IsChecked());
	}

	if (Sender==MouseSens)
	{
		class'PlayerInput'.default.MouseSensitivity = MouseSens.GetValue();
		PlayerOwner().ConsoleCommand("set PlayerInput MouseSensitivity "$MouseSens.GetValue());
		class'PlayerInput'.static.StaticSaveConfig();
	}

	if (Sender==MouseSmoothStr)
	{
		class'PlayerInput'.default.MouseSmoothingStrength = MouseSmoothStr.GetValue();
		PlayerOwner().ConsoleCommand("set PlayerInput MouseSmoothingStrength "$MouseSmoothStr.GetValue());
		class'PlayerInput'.static.StaticSaveConfig();
	}

	if (Sender==MouseThreshold)
	{
		class'PlayerInput'.default.MouseAccelThreshold = MouseThreshold.GetValue();
		PlayerOwner().ConsoleCommand("set PlayerInput MouseAccelThreshold "$MouseThreshold.GetValue());
		class'PlayerInput'.static.StaticSaveConfig();
	}

	if (Sender==DoubleClick)
	{
		class'PlayerInput'.default.DoubleClickTime = DoubleClick.GetValue();
		PlayerOwner().ConsoleCommand("set PlayerInput DoubleClickTime "$DoubleClick.GetValue());
		class'PlayerInput'.static.StaticSaveConfig();
	}


	if (Sender==MenuSens)
	{
		Controller.MenuMouseSens = MenuSens.GetValue();
		Controller.SaveConfig();
	}

	if (Sender==ifWeapon)
	{
		PlayerOwner().bEnableWeaponForceFeedback = ifWeapon.IsChecked();
		PlayerOwner().bForceFeedbackSupported = PlayerOwner().ForceFeedbackSupported
		(	ifWeapon.IsChecked()
		||	ifPickup.IsChecked()
		||	ifDamage.IsChecked()
		||	ifGUI.IsChecked()
		);
		class'PlayerController'.SaveConfig();
	}

	if (Sender==ifPickup)
	{
		PlayerOwner().bEnablePickupForceFeedback = ifPickup.IsChecked();
		PlayerOwner().bForceFeedbackSupported = PlayerOwner().ForceFeedbackSupported
		(	ifWeapon.IsChecked()
		||	ifPickup.IsChecked()
		||	ifDamage.IsChecked()
		||	ifGUI.IsChecked()
		);
		class'PlayerController'.SaveConfig();
	}

	if (Sender==ifDamage)
	{
		PlayerOwner().bEnableDamageForceFeedback = ifDamage.IsChecked();
		PlayerOwner().bForceFeedbackSupported = PlayerOwner().ForceFeedbackSupported
		(	ifWeapon.IsChecked()
		||	ifPickup.IsChecked()
		||	ifDamage.IsChecked()
		||	ifGUI.IsChecked()
		);
		class'PlayerController'.SaveConfig();
	}

	if (Sender==ifGUI)
	{
		PlayerOwner().bEnableGUIForceFeedback = ifGUI.IsChecked();
		PlayerOwner().bForceFeedbackSupported = PlayerOwner().ForceFeedbackSupported
		(	ifWeapon.IsChecked()
		||	ifPickup.IsChecked()
		||	ifDamage.IsChecked()
		||	ifGUI.IsChecked()
		);
		class'PlayerController'.SaveConfig();
	}
}

defaultproperties
{
     Begin Object Class=GUIImage Name=InputBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.106510
         WinLeft=0.021641
         WinWidth=0.381328
         WinHeight=0.636485
     End Object
     Controls(0)=GUIImage'XInterface.Tab_IForceSettings.InputBK1'

     Begin Object Class=moCheckBox Name=InputAutoAim
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Auto Aim"
         ComponentClassName="xinterface.GUICheckBoxButton"
         OnCreateComponent=InputAutoAim.InternalOnCreateComponent
         Hint="Enabling this option will activate computer-assisted aiming in single player games."
         WinTop=0.057396
         WinLeft=0.060938
         WinWidth=0.300000
         WinHeight=0.040000
         bVisible=False
     End Object
     Controls(1)=moCheckBox'XInterface.Tab_IForceSettings.InputAutoAim'

     Begin Object Class=moCheckBox Name=InputAutoSlope
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Auto Slope"
         ComponentClassName="xinterface.GUICheckBoxButton"
         OnCreateComponent=InputAutoSlope.InternalOnCreateComponent
         Hint="When enabled, your view will automatically pitch up/down when on a slope."
         WinTop=0.175989
         WinLeft=0.060937
         WinWidth=0.300000
         WinHeight=0.040000
     End Object
     Controls(2)=moCheckBox'XInterface.Tab_IForceSettings.InputAutoSlope'

     Begin Object Class=moCheckBox Name=InputInvertMouse
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Invert Mouse"
         ComponentClassName="xinterface.GUICheckBoxButton"
         OnCreateComponent=InputInvertMouse.InternalOnCreateComponent
         Hint="When enabled, the Y axis of your mouse will be inverted."
         WinTop=0.321927
         WinLeft=0.060938
         WinWidth=0.300000
         WinHeight=0.040000
     End Object
     Controls(3)=moCheckBox'XInterface.Tab_IForceSettings.InputInvertMouse'

     Begin Object Class=moCheckBox Name=InputMouseSmoothing
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Mouse Smoothing"
         ComponentClassName="xinterface.GUICheckBoxButton"
         OnCreateComponent=InputMouseSmoothing.InternalOnCreateComponent
         Hint="Enable this option to automatically smooth out movements in your mouse."
         WinTop=0.416041
         WinLeft=0.060938
         WinWidth=0.300000
         WinHeight=0.040000
     End Object
     Controls(4)=moCheckBox'XInterface.Tab_IForceSettings.InputMouseSmoothing'

     Begin Object Class=moCheckBox Name=InputUseJoystick
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Enable Joystick"
         ComponentClassName="xinterface.GUICheckBoxButton"
         OnCreateComponent=InputUseJoystick.InternalOnCreateComponent
         Hint="Enable this option to enable joystick support."
         WinTop=0.651302
         WinLeft=0.060938
         WinWidth=0.300000
         WinHeight=0.040000
     End Object
     Controls(5)=moCheckBox'XInterface.Tab_IForceSettings.InputUseJoystick'

     Begin Object Class=GUILabel Name=InputSliderLabel1
         Caption="Mouse Sensitivity (In Game)"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.126042
         WinLeft=0.543945
         WinWidth=0.332422
         WinHeight=32.000000
         bVisible=False
     End Object
     Controls(6)=GUILabel'XInterface.Tab_IForceSettings.InputSliderLabel1'

     Begin Object Class=moFloatEdit Name=InputMouseSensitivity
         MinValue=1.000000
         MaxValue=25.000000
         Step=0.250000
         ComponentJustification=TXTA_Left
         CaptionWidth=0.725000
         Caption="Mouse Sensitivity (In Game)"
         OnCreateComponent=InputMouseSensitivity.InternalOnCreateComponent
         Hint="Adjust mouse sensitivity"
         WinTop=0.105365
         WinLeft=0.472266
         WinWidth=0.421875
     End Object
     Controls(7)=moFloatEdit'XInterface.Tab_IForceSettings.InputMouseSensitivity'

     Begin Object Class=GUILabel Name=InputSliderLabel2
         Caption="Mouse Sensitivity (Menus)"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.327865
         WinLeft=0.548828
         WinWidth=0.308594
         WinHeight=32.000000
         bVisible=False
     End Object
     Controls(8)=GUILabel'XInterface.Tab_IForceSettings.InputSliderLabel2'

     Begin Object Class=moFloatEdit Name=InputMenuSensitivity
         MinValue=1.000000
         MaxValue=6.000000
         Step=0.250000
         ComponentJustification=TXTA_Left
         CaptionWidth=0.725000
         Caption="Mouse Sensitivity (Menus)"
         OnCreateComponent=InputMenuSensitivity.InternalOnCreateComponent
         Hint="Adjust mouse speed within the menus"
         WinTop=0.188698
         WinLeft=0.472266
         WinWidth=0.421875
     End Object
     Controls(9)=moFloatEdit'XInterface.Tab_IForceSettings.InputMenuSensitivity'

     Begin Object Class=GUIImage Name=InputBK2
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.760000
         WinLeft=0.021641
         WinWidth=0.957500
         WinHeight=0.240977
     End Object
     Controls(10)=GUIImage'XInterface.Tab_IForceSettings.InputBK2'

     Begin Object Class=moCheckBox Name=InputIFWeaponEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Weapon Effects"
         ComponentClassName="xinterface.GUICheckBoxButton"
         OnCreateComponent=InputIFWeaponEffects.InternalOnCreateComponent
         Hint="Turn this option On/Off to feel the weapons you fire."
         WinTop=0.852000
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
     End Object
     Controls(11)=moCheckBox'XInterface.Tab_IForceSettings.InputIFWeaponEffects'

     Begin Object Class=moCheckBox Name=InputIFPickupEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Pickup Effects"
         ComponentClassName="xinterface.GUICheckBoxButton"
         OnCreateComponent=InputIFPickupEffects.InternalOnCreateComponent
         Hint="Turn this option On/Off to feel the items you pick up."
         WinTop=0.933000
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
     End Object
     Controls(12)=moCheckBox'XInterface.Tab_IForceSettings.InputIFPickupEffects'

     Begin Object Class=moCheckBox Name=InputIFDamageEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Damage Effects"
         ComponentClassName="xinterface.GUICheckBoxButton"
         OnCreateComponent=InputIFDamageEffects.InternalOnCreateComponent
         Hint="Turn this option On/Off to feel the damage you take."
         WinTop=0.852000
         WinLeft=0.563867
         WinWidth=0.300000
         WinHeight=0.040000
     End Object
     Controls(13)=moCheckBox'XInterface.Tab_IForceSettings.InputIFDamageEffects'

     Begin Object Class=moCheckBox Name=InputIFGUIEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="GUI Effects"
         ComponentClassName="xinterface.GUICheckBoxButton"
         OnCreateComponent=InputIFGUIEffects.InternalOnCreateComponent
         Hint="Turn this option On/Off to feel the GUI."
         WinTop=0.933000
         WinLeft=0.563867
         WinWidth=0.300000
         WinHeight=0.040000
     End Object
     Controls(14)=moCheckBox'XInterface.Tab_IForceSettings.InputIFGUIEffects'

     Begin Object Class=GUILabel Name=InputIForceLabel
         Caption="TouchSense Force Feedback"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.777000
         WinLeft=0.023437
         WinWidth=0.956250
         WinHeight=32.000000
     End Object
     Controls(15)=GUILabel'XInterface.Tab_IForceSettings.InputIForceLabel'

     Begin Object Class=moFloatEdit Name=InputMouseSmoothStr
         MinValue=0.000000
         MaxValue=1.000000
         Step=0.050000
         ComponentJustification=TXTA_Left
         CaptionWidth=0.725000
         Caption="Mouse Smoothing Strength"
         OnCreateComponent=InputMouseSmoothStr.InternalOnCreateComponent
         Hint="Adjust the amount of smoothing that is applied to mouse movements"
         WinTop=0.324167
         WinLeft=0.472266
         WinWidth=0.421875
     End Object
     Controls(16)=moFloatEdit'XInterface.Tab_IForceSettings.InputMouseSmoothStr'

     Begin Object Class=moFloatEdit Name=InputMouseAccel
         MinValue=0.000000
         MaxValue=100.000000
         Step=5.000000
         ComponentJustification=TXTA_Left
         CaptionWidth=0.725000
         Caption="Mouse Accel. Threshold"
         OnCreateComponent=InputMouseAccel.InternalOnCreateComponent
         Hint="Adjust to determine the amount of movement needed before acceleration is applied"
         WinTop=0.405000
         WinLeft=0.472266
         WinWidth=0.421875
     End Object
     Controls(17)=moFloatEdit'XInterface.Tab_IForceSettings.InputMouseAccel'

     Begin Object Class=moFloatEdit Name=InputDodgeTime
         MinValue=0.000000
         MaxValue=1.000000
         Step=0.050000
         ComponentJustification=TXTA_Left
         CaptionWidth=0.725000
         Caption="Dodge Double-Click Time"
         OnCreateComponent=InputDodgeTime.InternalOnCreateComponent
         Hint="Determines how fast you have to double click to dodge"
         WinTop=0.582083
         WinLeft=0.472266
         WinWidth=0.421875
     End Object
     Controls(18)=moFloatEdit'XInterface.Tab_IForceSettings.InputDodgeTime'

     Begin Object Class=moCheckBox Name=InputMouseLag
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Reduce Mouse Lag"
         ComponentClassName="xinterface.GUICheckBoxButton"
         OnCreateComponent=InputMouseLag.InternalOnCreateComponent
         Hint="Enable this option will reduce the amount of lag in your mouse."
         WinTop=0.509791
         WinLeft=0.060938
         WinWidth=0.300000
         WinHeight=0.040000
     End Object
     Controls(19)=moCheckBox'XInterface.Tab_IForceSettings.InputMouseLag'

     WinTop=0.150000
     WinHeight=0.740000
}
