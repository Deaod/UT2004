class xMaterialTrigger extends Actor;

// deprecated

/*
var() editinline Material	Target;
var() Material	MaterialA;
var() Material	MaterialB;

var() enum EMatAction
{
	MTA_SwapShaderDiffuse,
	MTA_SwapShaderSelfIllum,
	MTA_SwapShaderSpecular,
	MTA_SwapCombinerMat1,
	MTA_SwapCombinerMat2,
	MTA_TickShaderSpecMaskColor,
	MTA_NoAction,
} MatTrigAction;

var() enum EMatTick
{
	MTT_FadeSpecularConst,
	MTT_PulseSpecularConst,
	MTT_NoAction,
} MatTrigTick;

var() float	MatTickValue;

var transient float tickAccum;
var transient float tickPtA;
var transient float tickPtB;
var transient bool triggerOn;

simulated function float Pulse( float x )
{
	if ( x < 0.5 )
	{
		return 2.0 * ( x * x * (3.0 - 2.0 * x) );
	}
	else
	{
		return 2.0 * (1.0 - ( x * x * (3.0 - 2.0 * x) ));
	}
}

simulated function TickConstantColor( ConstantColor cc, float t )
{
	local float f;
    local float alpha;

    tickAccum += t;
    if ( tickAccum >= 1.0 )
	{
        tickAccum = 1.0;
    }

	if ( MatTrigTick == MTT_FadeSpecularConst )
	{
		if ( tickAccum >= 1.0 )
		{
			Disable('Tick');
		}
		alpha = tickPtA + tickAccum * ( tickPtB-tickPtA );
	}
	else if ( MatTrigTick == MTT_PulseSpecularConst )
	{
        alpha = tickPtA + tickAccum * ( tickPtB-tickPtA );
		f = Level.TimeSeconds * MatTickValue;
		f = f - int(f);
		cc.Color.A = Pulse(f) * alpha;
	}

    cc.Color.A = alpha;
	//log("TickConst");
}

simulated function Tick( float t )
{
	Super.Tick(t);

	if( Target.IsA('Shader') && Shader(Target).SpecularityMask.IsA('ConstantColor') )
		TickConstantColor( ConstantColor(Shader(Target).SpecularityMask), t );
}

simulated function ShaderAction( Shader sh )
{
	//log("ShaderAction " $ sh );

	switch( MatTrigAction )
	{
		case MTA_SwapShaderSpecular:
			sh.Specular = MaterialA;
			break;
	}

}

simulated function CombinerAction( Combiner cb )
{
	//log("CombinerAction " $ cb );

}

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
	local Material	tmp;

	tmp = MaterialA;
	MaterialA = MaterialB;
	MaterialB = tmp;

    triggerOn = !triggerOn;


	if(Target.IsA('Shader'))
	{
		ShaderAction(Shader(Target));
	}
	else if (Target.IsA('Combiner'))
	{
		CombinerAction(Combiner(Target));
	}
	else
	{
		log("Incompatible material in xMaterialTrigger",'Warning');
	}

	if( Target.IsA('Shader') && Shader(Target).SpecularityMask.IsA('ConstantColor') )
	{
        if( triggerOn )
        {
            // fade up
            tickPtA = ConstantColor(Shader(Target).SpecularityMask).Color.A;
			tickPtB = 255.0;
        }
        else
        {
            // fade down
            tickPtA = ConstantColor(Shader(Target).SpecularityMask).Color.A;
			tickPtB = 0.0;
        }
		tickAccum = 0.0;
		switch( MatTrigTick )
		{
			case MTT_FadeSpecularConst:
			case MTT_PulseSpecularConst:
				Enable('Tick');
				break;
		}
	}
}
*/

defaultproperties
{
}
