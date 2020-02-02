//=============================================================================
// ObjectiveProgressDisplay
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ObjectiveProgressDisplay extends Info
	config;

var HUD_Assault			ASHUD;
var localized String	HeaderText, OptionalObjectivePrefix, ObjTimesString, TextCutSuffix, SpaceSeparator, PrimaryObjectivePrefix;
var float				SlideScale;

var vector				BoxSize, BoxPivot;

var()	float	SlideSpeed;

simulated function ShowStatus( bool bShow );
simulated function UpdateSlideScale( float DeltaTime );

simulated function Initialize( HUD_Assault H )
{
	ASHUD = H;
}

auto state Hidden
{
	simulated function ShowStatus( bool bShow )
	{
		if ( bShow )
			GotoState('SlideIn');
	}

	simulated function PostRender( Canvas C, float DeltaTime, bool bDefender )
	{
		DrawBigCurrentObjective( C, bDefender, false );
	}
}

state Visible
{
	simulated function ShowStatus( bool bShow )
	{
		if ( !bShow )
			GotoState('SlideOut');
	}
}

state SlideIn
{
	simulated function ShowStatus( bool bShow )
	{
		if ( !bShow )
			GotoState('SlideOut');
	}

	simulated function UpdateSlideScale( float DeltaTime )
	{
		SlideScale += DeltaTime * SlideSpeed;
		if ( SlideScale > 1.f )
		{
			SlideScale = 1.f;
			GotoState('Visible');
		}
	}

	simulated function vector DrawObjectives( Canvas C, vector BoxPivot, bool bDefender, bool bGetBoxSize )
	{
		if ( bGetBoxSize )
			return Global.DrawObjectives( C, BoxPivot, bDefender, bGetBoxSize );
		return vect(0,0,0);
	}
}

state SlideOut
{
	simulated function ShowStatus( bool bShow )
	{
		if ( bShow )
			GotoState('SlideIn');
	}

	simulated function UpdateSlideScale( float DeltaTime )
	{
		SlideScale -= DeltaTime * SlideSpeed;
		if ( SlideScale < 0.f )
		{
			SlideScale = 0.f;
			GotoState('Hidden');
		}
	}
	
	simulated function vector DrawObjectives( Canvas C, vector BoxPivot, bool bDefender, bool bGetBoxSize )
	{
		if ( bGetBoxSize )
			return Global.DrawObjectives( C, BoxPivot, bDefender, bGetBoxSize );
		return vect(0,0,0);
	}
}

simulated function PostRender( Canvas C, float DeltaTime, bool bDefender )
{
	local float		HeaderHeight;
	local float		XL, YL;

	C.Style	= ERenderStyle.STY_Alpha;
	C.Font = class'UT2MidGameFont'.static.GetMidGameFont( C.ClipX*0.75 * ASHUD.HUDScale );
	C.StrLen( HeaderText, XL, YL);
	HeaderHeight = YL * 2;

	UpdateSlideScale( DeltaTime );
	BoxSize = DrawObjectives( C, vect(0,0,0), bDefender, true );
	//BoxSize = GetBoxSize( C, bDefender );
	BoxPivot.X = C.ClipX - BoxSize.X;
	//BoxPivot.X = (C.ClipX - BoxSize.X) * 0.5;
	BoxPivot.Y = (BoxSize.Y+HeaderHeight) * SlideScale - BoxSize.Y;

	DrawBigCurrentObjective( C, bDefender, true );

	// Draw Header Box
	C.SetDrawColor(255, 255, 255, 255);
	C.SetPos(BoxPivot.X, BoxPivot.Y - HeaderHeight);
	if ( ASHUD.PawnOwner != None && ASHUD.PawnOwner.GetTeamNum() == 0 )
		C.DrawTileStretched(texture'InterfaceContent.Menu.ScoreBoxC', BoxSize.X, HeaderHeight);
	else
		C.DrawTileStretched(texture'InterfaceContent.Menu.ScoreBoxB', BoxSize.X, HeaderHeight);
	//C.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', BoxSize.X, HeaderHeight);

	// Draw Objectives Box
	C.SetDrawColor(255, 255, 255, 255);
	C.SetPos(BoxPivot.X, BoxPivot.Y);
	if ( ASHUD.PawnOwner != None && ASHUD.PawnOwner.GetTeamNum() == 0 )
		C.DrawTileStretched(texture'InterfaceContent.Menu.ScoreBoxC', BoxSize.X, BoxSize.Y);
	else
		C.DrawTileStretched(texture'InterfaceContent.Menu.ScoreBoxB', BoxSize.X, BoxSize.Y);

	// Draw Header Text
	if ( SlideScale == 1.f )
	{
		C.Font = class'UT2MidGameFont'.static.GetMidGameFont( C.ClipX*0.75 * ASHUD.HUDScale );
		C.DrawColor = C.MakeColor( 255, 255, 255, 255);
		C.StrLen( HeaderText, XL, YL);
		C.SetPos( BoxPivot.X + (BoxSize.X - XL)*0.5, BoxPivot.Y - (HeaderHeight + YL)*0.5 );
		C.DrawText( HeaderText );
	}
	
	// List Objectives
	DrawObjectives( C, BoxPivot, bDefender, false );

}

/* if bGetBoxSize is true, function calculates the size needed for the objective list box
	Otherwise it draws the objective list... */
simulated function vector DrawObjectives( Canvas C, vector BoxPivot, bool bDefender, bool bGetBoxSize )
{
	local int		i, priority, startpriority, endpriority;
	local bool		bDrawObjectiveNumber;
	local float		XL, YL, XUnit, YOffset;
	local vector	ScreenPos, newBoxSize;
	local string	entry;

	StartPriority	= 0;
	EndPriority		= ASHUD.ASGRI.MaxObjectivePriority;

	if ( !bGetBoxSize )
	{
		C.Font = class'UT2MidGameFont'.static.GetMidGameFont( C.ClipX*0.75 * ASHUD.HUDScale );
		C.StrLen("0", XL, YL);
		
		XUnit	= XL;
		YOffset	= BoxPivot.Y + YL*0.5;
	}

	for ( priority=StartPriority; priority<=EndPriority; priority++)
	{
		bDrawObjectiveNumber	= true;

		// First pass, primary objectives
		for (i=0; i<ASHUD.OBJ.Length; i++)
		{
			if ( (ASHUD.OBJ[i].ObjectivePriority != priority) || ASHUD.OBJ[i].bOptionalObjective )
				continue;

			if ( ASHUD.ObjectiveProgress == priority )
				C.Font = class'UT2MidGameFont'.static.GetMidGameFont( C.ClipX*0.75 * ASHUD.HUDScale );
			else
				C.Font = class'UT2MidGameFont'.static.GetMidGameFont( C.ClipX*0.67 * ASHUD.HUDScale );

			entry = CheckEntry( C, GetObjectiveDescription(ASHUD.OBJ[i], bDefender) );

			if ( bGetBoxSize )
			{
				C.StrLen( entry, XL, YL);
				newBoxSize.X	 = FMax( newBoxSize.X, XL );
				newBoxSize.Y	+= YL;
			}
			else
			{
				C.StrLen("0", XL, YL);

				SetObjectiveColor( C, ASHUD.OBJ[i] );

				C.SetPos( BoxPivot.X + XUnit*4, YOffset );
				C.DrawText( entry );

				if ( ASHUD.OBJ[i].IsCritical() && ASHUD.ObjectiveProgress == priority )
				{
					C.DrawColor = ASHUD.WhiteColor;
					ScreenPos.X = BoxPivot.X + XUnit + XL*0.5;
					ScreenPos.Y = YOffset + YL*0.33;
					ASHUD.DrawCriticalObjectiveOverlay( C, ScreenPos, 0.45 );
				}
				else if ( bDrawObjectiveNumber )	// Objective number
				{
					C.SetPos( BoxPivot.X + XUnit, YOffset );
					C.DrawText( string(priority+1) );

					C.SetPos( BoxPivot.X + XUnit*3, YOffset );
					C.DrawText(PrimaryObjectivePrefix);
				}

				YOffset += YL;
				bDrawObjectiveNumber = false;
			}

			// Display only one objective if not currently relevant
			if ( ASHUD.ObjectiveProgress != priority )
				break;
		}

		// Second pass for Optional Objectives (only shown for relevant objectives)
		if ( ASHUD.ObjectiveProgress == priority )
		{
			C.Font = class'UT2MidGameFont'.static.GetMidGameFont( C.ClipX * 0.67 * ASHUD.HUDScale );
			for (i=0; i<ASHUD.OBJ.Length; i++)
			{
				if ( (ASHUD.OBJ[i].ObjectivePriority > priority) || !ASHUD.OBJ[i].bOptionalObjective )
					continue;

				// Only show non active optional objectives for current priority
				// this way we can still show optional objectives of different priority
				if ( !ASHUD.OBJ[i].IsActive() && ASHUD.OBJ[i].ObjectivePriority != priority )
					continue;

				entry = CheckEntry( C, GetObjectiveDescription(ASHUD.OBJ[i], bDefender) );
				if ( bGetBoxSize )
				{
					C.StrLen( entry, XL, YL);
					newBoxSize.X	 = FMax( newBoxSize.X, XL );
					newBoxSize.Y	+= YL;
				}
				else
				{
					SetObjectiveColor( C, ASHUD.OBJ[i] );
					C.StrLen("0", XL, YL);

					C.SetPos( BoxPivot.X + XUnit*5, YOffset );
					C.DrawText( entry );
					
					if ( ASHUD.OBJ[i].IsCritical() )
					{
						C.DrawColor = ASHUD.WhiteColor;
						ScreenPos.X = BoxPivot.X + XUnit*3 + XL*0.5;
						ScreenPos.Y = YOffset + YL*0.33;
						ASHUD.DrawCriticalObjectiveOverlay( C, ScreenPos, 0.3 );
					}
					else
					{
						C.SetPos( BoxPivot.X + XUnit*4, YOffset );
						C.DrawText( OptionalObjectivePrefix );
					}
					
					YOffset += YL;
				}
			}
		}
	}

	if ( bGetBoxSize )
	{
		// Check in case Header is larger than objectives info...
		C.Font = class'UT2MidGameFont'.static.GetMidGameFont( C.ClipX*0.75 * ASHUD.HUDScale );
		C.StrLen( HeaderText, XL, YL);
		newBoxSize.X = FMax( newBoxSize.X, XL );

		// Expand borders
		C.StrLen("0", XL, YL);
		XUnit = XL;
		newBoxSize.X	+= XUnit * 5;
		newBoxSize.Y	+= YL;

		return newBoxSize;
	}

	return vect(0,0,0);
}

/* makes sure entries are not too wide */
simulated function String CheckEntry( Canvas C, String Entry )
{
	local float	XL, YL;
	local string left, right, newentry, previousentry;

	C.TextSize( entry, XL, YL);
	if ( XL < C.ClipX*0.33)
		return entry;

	// fit as much words as possible, and cut remaining...
	do
	{
		previousentry = newentry;
		if ( !Divide(Entry, SpaceSeparator, left, right) )
			break;

		if ( newentry != "" )
			newentry = newentry $ SpaceSeparator $ left;
		else
			newentry = newentry $ left;

		Entry = right;
		C.TextSize( newentry $ TextCutSuffix, XL, YL );
	}
	until ( XL > C.ClipX*0.33 )

	return (previousentry $ TextCutSuffix);
}

simulated function DrawBigCurrentObjective( Canvas C, bool bDefender, bool bCheckOverlap )
{
	local float		XL, YL, XL2, YL2, XO, YO;
	local String	CurrentObjectiveString;
	local vector	ScreenPos;
	local byte		bProgressPulsing;
	local int		PrimaryObjectiveCount;

	if ( ASHUD.CurrentObjective == None )
		return;

	C.Font	= ASHUD.GetFontSizeIndex( C, 0 );
	C.Style = ERenderStyle.STY_Alpha;

	if ( bDefender )
		CurrentObjectiveString = ASHUD.CurrentObjective.Objective_Info_Defender;
	else
		CurrentObjectiveString = ASHUD.CurrentObjective.Objective_Info_Attacker;

	if ( CurrentObjectiveString != "" )
	{
		PrimaryObjectiveCount = GetPrimaryObjectiveCount();
		if ( PrimaryObjectiveCount > 1 )
			CurrentObjectiveString = CurrentObjectiveString @ ObjTimesString $ PrimaryObjectiveCount;
		
		C.StrLen( CurrentObjectiveString, XL, YL );
		if ( XL > C.ClipX*0.33 * ASHUD.HUDScale )
		{
			C.Font	= ASHUD.GetFontSizeIndex( C, -1 );
			C.StrLen( CurrentObjectiveString, XL, YL );
			if ( XL > C.ClipX*0.33 * ASHUD.HUDScale )
			{
				C.Font	= ASHUD.GetFontSizeIndex( C, -2 );
				C.StrLen( CurrentObjectiveString, XL, YL );
				if ( XL > C.ClipX*0.33 * ASHUD.HUDScale )
				{
					C.Font	= ASHUD.GetFontSizeIndex( C, -3 );
					C.StrLen( CurrentObjectiveString, XL, YL );
				}
			}
		}

		XL2	= XL + 64 * ASHUD.ResScaleX;
		YL2	= YL +  8 * ASHUD.ResScaleY;
		XO = C.ClipX * 0.5;
		YO = YL*0.5 + 10 * ASHUD.ResScaleY;

		// Draw only if not overlapping
		//if ( bCheckOverlap && XO + XL*0.5 > BoxPivot.X )
		//	return;

		// Draw background
		C.DrawColor = C.MakeColor(0, 0, 0, 150);
		C.SetPos( XO - XL2*0.5, YO - YL2*0.5 );
		C.DrawTile(Texture'HudContent.Generic.HUD', XL2, YL2, 168, 211, 166, 44);

		// draw current objective text
		C.DrawColor = ASHUD.GetObjectiveColor( ASHUD.CurrentObjective );
		if ( bCheckOverlap && XO + XL*0.5 > BoxPivot.X )
		{
			XO -= (XO + XL*0.5 - BoxPivot.X);
			C.DrawColor.A = 128;
		}
		C.SetPos( XO - XL*0.5, YO - YL*0.5 );
		C.DrawText( CurrentObjectiveString, false );

		// Draw Objective Type Icon Background
		ScreenPos.X = XO - XL*0.5 - 20*ASHUD.ResScaleX;
		ScreenPos.Y = YO;
		XL2 = 27*ASHUD.ResScaleX*ASHUD.HUDScale*0.60;
		YL2 = 27*ASHUD.ResScaleY*ASHUD.HUDScale*0.60;
		C.DrawColor = C.MakeColor(255, 255, 255, 255);
		C.SetPos( ScreenPos.X - XL2, ScreenPos.Y - YL2);
		C.DrawTile(Texture'HudContent.Generic.HUD', XL2*2, YL2*2, 119, 258, 54, 54);

		// Draw Current Objective Type Icon
		if ( ASHUD.CurrentObjective.ObjectiveTypeIcon != None )
		{
			C.DrawColor = ASHUD.GetObjectiveColor( ASHUD.CurrentObjective );
			XL2 = 32*ASHUD.ResScaleX*ASHUD.HUDScale*0.4;
			YL2 = 32*ASHUD.ResScaleY*ASHUD.HUDScale*0.4;
			C.SetPos( ScreenPos.X - XL2, ScreenPos.Y - YL2);
			C.DrawTile(ASHUD.CurrentObjective.ObjectiveTypeIcon, XL2*2, YL2*2, 0, 0, 64, 64);
		}

		// Draw Shield overlay (defenders)
		if ( bDefender )
		{
			C.DrawColor = ASHUD.GetObjectiveColor( ASHUD.CurrentObjective, bProgressPulsing );
			if ( AnyPrimaryObjectivesCritical() )
				C.DrawColor = ASHUD.GreenColor*ASHUD.fPulse + ASHUD.GoldColor*(1-ASHUD.fPulse);
			else
				C.DrawColor = ASHUD.GreenColor;

			if ( bProgressPulsing == 0 )
				C.DrawColor.A = (127 + 64 * ASHUD.fPulse);
			else
				C.DrawColor.A = 127;

			XL2 = ASHUD.ResScaleX*ASHUD.HUDScale*0.45;
			YL2 = ASHUD.ResScaleY*ASHUD.HUDScale*0.45;
			C.SetPos(ScreenPos.X - XL2 * 32, ScreenPos.Y - YL2 * 32);
			C.DrawTile( Texture'AS_FX_TX.HUD.OBJ_Status', 64*XL2, 64*YL2, 191.0, 191.0, 64, 64);
		}

		// objective progress status
		ASHUD.DrawObjectiveStatusOverlay( C, GetGlobalObjectiveProgress(), AnyPrimaryObjectivesCritical(), ScreenPos, 1.0f );
		ASHUD.DrawObjectiveStatusOverlay( C, GetGlobalObjectiveProgress(), AnyPrimaryObjectivesCritical(), ScreenPos, 1.1f );

		// display critical icon for any critical primary objective
		if ( AnyPrimaryObjectivesCritical() )	
		{
			C.DrawColor = ASHUD.WhiteColor;
			ASHUD.DrawCriticalObjectiveOverlay( C, ScreenPos, 1.f );
		}
	}
}

/* returns number of primary objectives currently relevant */
simulated function int GetPrimaryObjectiveCount()
{
	local int	i, Count;

	for (i=0; i<ASHUD.OBJ.Length; i++)
	{
		if ( ASHUD.OBJ[i].ObjectivePriority != ASHUD.ObjectiveProgress 
			|| !ASHUD.OBJ[i].IsActive() || ASHUD.OBJ[i].bOptionalObjective )
			continue;
		Count++;
	}

	return Count;
}

/* returns global progress (status to completion) of all current primary objectives */
simulated function float GetGlobalObjectiveProgress()
{
	local int	i, Count;
	local float	GlobalProgress;

	for (i=0; i<ASHUD.OBJ.Length; i++)
	{
		if ( ASHUD.OBJ[i].ObjectivePriority != ASHUD.ObjectiveProgress || ASHUD.OBJ[i].bOptionalObjective )
			continue;
		GlobalProgress += ASHUD.OBJ[i].GetObjectiveProgress();
		Count++;
	}

	return (GlobalProgress/float(Count));
}

/* any current primary objective critical? */
simulated function bool AnyPrimaryObjectivesCritical()
{
	local int i;

	if ( ASHUD.CurrentObjective.IsCritical() )
		return true;

	for (i=0; i<ASHUD.OBJ.Length; i++)
	{
		if ( ASHUD.OBJ[i].ObjectivePriority != ASHUD.ObjectiveProgress || ASHUD.OBJ[i].bOptionalObjective )
			continue;

		if ( ASHUD.OBJ[i].IsCritical() )
			return true;
	}

	return false;
}

/* any current optional objective critical? */
simulated function bool AnyOptionalObjectiveCritical()
{
	local int i;

	for (i=0; i<ASHUD.OBJ.Length; i++)
	{
		if ( ASHUD.OBJ[i].ObjectivePriority != ASHUD.ObjectiveProgress || !ASHUD.OBJ[i].bOptionalObjective )
			continue;

		if ( ASHUD.OBJ[i].IsCritical() )
			return true;
	}

	return false;
}

//
// Helper
//

simulated function SetObjectiveColor( Canvas C, GameObjective GO )
{
	local Color ObjColor;

	if ( GO == ASHUD.CurrentObjective )
		ObjColor = C.MakeColor( 255, 255, 127, 255);
	else if ( GO.bDisabled )
		ObjColor = C.MakeColor( 127, 127, 127, 255 );
	else if ( GO.bOptionalObjective )
		ObjColor = C.MakeColor( 192, 192, 192, 192 );
	else
		ObjColor = C.MakeColor( 255, 255, 255, 255 );

	if ( GO.IsCritical() )
		ObjColor = ObjColor * (1-ASHUD.fPulse) + C.MakeColor(255,127,64,255) * ASHUD.fPulse;
	
	C.DrawColor = ObjColor;
}

simulated function string GetObjectiveDescription( GameObjective GO, bool bDefender )
{
	if ( bDefender )
		return GO.Objective_Info_Defender;

	return GO.Objective_Info_Attacker;
}

defaultproperties
{
     HeaderText="Objectives"
     OptionalObjectivePrefix="*"
     ObjTimesString="x"
     TextCutSuffix="..."
     SpaceSeparator=" "
     PrimaryObjectivePrefix="-"
     SlideSpeed=4.000000
}
