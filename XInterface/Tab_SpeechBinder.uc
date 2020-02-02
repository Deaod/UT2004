class Tab_SpeechBinder extends Tab_ControlSettings;

var transient bool bNoMatureLanguage;
var localized string SpeechLabel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	GUILabel(Controls[4]).Caption = SpeechLabel;
	Controls[7].bVisible = false; // Hide 'reset' button

	LoadSpeechCommands();

	bNoMatureLanguage = MyController.ViewportOwner.Actor.bNoMatureLanguage;

	Super.Initcomponent(MyController, MyOwner);
}

function InitBindings()
{
	local int i,j,k,index;
	local string KeyName, Alias, LocalizedKeyName;

	// Clear them all.

	for (i=0;i<Bindings.Length;i++)
	{
		if (Bindings[i].Binds.Length>0)
			Bindings[i].Binds.Remove(0,Bindings[i].Binds.Length);

		if (Bindings[i].BindKeyNames.Length>0)
			Bindings[i].BindKeyNames.Remove(0,Bindings[i].BindKeyNames.Length);

		if (Bindings[i].BindLocalizedKeyNames.Length>0)
			Bindings[i].BindLocalizedKeyNames.Remove(0,Bindings[i].BindLocalizedKeyNames.Length);

		MyListBox.List.Add(Bindings[i].KeyLabel);

	}

	for (i=0;i<255;i++)
	{
		KeyName = PlayerOwner().ConsoleCommand("KEYNAME"@i);
		LocalizedKeyName = PlayerOwner().ConsoleCommand("LOCALIZEDKEYNAME"@i);
		if (KeyName!="")
		{
			Alias = PlayerOwner().ConsoleCommand("KEYBINDING"@KeyName);
			if (Alias!="")
			{
				for (j=0;j<Bindings.Length;j++)
				{
					if (Bindings[j].Alias ~= Alias)
					{
						index = Bindings[j].Binds.Length;

						Bindings[j].Binds[index] = i;
						Bindings[j].BindKeyNames[Index] = KeyName;
						Bindings[j].BindLocalizedKeyNames[Index] = LocalizedKeyName;

						for (k=0;k<index;k++)
						{
							if ( Weight(Bindings[j].Binds[k]) < Weight(Bindings[j].Binds[Index]) )
							{
								Swap(j,k,Index);
								break;
							}
						}
					}
				}
			}
		}
	}
}

function AddCommand(bool IsSection, string KeyLabel, string Alias)
{
	local int At;

    At = Bindings.Length;
    Bindings.Length = Bindings.Length + 1;

	Bindings[At].bIsSectionLabel = IsSection;
	Bindings[At].KeyLabel = KeyLabel;
	Bindings[At].Alias = Alias;
}



// We pass in the controller here
function LoadSpeechCommands()
{
	local int i;

	Bindings.Remove(0,Bindings.Length);

	//////////////////////////////// ACKNOWLEDGEMENTS /////////////////////////////////////////////
	AddCommand(true, class'ExtendedConsole'.default.SMStateName[1], "");

	for(i=0; i<class'xVoicePack'.default.numAcks; i++)
	{
		AddCommand(false, class'xVoicePack'.default.AckString[i], "speech ACK "$i);
	}

	//////////////////////////////// FRIENDLY FIRE /////////////////////////////////////////////
	AddCommand(true, class'ExtendedConsole'.default.SMStateName[2], "");

	for(i=0; i<class'xVoicePack'.default.numFFires; i++)
	{
		if( class'xVoicePack'.default.FFireAbbrev[i] != "" )
			AddCommand(false, class'xVoicePack'.default.FFireAbbrev[i], "speech FRIENDLYFIRE "$i);
		else
			AddCommand(false, class'xVoicePack'.default.FFireString[i], "speech FRIENDLYFIRE "$i);
	}

	//////////////////////////////// ORDERS /////////////////////////////////////////////
	AddCommand(true, class'ExtendedConsole'.default.SMStateName[3], "");

	for(i=0; i<16; i++)
	{
		if( class'xVoicePack'.default.OrderString[i] == "" )
			continue;

		if(class'xVoicePack'.default.OrderAbbrev[i] != "")
			AddCommand(false, class'xVoicePack'.default.OrderAbbrev[i], "speech ORDER "$i);
		else
			AddCommand(false, class'xVoicePack'.default.OrderString[i], "speech ORDER "$i);
	}

	//////////////////////////////// OTHER /////////////////////////////////////////////
	AddCommand(true, class'ExtendedConsole'.default.SMStateName[4], "");

	for(i=0; i<ArrayCount(class'xVoicePack'.default.OtherString); i++)
	{
		if( class'xVoicePack'.default.OtherString[i] == "" )
			continue;

		if( class'xVoicePack'.default.OtherAbbrev[i] != "" )
			AddCommand(false, class'xVoicePack'.default.OtherAbbrev[i], "speech OTHER "$i);
		else
			AddCommand(false, class'xVoicePack'.default.OtherString[i], "speech OTHER "$i);
	}

	//////////////////////////////// LOAD TAUNTS /////////////////////////////////////////////
	// NB. This wont get species-specific taunts. Oh well :)
	AddCommand(true, class'ExtendedConsole'.default.SMStateName[5], "");

	for(i=0; i<class'xVoicePack'.default.numTaunts; i++)
	{
		if( class'xVoicePack'.default.MatureTaunt[i] == 1 && bNoMatureLanguage )
			continue;

		if( class'xVoicePack'.default.TauntAbbrev[i] != "" )
			AddCommand(false, class'xVoicePack'.default.TauntAbbrev[i], "speech TAUNT "$i);
		else
			AddCommand(false, class'xVoicePack'.default.TauntString[i], "speech TAUNT "$i);
	}
}

defaultproperties
{
     SpeechLabel="Phrase"
}
