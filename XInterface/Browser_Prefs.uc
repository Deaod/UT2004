class Browser_Prefs extends Browser_Page;

var GUITitleBar		StatusBar;

var localized string	ViewStatsStrings[3];
var localized string	MutatorModeStrings[4];
var localized string    WeaponStayStrings[3];
var localized string    TranslocatorStrings[3];

var bool				bIsInitialised;

var array<xUtil.MutatorRecord> MutatorRecords;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.InitComponent(MyController, MyOwner);

	if(bIsInitialised)
		return;

	GUIButton(GUIPanel(Controls[0]).Controls[0]).OnClick=BackClick;

	// Set options for stats server viewing
	moComboBox(Controls[5]).AddItem(ViewStatsStrings[0]);
	moComboBox(Controls[5]).AddItem(ViewStatsStrings[1]);
	moComboBox(Controls[5]).AddItem(ViewStatsStrings[2]);
	moComboBox(Controls[5]).ReadOnly(true);

	// Load mutators into combobox
	class'xUtil'.static.GetMutatorList(MutatorRecords);

	moComboBox(Controls[9]).AddItem(MutatorModeStrings[0]);
	moComboBox(Controls[9]).AddItem(MutatorModeStrings[1]);
	moComboBox(Controls[9]).AddItem(MutatorModeStrings[2]);
	moComboBox(Controls[9]).AddItem(MutatorModeStrings[3]);
	moComboBox(Controls[9]).ReadOnly(true);

	moComboBox(Controls[13]).AddItem(MutatorModeStrings[0]);
	moComboBox(Controls[13]).AddItem(MutatorModeStrings[2]);
	moComboBox(Controls[13]).AddItem(MutatorModeStrings[3]);
	moComboBox(Controls[13]).ReadOnly(true);

	for(i=0; i<MutatorRecords.Length; i++)
	{
		moComboBox(Controls[6]).AddItem(MutatorRecords[i].FriendlyName, None, MutatorRecords[i].ClassName);
		moComboBox(Controls[14]).AddItem(MutatorRecords[i].FriendlyName, None, MutatorRecords[i].ClassName);
	}
	moComboBox(Controls[6]).ReadOnly(true);

	// Weapon stay
	moComboBox(Controls[11]).AddItem(WeaponStayStrings[0]);
	moComboBox(Controls[11]).AddItem(WeaponStayStrings[1]);
	moComboBox(Controls[11]).AddItem(WeaponStayStrings[2]);
	moComboBox(Controls[11]).ReadOnly(true);

	// Translocator
	moComboBox(Controls[12]).AddItem(TranslocatorStrings[0]);
	moComboBox(Controls[12]).AddItem(TranslocatorStrings[1]);
	moComboBox(Controls[12]).AddItem(TranslocatorStrings[2]);
	moComboBox(Controls[12]).ReadOnly(true);

	moNumericEdit(Controls[15]).MyNumericEdit.Step = 10;
	moNumericEdit(Controls[16]).MyNumericEdit.Step = 10;

	for(i=2; i<17; i++)
	{
		Controls[i].OnLoadINI=MyOnLoadINI;
		Controls[i].OnChange=MyOnChange;
	}

	StatusBar = GUITitleBar(GUIPanel(Controls[0]).Controls[1]);

	// Set on click for 'Show Icon Key' button
	GUIButton(GUIPanel(Controls[0]).Controls[2]).OnClick = InternalShowIconKey;

	bIsInitialised=true;
}

// delegates
function bool BackClick(GUIComponent Sender)
{
	Controller.CloseMenu(true);
	return true;
}

function UpdateMutatorVisibility()
{
	// If first one is 'any' or 'none', don't show any mutator selector boxes
	if(Browser.ViewMutatorMode == VMM_AnyMutators || Browser.ViewMutatorMode == VMM_NoMutators)
	{
		Controls[6].bVisible = false;
		Controls[13].bVisible = false;
		Controls[14].bVisible = false;
	}
	else // If its not - show the first mutator selection box, and the second mode box
	{
		Controls[6].bVisible = true;

		Controls[13].bVisible = true;

		// And check the second mode drop-down,
		if(Browser.ViewMutator2Mode == VMM_AnyMutators)
			Controls[14].bVisible = false;
		else
			Controls[14].bVisible = true;
	}
}

function bool InternalShowIconKey(GUIComponent Sender)
{
	Controller.OpenMenu("XInterface.Browser_IconKey");

	return true;
}


///////////////////// LOAD ///////////////////////
function MyOnLoadINI(GUIComponent Sender, string s)
{
	local int i;

	if(Sender == Controls[8])
		moCheckBox(Controls[8]).Checked(Browser.bOnlyShowStandard);
	else if(Sender == Controls[2])
		moCheckBox(Controls[2]).Checked(Browser.bOnlyShowNonPassword);
	else if(Sender == Controls[3])
		moCheckBox(Controls[3]).Checked(Browser.bDontShowFull);
	else if(Sender == Controls[4])
		moCheckBox(Controls[4]).Checked(Browser.bDontShowEmpty);
	else if(Sender == Controls[5])
		moComboBox(Controls[5]).SetText(ViewStatsStrings[Browser.StatsServerView]);
	else if(Sender == Controls[6])
	{
		// Find the Mutator with this class name, and put its friendly name in the box
		for(i=0; i<MutatorRecords.Length; i++)
		{
			if( Browser.DesiredMutator == MutatorRecords[i].ClassName )
			{
				moComboBox(Controls[6]).SetText( MutatorRecords[i].FriendlyName );
				return;
			}
		}
	}
	else if(Sender == Controls[7])
	{
		moEditBox(Controls[7]).SetText(Browser.CustomQuery);
	}
	else if(Sender == Controls[9])
	{
		moComboBox(Controls[9]).SetText( MutatorModeStrings[Browser.ViewMutatorMode] );

		UpdateMutatorVisibility();
	}
	else if(Sender == Controls[10])
		moCheckBox(Controls[10]).Checked(Browser.bDontShowWithBots);
	else if(Sender == Controls[11])
		moComboBox(Controls[11]).SetText(WeaponStayStrings[Browser.WeaponStayServerView]);
	else if(Sender == Controls[12])
		moComboBox(Controls[12]).SetText(TranslocatorStrings[Browser.TranslocServerView]);
	else if(Sender == Controls[13])
	{
		moComboBox(Controls[13]).SetText( MutatorModeStrings[Browser.ViewMutator2Mode] );

		UpdateMutatorVisibility();
	}
	else if(Sender == Controls[14])
	{
		for(i=0; i<MutatorRecords.Length; i++)
		{
			if( Browser.DesiredMutator2 == MutatorRecords[i].ClassName )
			{
				moComboBox(Controls[14]).SetText( MutatorRecords[i].FriendlyName );
				return;
			}
		}
	}
	else if(Sender == Controls[15])
		moNumericEdit(Controls[15]).SetValue(Browser.MinGamespeed);
	else if(Sender == Controls[16])
		moNumericEdit(Controls[16]).SetValue(Browser.MaxGamespeed);
}

///////////////////// SAVE ///////////////////////
function MyOnChange(GUIComponent Sender)
{
	local string t;

	if(Sender == Controls[8])
		Browser.bOnlyShowStandard = moCheckBox(Controls[8]).IsChecked();
	else if(Sender == Controls[2])
		Browser.bOnlyShowNonPassword = moCheckBox(Controls[2]).IsChecked();
	else if(Sender == Controls[3])
		Browser.bDontShowFull = moCheckBox(Controls[3]).IsChecked();
	else if(Sender == Controls[4])
		Browser.bDontShowEmpty = moCheckBox(Controls[4]).IsChecked();
	else if(Sender == Controls[5])
	{
		t = moComboBox(Controls[5]).GetText();

		if(t == ViewStatsStrings[0])
			Browser.StatsServerView = SSV_Any;
		else if(t == ViewStatsStrings[1])
			Browser.StatsServerView = SSV_OnlyStatsEnabled;
		else if(t == ViewStatsStrings[2])
			Browser.StatsServerView = SSV_NoStatsEnabled;
	}
	else if(Sender == Controls[6])
	{
		Browser.DesiredMutator = moComboBox(Controls[6]).GetExtra();
	}
	else if(Sender == Controls[7])
	{
		Browser.CustomQuery = moEditBox(Controls[7]).GetText();
	}
	else if(Sender == Controls[9])
	{
		t = moComboBox(Controls[9]).GetText();

		if(t == MutatorModeStrings[0])
			Browser.ViewMutatorMode = VMM_AnyMutators;
		else if(t == MutatorModeStrings[1])
			Browser.ViewMutatorMode = VMM_NoMutators;
		else if(t == MutatorModeStrings[2])
			Browser.ViewMutatorMode = VMM_ThisMutator;
		else if(t == MutatorModeStrings[3])
			Browser.ViewMutatorMode = VMM_NotThisMutator;

		UpdateMutatorVisibility();
	}
	else if(Sender == Controls[10])
		Browser.bDontShowWithBots = moCheckBox(Controls[10]).IsChecked();
	else if(Sender == Controls[11])
	{
		t = moComboBox(Controls[11]).GetText();

		if(t == WeaponStayStrings[0])
			Browser.WeaponStayServerView = WSSV_Any;
		else if(t == WeaponStayStrings[1])
			Browser.WeaponStayServerView = WSSV_OnlyWeaponStay;
		else if(t == WeaponStayStrings[2])
			Browser.WeaponStayServerView = WSSV_NoWeaponStay;
	}
	else if(Sender == Controls[12])
	{
		t = moComboBox(Controls[12]).GetText();

		if(t == TranslocatorStrings[0])
			Browser.TranslocServerView = TSV_Any;
		else if(t == TranslocatorStrings[1])
			Browser.TranslocServerView = TSV_OnlyTransloc;
		else if(t == TranslocatorStrings[2])
			Browser.TranslocServerView = TSV_NoTransloc;
	}
	else if(Sender == Controls[13])
	{
		t = moComboBox(Controls[13]).GetText();

		if(t == MutatorModeStrings[0])
			Browser.ViewMutator2Mode = VMM_AnyMutators;
		else if(t == MutatorModeStrings[2])
			Browser.ViewMutator2Mode = VMM_ThisMutator;
		else if(t == MutatorModeStrings[3])
			Browser.ViewMutator2Mode = VMM_NotThisMutator;

		UpdateMutatorVisibility();
	}
	else if(Sender == Controls[14])
	{
		Browser.DesiredMutator2 = moComboBox(Controls[14]).GetExtra();
	}
	else if(Sender == Controls[15])
	{
		if( moNumericEdit(Controls[15]).GetValue() < 0 )
			moNumericEdit(Controls[15]).SetValue( 0 );

		Browser.MinGamespeed = moNumericEdit(Controls[15]).GetValue();
	}
	else if(Sender == Controls[16])
	{
		if( moNumericEdit(Controls[16]).GetValue() > 200 )
			moNumericEdit(Controls[16]).SetValue( 200 );

		Browser.MaxGamespeed = moNumericEdit(Controls[16]).GetValue();
	}

	Browser.SaveConfig();
}

defaultproperties
{
     ViewStatsStrings(0)="Any Servers"
     ViewStatsStrings(1)="Only Stats Servers"
     ViewStatsStrings(2)="No Stats Servers"
     MutatorModeStrings(0)="Any Mutators"
     MutatorModeStrings(1)="No Mutators"
     MutatorModeStrings(2)="This Mutator"
     MutatorModeStrings(3)="Not This Mutator"
     WeaponStayStrings(0)="Any Servers"
     WeaponStayStrings(1)="Only Weapon Stay Servers"
     WeaponStayStrings(2)="No Weapon Stay Servers"
     TranslocatorStrings(0)="Any Servers"
     TranslocatorStrings(1)="Only Translocator Servers"
     TranslocatorStrings(2)="No Translocator Servers"
     Begin Object Class=GUIPanel Name=FooterPanel
         Begin Object Class=GUIButton Name=MyBackButton
             Caption="BACK"
             StyleName="SquareMenuButton"
             WinWidth=0.200000
             WinHeight=0.500000
             OnKeyEvent=MyBackButton.InternalOnKeyEvent
         End Object
         Controls(0)=GUIButton'XInterface.Browser_Prefs.MyBackButton'

         Begin Object Class=GUITitleBar Name=MyStatus
             bUseTextHeight=False
             Justification=TXTA_Left
             StyleName="SquareBar"
             WinTop=0.500000
             WinHeight=0.500000
         End Object
         Controls(1)=GUITitleBar'XInterface.Browser_Prefs.MyStatus'

         Begin Object Class=GUIButton Name=MyKeyButton
             Caption="ICON KEY"
             StyleName="SquareMenuButton"
             WinLeft=0.200000
             WinWidth=0.200000
             WinHeight=0.500000
             OnKeyEvent=MyKeyButton.InternalOnKeyEvent
         End Object
         Controls(2)=GUIButton'XInterface.Browser_Prefs.MyKeyButton'

         WinTop=0.900000
         WinHeight=0.100000
     End Object
     Controls(0)=GUIPanel'XInterface.Browser_Prefs.FooterPanel'

     Begin Object Class=GUILabel Name=FilterTitle
         Caption="Server Filtering Options:"
         TextColor=(B=0,G=200,R=230)
         TextFont="UT2HeaderFont"
         WinTop=0.050000
         WinLeft=0.150000
         WinWidth=0.720003
         WinHeight=0.056250
     End Object
     Controls(1)=GUILabel'XInterface.Browser_Prefs.FilterTitle'

     Begin Object Class=moCheckBox Name=NoPasswdCheckBox
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="No Passworded Servers"
         OnCreateComponent=NoPasswdCheckBox.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.210000
         WinLeft=0.050000
         WinWidth=0.340000
         WinHeight=0.040000
     End Object
     Controls(2)=moCheckBox'XInterface.Browser_Prefs.NoPasswdCheckBox'

     Begin Object Class=moCheckBox Name=NoFullCheckBox
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="No Full Servers"
         OnCreateComponent=NoFullCheckBox.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.270000
         WinLeft=0.050000
         WinWidth=0.340000
         WinHeight=0.040000
     End Object
     Controls(3)=moCheckBox'XInterface.Browser_Prefs.NoFullCheckBox'

     Begin Object Class=moCheckBox Name=NoEmptyCheckBox
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="No Empty Servers"
         OnCreateComponent=NoEmptyCheckBox.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.330000
         WinLeft=0.050000
         WinWidth=0.340000
         WinHeight=0.040000
     End Object
     Controls(4)=moCheckBox'XInterface.Browser_Prefs.NoEmptyCheckBox'

     Begin Object Class=moComboBox Name=StatsViewCombo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.400000
         Caption="Stats Servers"
         OnCreateComponent=StatsViewCombo.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.390000
         WinLeft=0.050000
         WinWidth=0.760000
         WinHeight=0.040000
     End Object
     Controls(5)=moComboBox'XInterface.Browser_Prefs.StatsViewCombo'

     Begin Object Class=moComboBox Name=MutatorCombo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.000000
         OnCreateComponent=MutatorCombo.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.450000
         WinLeft=0.675004
         WinWidth=0.308750
         WinHeight=0.060000
     End Object
     Controls(6)=moComboBox'XInterface.Browser_Prefs.MutatorCombo'

     Begin Object Class=moEditBox Name=CustomQuery
         CaptionWidth=0.400000
         Caption="Custom Query"
         OnCreateComponent=CustomQuery.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.750000
         WinLeft=0.050000
         WinWidth=0.760000
         WinHeight=0.040000
     End Object
     Controls(7)=moEditBox'XInterface.Browser_Prefs.CustomQuery'

     Begin Object Class=moCheckBox Name=OnlyStandardCheckBox
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Only Standard Servers"
         OnCreateComponent=OnlyStandardCheckBox.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.150000
         WinLeft=0.050000
         WinWidth=0.340000
         WinHeight=0.040000
     End Object
     Controls(8)=moCheckBox'XInterface.Browser_Prefs.OnlyStandardCheckBox'

     Begin Object Class=moComboBox Name=MutatorModeCombo
         ComponentJustification=TXTA_Left
         Caption="Mutators"
         OnCreateComponent=MutatorModeCombo.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.450000
         WinLeft=0.050000
         WinWidth=0.610000
         WinHeight=0.040000
     End Object
     Controls(9)=moComboBox'XInterface.Browser_Prefs.MutatorModeCombo'

     Begin Object Class=moCheckBox Name=NoBotServersCheckBox
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="No Servers With Bots"
         OnCreateComponent=NoBotServersCheckBox.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.390000
         WinLeft=0.050000
         WinWidth=0.340000
         WinHeight=0.040000
         bVisible=False
     End Object
     Controls(10)=moCheckBox'XInterface.Browser_Prefs.NoBotServersCheckBox'

     Begin Object Class=moComboBox Name=WeaponStayCombo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.400000
         Caption="WeaponStay"
         OnCreateComponent=WeaponStayCombo.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.570000
         WinLeft=0.050000
         WinWidth=0.760000
         WinHeight=0.040000
     End Object
     Controls(11)=moComboBox'XInterface.Browser_Prefs.WeaponStayCombo'

     Begin Object Class=moComboBox Name=TranslocatorCombo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.400000
         Caption="Translocator"
         OnCreateComponent=TranslocatorCombo.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.630000
         WinLeft=0.050000
         WinWidth=0.760000
         WinHeight=0.040000
     End Object
     Controls(12)=moComboBox'XInterface.Browser_Prefs.TranslocatorCombo'

     Begin Object Class=moComboBox Name=MutatorModeCombo2
         ComponentJustification=TXTA_Left
         OnCreateComponent=MutatorModeCombo2.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.510000
         WinLeft=0.050000
         WinWidth=0.610000
         WinHeight=0.040000
     End Object
     Controls(13)=moComboBox'XInterface.Browser_Prefs.MutatorModeCombo2'

     Begin Object Class=moComboBox Name=MutatorCombo2
         ComponentJustification=TXTA_Left
         CaptionWidth=0.000000
         OnCreateComponent=MutatorCombo2.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.510000
         WinLeft=0.675004
         WinWidth=0.308750
         WinHeight=0.060000
     End Object
     Controls(14)=moComboBox'XInterface.Browser_Prefs.MutatorCombo2'

     Begin Object Class=moNumericEdit Name=MinGamespeed
         MinValue=0
         MaxValue=200
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Game Speed Min"
         OnCreateComponent=MinGamespeed.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.690000
         WinLeft=0.050000
         WinWidth=0.433750
         WinHeight=0.060000
     End Object
     Controls(15)=moNumericEdit'XInterface.Browser_Prefs.MinGamespeed'

     Begin Object Class=moNumericEdit Name=MaxGamespeed
         MinValue=0
         MaxValue=200
         ComponentJustification=TXTA_Left
         CaptionWidth=0.400000
         Caption="Max"
         OnCreateComponent=MaxGamespeed.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.690000
         WinLeft=0.557501
         WinWidth=0.235000
         WinHeight=0.060000
     End Object
     Controls(16)=moNumericEdit'XInterface.Browser_Prefs.MaxGamespeed'

}
