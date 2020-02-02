// ====================================================================
//  Class:  XInterface.Tab_DetailSettings
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_DetailSettings extends UT2K3TabPanel;

var config bool bExpert;
var localized string	DetailLevels[7];
var bool				bPlayedSound;

// bit hacky - but needed to know if we are increasing detail
var int					prevWorldDetail, prevTextureDetail, prevCharDetail;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	Super.Initcomponent(MyController, MyOwner);

	for (i=0;i<Controls.Length;i++)
		Controls[i].OnChange=InternalOnChange;

	if(PlayerOwner().Level.IsDemoBuild())
	{
		for(i = 0;i < 4;i++)
			moComboBox(Controls[1]).AddItem(DetailLevels[i]);
		for(i = 0;i < 4;i++)
			moComboBox(Controls[2]).AddItem(DetailLevels[i]);
	}
	else
	{
		for(i = 0;i < ArrayCount(DetailLevels);i++)
			moComboBox(Controls[1]).AddItem(DetailLevels[i]);
		for(i = 0;i < ArrayCount(DetailLevels);i++)
			moComboBox(Controls[2]).AddItem(DetailLevels[i]);
	}
	moComboBox(Controls[1]).ReadOnly(True);
	moComboBox(Controls[2]).ReadOnly(True);

	moComboBox(Controls[3]).AddItem(DetailLevels[3]);
	moComboBox(Controls[3]).AddItem(DetailLevels[4]);
	moComboBox(Controls[3]).AddItem(DetailLevels[6]);
	moComboBox(Controls[3]).ReadOnly(True);

	for(i = 2;i < 5;i++)
		moComboBox(Controls[4]).AddItem(DetailLevels[i]);
	moComboBox(Controls[4]).ReadOnly(True);

	for(i = 2;i < 5;i++)
		moComboBox(Controls[10]).AddItem(DetailLevels[i]);
	moComboBox(Controls[10]).ReadOnly(True);
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local int i;
	local bool a, b;

	if (Sender==Controls[1])
	{
		if(s == "UltraLow")
			prevTextureDetail=0;
		else if(s == "Low")
			prevTextureDetail=1;
		else if(s == "Lower")
			prevTextureDetail=2;
		else if(s == "Normal")
			prevTextureDetail=3;
		else if(s == "Higher")
			prevTextureDetail=4;
		else if(s == "High")
			prevTextureDetail=5;
		else if(s == "UltraHigh")
			prevTextureDetail=6;

		moComboBox(Sender).SetText(DetailLevels[prevTextureDetail]);
	}

	else if (Sender==Controls[2])
	{
		if(s == "UltraLow")
			prevCharDetail=0;
		else if(s == "Low")
			prevCharDetail=1;
		else if(s == "Lower")
			prevCharDetail=2;
		else if(s == "Normal")
			prevCharDetail=3;
		else if(s == "Higher")
			prevCharDetail=4;
		else if(s == "High")
			prevCharDetail=5;
		else if(s == "UltraHigh")
			prevCharDetail=6;

		moComboBox(Sender).SetText(DetailLevels[prevCharDetail]);
	}

	else if (Sender==Controls[3])
	{
		a = bool(PlayerOwner().ConsoleCommand("get ini:Engine.Engine.RenderDevice HighDetailActors"));
		b = bool(PlayerOwner().ConsoleCommand("get ini:Engine.Engine.RenderDevice SuperHighDetailActors"));

		if(b)
			prevWorldDetail=6;
		else if(a)
			prevWorldDetail=4;
		else
			prevWorldDetail=3;

		moComboBox(Sender).SetText(DetailLevels[prevWorldDetail]);
	}

	else if (Sender==Controls[4])
	{
		if(PlayerOwner().Level.default.PhysicsDetailLevel == PDL_Low)
			moComboBox(Sender).SetText(DetailLevels[2]);
		else if(PlayerOwner().Level.default.PhysicsDetailLevel == PDL_Medium)
			moComboBox(Sender).SetText(DetailLevels[3]);
		else
			moComboBox(Sender).SetText(DetailLevels[4]);
	}

	else if (Sender==Controls[5])
		moCheckBox(Sender).Checked(class'UnrealPawn'.default.bPlayerShadows);

	else if (Sender==Controls[7])
		moCheckBox(Sender).Checked(!bool(s));

	else if (Sender==Controls[10])
	{
		i = PlayerOwner().Level.default.DecalStayScale;

		switch (i)
		{
			case 0 : moComboBox(Sender).SetText(DetailLevels[2]);break;
			case 1 : moComboBox(Sender).SetText(DetailLevels[3]);break;
			case 2 : moComboBox(Sender).SetText(DetailLevels[4]);break;
		}
	}

    else if (Sender==Controls[14])
    	moCheckBox(Sender).Checked(class'UnrealPawn'.Default.bBlobShadow);

	else
		moCheckBox(Sender).Checked(bool(s));
}

function string InternalOnSaveINI(GUIComponent Sender); 		// Do the actual work here

function InternalOnChange(GUIComponent Sender)
{
	local String t,v;
	local bool b, goingUp;
	local int newDetail;

	if (!Controller.bCurMenuInitialized)
		return;

	if (Sender==Controls[1])
	{
		t = "set ini:Engine.Engine.ViewportManager TextureDetail";

		if(moComboBox(Sender).GetText() == DetailLevels[0])
		{
			v = "UltraLow";
			newDetail = 0;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[1])
		{
			v = "Low";
			newDetail = 1;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[2])
		{
			v = "Lower";
			newDetail = 2;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[3])
		{
			v = "Normal";
			newDetail = 3;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[4])
		{
			v = "Higher";
			newDetail = 4;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[5])
		{
			v = "High";
			newDetail = 5;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[6])
		{
			v = "UltraHigh";
			newDetail = 6;
		}

		PlayerOwner().ConsoleCommand(t$"Terrain"@v);
		PlayerOwner().ConsoleCommand(t$"World"@v);
		PlayerOwner().ConsoleCommand(t$"Rendermap"@v);
		PlayerOwner().ConsoleCommand(t$"Lightmap"@v);
		PlayerOwner().ConsoleCommand("flush");

		if(newDetail > prevTextureDetail)
			goingUp = true;

		prevTextureDetail = newDetail;
	}

	else if (Sender==Controls[2])
	{
		t = "set ini:Engine.Engine.ViewportManager TextureDetail";

		if(moComboBox(Sender).GetText() == DetailLevels[0])
		{
			v = "UltraLow";
			newDetail = 0;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[1])
		{
			v = "Low";
			newDetail = 1;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[2])
		{
			v = "Lower";
			newDetail = 2;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[3])
		{
			v = "Normal";
			newDetail = 3;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[4])
		{
			v = "Higher";
			newDetail = 4;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[5])
		{
			v = "High";
			newDetail = 5;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[6])
		{
			v = "UltraHigh";
			newDetail = 6;
		}

		PlayerOwner().ConsoleCommand(t$"WeaponSkin"@v);
		PlayerOwner().ConsoleCommand(t$"PlayerSkin"@v);
		PlayerOwner().ConsoleCommand("flush");

		if(newDetail > prevCharDetail)
			goingUp = true;

		prevCharDetail = newDetail;
	}

	else if (Sender==Controls[3])
	{
		if(moComboBox(Sender).GetText() == DetailLevels[6])
		{
			PlayerOwner().ConsoleCommand("set ini:Engine.Engine.RenderDevice HighDetailActors True");
			PlayerOwner().ConsoleCommand("set ini:Engine.Engine.RenderDevice SuperHighDetailActors True");
			PlayerOwner().Level.DetailChange(DM_SuperHigh);
			newDetail = 6;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[4])
		{
			PlayerOwner().ConsoleCommand("set ini:Engine.Engine.RenderDevice HighDetailActors True");
			PlayerOwner().ConsoleCommand("set ini:Engine.Engine.RenderDevice SuperHighDetailActors False");
			PlayerOwner().Level.DetailChange(DM_High);
			newDetail = 4;
		}
		else if(moComboBox(Sender).GetText() == DetailLevels[3])
		{
			PlayerOwner().ConsoleCommand("set ini:Engine.Engine.RenderDevice HighDetailActors False");
			PlayerOwner().ConsoleCommand("set ini:Engine.Engine.RenderDevice SuperHighDetailActors False");
			PlayerOwner().Level.DetailChange(DM_Low);
			newDetail = 3;
		}

		if(newDetail > prevWorldDetail)
			goingUp = true;

		prevWorldDetail = newDetail;
	}

	else if (Sender==Controls[4])
	{
		if (moComboBox(Sender).GetText()==DetailLevels[2])
			PlayerOwner().Level.default.PhysicsDetailLevel=PDL_Low;
		else if (moComboBox(Sender).GetText()==DetailLevels[3])
			PlayerOwner().Level.default.PhysicsDetailLevel=PDL_Medium;
		else if (moComboBox(Sender).GetText()==DetailLevels[4])
			PlayerOwner().Level.default.PhysicsDetailLevel=PDL_High;

		PlayerOwner().Level.PhysicsDetailLevel = PlayerOwner().Level.default.PhysicsDetailLevel;
		PlayerOwner().Level.SaveConfig();
	}

	else if (Sender==Controls[5])
	{
		PlayerOwner().ConsoleCommand("set UnrealPawn bPlayerShadows "$moCheckBox(Sender).IsChecked());
		class'UnrealPawn'.default.bPlayerShadows = moCheckBox(Sender).IsChecked();
		class'UnrealPawn'.static.StaticSaveConfig();

		if( moCheckBox(Sender).IsChecked() )
			goingUp = true;
	}

    else if (Sender==Controls[14])
    {
		PlayerOwner().ConsoleCommand("set UnrealPawn bBlobShadow "$moCheckBox(Sender).IsChecked());
		class'UnrealPawn'.default.bBlobShadow = moCheckBox(Sender).IsChecked();
		class'UnrealPawn'.static.StaticSaveConfig();
    }

	else if (Sender==Controls[7])
	{
		b = moCheckBox(Sender).IsChecked();
		b = b!=true;
		PlayerOwner().ConsoleCommand("set"@Sender.INIOption@b);

		if( moCheckBox(Sender).IsChecked() )
			goingUp = true;
	}

	else if (Sender==Controls[10])
	{
		if (moComboBox(Sender).GetText()==DetailLevels[4])
			PlayerOwner().Level.default.DecalStayScale=2;
		else if (moComboBox(Sender).GetText()==DetailLevels[3])
			PlayerOwner().Level.default.DecalStayScale=1;
		else if (moComboBox(Sender).GetText()==DetailLevels[2])
			PlayerOwner().Level.default.DecalStayScale=0;

		PlayerOwner().Level.DecalStayScale=PlayerOwner().Level.default.DecalStayScale;
		PlayerOwner().Level.SaveConfig();
	}

	else
	{
		PlayerOwner().ConsoleCommand("set"@Sender.INIOption@moCheckBox(Sender).IsChecked());

		if( moCheckBox(Sender).IsChecked() )
			goingUp = true;
	}

	// If we have increased the detail level, show paranoid warning
	if (goingUp && !bExpert)
		Controller.OpenMenu("XInterface.UT2PerformWarn");


	// Check if we are maxed out (and mature-enabled)!
	if( !bPlayedSound && !PlayerOwner().bNoMatureLanguage &&
		moComboBox(Controls[1]).GetText() == DetailLevels[6] &&
		moComboBox(Controls[2]).GetText() == DetailLevels[6] &&
		moComboBox(Controls[3]).GetText() == DetailLevels[6] &&
		moComboBox(Controls[4]).GetText() == DetailLevels[4] &&
		moCheckBox(Controls[5]).IsChecked() &&
		moCheckBox(Controls[6]).IsChecked() &&
		moCheckBox(Controls[7]).IsChecked() &&
		moCheckBox(Controls[8]).IsChecked() &&
		moCheckBox(Controls[9]).IsChecked() &&
		moComboBox(Controls[10]).GetText() == DetailLevels[4] &&
		moCheckBox(Controls[11]).IsChecked() &&
		moCheckBox(Controls[12]).IsChecked() )
	{
		PlayerOwner().ClientPlaySound(sound'AnnouncerMale2K4.HolyShit_F');
		bPlayedSound = true;
	}
}

defaultproperties
{
     DetailLevels(0)="Lowest"
     DetailLevels(1)="Lower"
     DetailLevels(2)="Low"
     DetailLevels(3)="Normal"
     DetailLevels(4)="High"
     DetailLevels(5)="Higher"
     DetailLevels(6)="Highest"
     Begin Object Class=GUIImage Name=DetailBK
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.320000
         WinLeft=0.021641
         WinWidth=0.957500
         WinHeight=0.521250
     End Object
     Controls(0)=GUIImage'XInterface.Tab_DetailSettings.DetailBK'

     Begin Object Class=moComboBox Name=DetailWorldDetail
         ComponentJustification=TXTA_Left
         Caption="Texture Detail"
         OnCreateComponent=DetailWorldDetail.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.ViewportManager TextureDetailWorld"
         IniDefault="High"
         Hint="Changes how much world detail will be rendered."
         WinTop=0.100000
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.050000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(1)=moComboBox'XInterface.Tab_DetailSettings.DetailWorldDetail'

     Begin Object Class=moComboBox Name=DetailCharacterDetail
         ComponentJustification=TXTA_Left
         Caption="Character Detail"
         OnCreateComponent=DetailCharacterDetail.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.ViewportManager TextureDetailPlayerSkin"
         IniDefault="High"
         Hint="Changes how much character detail will be rendered."
         WinTop=0.100000
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.050000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(2)=moComboBox'XInterface.Tab_DetailSettings.DetailCharacterDetail'

     Begin Object Class=moComboBox Name=DetailActorDetail
         ComponentJustification=TXTA_Left
         Caption="World Detail"
         OnCreateComponent=DetailActorDetail.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="High"
         Hint="Changes the level of detail used for optional geometry and effects."
         WinTop=0.200000
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.050000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(3)=moComboBox'XInterface.Tab_DetailSettings.DetailActorDetail'

     Begin Object Class=moComboBox Name=DetailPhysics
         ComponentJustification=TXTA_Left
         Caption="Physics Detail"
         OnCreateComponent=DetailPhysics.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="High"
         Hint="Changes the physics simulation level of detail."
         WinTop=0.200000
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.050000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(4)=moComboBox'XInterface.Tab_DetailSettings.DetailPhysics'

     Begin Object Class=moCheckBox Name=DetailCharacterShadows
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Character Shadows"
         OnCreateComponent=DetailCharacterShadows.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables character shadows."
         WinTop=0.360000
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.050000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(5)=moCheckBox'XInterface.Tab_DetailSettings.DetailCharacterShadows'

     Begin Object Class=moCheckBox Name=DetailDecals
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Decals"
         OnCreateComponent=DetailDecals.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.ViewportManager Decals"
         IniDefault="True"
         Hint="Enables weapon scarring effects."
         WinTop=0.360000
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.050000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(6)=moCheckBox'XInterface.Tab_DetailSettings.DetailDecals'

     Begin Object Class=moCheckBox Name=DetailDynamicLighting
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Dynamic Lighting"
         OnCreateComponent=DetailDynamicLighting.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.ViewportManager NoDynamicLights"
         IniDefault="True"
         Hint="Enables dynamic lights."
         WinTop=0.460000
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.050000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(7)=moCheckBox'XInterface.Tab_DetailSettings.DetailDynamicLighting'

     Begin Object Class=moCheckBox Name=DetailCoronas
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Coronas"
         OnCreateComponent=DetailCoronas.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.ViewportManager Coronas"
         IniDefault="True"
         Hint="Enables coronas."
         WinTop=0.460000
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.050000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(8)=moCheckBox'XInterface.Tab_DetailSettings.DetailCoronas'

     Begin Object Class=moCheckBox Name=DetailDetailTextures
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Detail Textures"
         OnCreateComponent=DetailDetailTextures.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.RenderDevice DetailTextures"
         IniDefault="True"
         Hint="Enables detail textures."
         WinTop=0.560000
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.050000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(9)=moCheckBox'XInterface.Tab_DetailSettings.DetailDetailTextures'

     Begin Object Class=moComboBox Name=DetailDecalStay
         ComponentJustification=TXTA_Left
         Caption="Decal Stay"
         OnCreateComponent=DetailDecalStay.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="Normal"
         Hint="Changes how long weapon scarring effects stay around."
         WinTop=0.550000
         WinLeft=0.598750
         WinWidth=0.350000
         WinHeight=0.060000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(10)=moComboBox'XInterface.Tab_DetailSettings.DetailDecalStay'

     Begin Object Class=moCheckBox Name=DetailProjectors
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Projectors"
         OnCreateComponent=DetailProjectors.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.ViewportManager Projectors"
         IniDefault="True"
         Hint="Enables Projectors."
         WinTop=0.656251
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(11)=moCheckBox'XInterface.Tab_DetailSettings.DetailProjectors'

     Begin Object Class=moCheckBox Name=DetailDecoLayers
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Foliage"
         OnCreateComponent=DetailDecoLayers.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.ViewportManager DecoLayers"
         IniDefault="True"
         Hint="Enables grass and other decorative foliage."
         WinTop=0.656251
         WinLeft=0.598750
         WinWidth=0.300000
         WinHeight=0.040000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(12)=moCheckBox'XInterface.Tab_DetailSettings.DetailDecoLayers'

     Begin Object Class=moCheckBox Name=DetailTrilinear
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Trilinear Filtering"
         OnCreateComponent=DetailTrilinear.InternalOnCreateComponent
         IniOption="ini:Engine.Engine.RenderDevice UseTrilinear"
         IniDefault="False"
         Hint="Enable trilinear filtering, recommended for high-performance PCs."
         WinTop=0.750000
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
         OnSaveINI=Tab_DetailSettings.InternalOnSaveINI
     End Object
     Controls(13)=moCheckBox'XInterface.Tab_DetailSettings.DetailTrilinear'

     Begin Object Class=moCheckBox Name=DetailBlob
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Use Blob Shadows"
         OnCreateComponent=DetailBlob.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Enable blob shadows.  Recommended for low-performance PCs."
         WinTop=0.750000
         WinLeft=0.598750
         WinWidth=0.300000
         WinHeight=0.040000
         OnLoadINI=Tab_DetailSettings.InternalOnLoadINI
     End Object
     Controls(14)=moCheckBox'XInterface.Tab_DetailSettings.DetailBlob'

     WinTop=0.150000
     WinHeight=0.740000
}
