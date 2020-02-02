//==============================================================================
//  Created on: 11/23/2003
//  Manages playinfo settings for remote server
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class RemotePlayInfoPanel extends UT2K4PlayInfoPanel;

delegate SettingChanged( string SettingName, string NewValue );

function InitComponent( GUIController InController, GUIComponent InOwner )
{
	Super.InitComponent(InController, InOwner);
	lb_Rules.FillOwner();
}

function PlayInfo GetPlayInfo()
{
	if ( GamePI == None )
		GamePI = new(None) class'PlayInfo';

	return GamePI;
}

function ReceivedRule( string PropertyName, string ClassName, string CurrentValue )
{
	local int i;
	local class<Info> OwnerClass;

	GetPlayInfo();
	i = GamePI.FindIndex(PropertyName);
	if( i == -1 )  // setting not found, need to load it
	{
		OwnerClass = class<Info>(DynamicLoadObject(ClassName,class'Class'));
		if (OwnerClass != None)
		{
			OwnerClass.static.FillPlayInfo(GamePI);
			i = GamePI.FindIndex(PropertyName);
			if( i == -1 )
			{
				log("Failed to find PlayInfo Setting " $ PropertyName);
				return;
			}
		}
		else
		{
			Log("Failed to load " $ ClassName);
			return;
		}
	}

	StoreSetting(i, CurrentValue);
	InfoRules[InfoRules.Length] = GamePI.Settings[i];
}

function ReceivedValue( string SettingName, string Value )
{
	local int gidx, ridx, lidx;

	gidx = GamePI.FindIndex(SettingName);
	if ( gidx != -1 )
	{
		ridx = GetInfoRuleIndex(gidx);
		if ( ridx != -1 )
		{
			lidx = FindComponentWithTag(ridx);
			if ( lidx >= 0 && lidx < li_Rules.Elements.Length )
				li_Rules.Elements[lidx].SetComponentValue(Value,True);
		}
	}
}

function ClearRules()
{
	if ( GamePI != None )
		GamePI.Clear();
	InfoRules.Remove(0, InfoRules.Length);
}

function Refresh()
{
	Super.ClearRules();
	LoadRules();
}

function LoadRules()
{
	local int i, idx, lastidx;

	GamePI.Sort(0);

	lastidx = -1;
	for ( i = 0; i < GamePI.Settings.Length; i++ )
	{
		idx = GetInfoRuleIndex(i);
		if ( idx != -1 )
		{
			if ( lastidx == -1 || InfoRules[idx].Grouping != InfoRules[lastidx].Grouping )
				AddGroupHeader(idx, li_Rules.Elements.Length == 0);

			AddRule(InfoRules[idx], idx);
			lastidx = idx;
		}
	}

	Super.LoadRules();
}

function int GetInfoRuleIndex( int GamePIIndex )
{
	local int i;

	if ( GamePI == None || GamePIIndex < 0 || GamePIIndex >= GamePI.Settings.Length )
		return -1;

	for ( i = 0; i < InfoRules.Length; i++ )
		if ( InfoRules[i].SettingName ~= GamePI.Settings[GamePIIndex].SettingName )
			return i;

	return -1;
}

function UpdateSetting(GUIMenuOption Sender)
{
    local int i;
    local int Index;
    local string Value;

    if (Sender == None)
        return;

    i = Sender.Tag;
    if (i < 0)
        return;

	GetPlayInfo();
    if (InfoRules[i].DisplayName != Sender.Caption)
    {
    	if ( Controller.bModAuthor )
		{
		   	log("Corrupt list index detected in component"@Sender.Name,'ModAuthor');
    		DumpListElements( FindComponentIndex(Sender), i );
    	}
    	return;
    }

    Index = GamePI.FindIndex(InfoRules[i].SettingName);
    if (InfoRules[i].DisplayName != Sender.Caption || Index == -1)
    {
    	if ( Controller.bModAuthor )
    	{
	    	log("Invalid setting requested from PlayInfo!",'ModAuthor');
	    	DumpListElements(FindComponentIndex(Sender), i);
	    }
    	return;
    }

	Value = Sender.GetComponentValue();
    StoreSetting(Index, Value);
    SettingChanged( GamePI.Settings[Index].SettingName, GamePI.Settings[Index].Value );
}
/*
event Free()
{
	GamePI = None;
	Super.Free();
}
*/

defaultproperties
{
     NumColumns=2
}
