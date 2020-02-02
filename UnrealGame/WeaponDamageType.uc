class WeaponDamageType extends DamageType
	abstract;

var() class<Weapon>         WeaponClass;

static function string GetWeaponClass()
{
	return string(Default.WeaponClass);
}

defaultproperties
{
     bDirectDamage=True
}
