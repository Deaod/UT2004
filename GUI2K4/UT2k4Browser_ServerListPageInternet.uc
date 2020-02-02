//====================================================================
//  Browser page for internet servers
//
//  Written by Ron Prestenback
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class UT2K4Browser_ServerListPageInternet extends UT2K4Browser_ServerListPageMS
	DependsOn(CustomFilter);


var CustomFilter LoadCustomFilter;
var config int PlayCount;
var config int ShowAt;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	Browser.co_GameType.OnChange = NewGameType;
	GameTypeChanged(UT2K4Browser_ServersList(Browser.co_GameType.GetObject()));

	if (PlayCount<ShowAt)
		PlayCount++;
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);

	if ( bShow && bInit )
		bInit = False;
}

function Refresh()
{
	local int i, j;
	local string TmpString;
	local array<CustomFilter.AFilterRule> Rules;

	local MasterServerClient.QueryData QueryItem;

	GameTypeChanged(UT2K4Browser_ServersList(Browser.co_GameType.GetObject()));
	Super.Refresh();

	if (PlayCount==ShowAt)
	{
	    Controller.OpenMenu("gui2k4.UT2K4TryAMod",""$PlayCount);
		PlayCount=ShowAt+1;
	}
	SaveConfig();

	AddQueryTerm("gametype", GetItemName(Browser.CurrentGameType), QT_Equals);

	if ( Browser.bStandardServersOnly )
		AddQueryTerm( "standard", "true", QT_Equals );

	// Add any extra filtering to the query
	for (i = 0; i < FilterMaster.AllFilters.Length; i++)
	{
		if ( FilterMaster.IsActiveAt(i) )
		{
			Rules = FilterMaster.GetFilterRules( i );
			for (j = 0; j < Rules.Length; j++)
			{
				QueryItem = Rules[j].FilterItem;
				if (ValidateQueryItem(Rules[j].FilterType, QueryItem ))
				{
					TmpString = QueryItem.Value;
					if (QueryItem.QueryType < 2)
						class'CustomFilter'.static.ChopClass(TmpString);

					AddQueryTerm( QueryItem.Key, TmpString, QueryItem.QueryType );
				}
			}
		}
	}

	// Run query
	Browser.Uplink().StartQuery(CTM_Query);
	SetFooterCaption(StartQueryString);
}

function ClearAllLists()
{
	local int i;
	local GUIList ComboList;
	local UT2K4Browser_ServersList List;

	if ( Browser == None || Browser.co_GameType == None )
		return;

	ComboList = Browser.co_GameType.MyComboBox.List;
	for ( i = 0; i < ComboList.ItemCount; i++ )
	{
		List = UT2K4Browser_ServersList(ComboList.GetObject());
		if ( List != None )
		{
			List.OnChange = None;
			List.SetAnchor(None);
			List.Clear();
		}
	}
}

function InitServerList()
{
	li_Server = UT2K4Browser_ServersList(lb_Server.List);
	li_Server.OnChange = ServerListChanged;
	li_Server.bPresort = True;
	lb_Server.SetAnchor(Self);
}

function NewGameType(GUIComponent Sender)
{
	local string SelectedGame;
	local UT2K4Browser_ServersList List;

	if (Sender != Browser.co_GameType)
		return;

	SelectedGame = moComboBox(Sender).GetExtra();
	if (Browser.CurrentGameType ~= SelectedGame)
		return;

	Browser.CurrentGameType = SelectedGame;
	Browser.SaveConfig();
//	Refresh();

	List = UT2K4Browser_ServersList(Browser.co_GameType.GetObject());
	if ( List.Servers.Length == 0 )
		Refresh();
	else
	{
		GameTypeChanged(List);
		BindQueryClient(Browser.Uplink());
		li_Server.AutoPingServers();
	}
}

function GameTypeChanged(UT2K4Browser_ServersList NewList)
{
	if (NewList != None)
	{
		if (li_Server != None)
		{
			li_Server.OnChange = None;
			li_Server.StopPings();
			li_Server.SetAnchor(None);
		}

		lb_Server.InitBaseList(NewList);
	}

	InitServerList();
}

function bool ValidateQueryItem(CustomFilter.EDataType FilterType, MasterServerClient.QueryData Data)
{
	local int i;

	if (Data.QueryType == QT_Disabled)
		return false;

	switch (FilterType)
	{
		case DT_Unique:
			for (i = 0; i < Browser.Uplink().Query.Length; i++)
			{
				if (Browser.Uplink().Query[i].Key == Data.Key)
					return false;
			}

   			return true;

		case DT_Ranged:
			if (Data.QueryType == QT_NotEquals)
				return false;

			for (i = 0; i < Browser.Uplink().Query.Length; i++)
			{
				if (Browser.Uplink().Query[i].Key == Data.Key)
				{
					if (Data.QueryType == QT_Equals)
					   return false;

  					switch (Browser.Uplink().Query[i].QueryType)
					{
						case QT_GreaterThan:
							if (Data.QueryType == QT_GreaterThanEquals)
								return false;

						case QT_GreaterThanEquals:
							if (Data.QueryType == QT_GreaterThan)
								return false;

							if (Browser.Uplink().Query[i].Value >= Data.Value)
							   return false;

                            break;

						case QT_LessThan:
						     if (Data.QueryType == QT_LessThanEquals)
						        return false;

						case QT_LessThanEquals:
						     if (Data.QueryType == QT_LessThan)
						        return false;

			                 if (Browser.Uplink().Query[i].Value <= Data.Value)
			                    return false;

					}

					break;
				}
			}

			return true;

		case DT_Multiple:
		     for (i = 0; i < Browser.Uplink().Query.Length; i++)
		         if ((Browser.Uplink().Query[i].Key == Data.Key) &&
		         	 (Browser.Uplink().Query[i].Value == Data.Value))
		               return false;

			return true;
	}

	return false;
}

function FilterClicked()
{
	if ( Controller.OpenMenu(Controller.FilterMenu) )
	{
		Controller.ActivePage.OnClose = FiltersClosed;
		if ( li_Server != None )
			li_Server.StopPings();
	}
}

function FiltersClosed(bool bCancelled)
{
	if ( !bCancelled )
	{
		ClearAllLists();
		Refresh();
	}
	else if ( li_Server != None )
		li_Server.AutoPingServers();
}

function bool ShouldDisplayGameType()
{
	return true;
}

function bool IsFilterAvailable( out string ButtonCaption )
{
	ButtonCaption = FilterCaption;
	return !class'LevelInfo'.static.IsDemoBuild();
}

defaultproperties
{
     PlayCount=11
     ShowAt=10
}
