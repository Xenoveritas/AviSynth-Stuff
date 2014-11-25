#
# This is a port of the jQuery UI easings, which are licensed under the MIT
# license. So I guess this is too.
#
# The jQuery easings are originally from Robert Panner (http://www.easings.net).
#

# Generally these work by getting a float from 0-1 where 0 is the start and 1
# is the end. You can then multiply them by whatever you're animating to apply
# the easing. Note that some go beyond that range. (See easings.net for details.)

# Quad easing
function EasingQuad(float p) {
	return Pow(p, 2)
}
function EasingCubic(float p) {
	return Pow(p, 3)
}
function EasingQuart(float p) {
	return Pow(p, 4)
}
function EasingQuint(float p) {
	return Pow(p, 5)
}
function EasingExpo(float p) {
	return Pow(p, 6)
}
function EasingSine(float p) {
	return 1 - Cos(p * Pi() / 2)
}
function EasingCirc(float p) {
	return 1 - Sqrt(1 - p * p)
}
function EasingElastic(float p) {
	return p == 0 || p == 1 ? p : \
		-Pow( 2, 8 * (p - 1) ) * Sin( ( (p - 1) * 80 - 7.5 ) * Pi() / 15 )
}
function EasingBack(float p) {
	return p * p * ( 3 * p - 2 )
}

# Rather than try and port the jQuery version, these are based on Robert
# Penner's version found at
# http://gsgd.co.uk/sandbox/jquery/easing/jquery.easing.1.3.js

function EasingBounce(p) {
	# Technically this is timed backwards from the original, so flip it
	p = 1 - p
	return 1 - ( p < (1/2.75) ? (7.5625*p*p) : \
		p < (2/2.75) ? 7.5625*Pow(p - 1.5/2.75, 2) + 0.75 : \
		p < (2.5/2.75) ? 7.5625*Pow(p - 2.25/2.75, 2) + 0.9375 : \
			7.5625*Pow(p- 2.625/2.75, 2) + 0.984375 )
}

/*
 * Create the ease in/ease in/out variants:
[
 'Quad', 'Cubic', 'Quart', 'Quint', 'Expo', 'Sine', 'Circ', 'Elastic', 'Back', 'Bounce'
].forEach(function(easing) {
 console.log('function EaseIn%s(float p) {', easing);
 console.log('\treturn Easing%s(p)', easing);
 console.log('}');
 console.log('function EaseOut%s(float p) {', easing);
 console.log('\treturn 1.0 - Easing%s(1.0 - p)', easing);
 console.log('}');
 console.log('function EaseInOut%s(float p) {', easing);
 console.log('\treturn p < 0.5 ? \\');
 console.log('\t\tEasing%s( p * 2 ) / 2 : \\', easing);
 console.log('\t\t1 - Easing%s( p * -2 + 2 ) / 2', easing);
 console.log('}');
});
 */
function EaseInQuad(float p) {
	return EasingQuad(p)
}
function EaseOutQuad(float p) {
	return 1.0 - EasingQuad(1.0 - p)
}
function EaseInOutQuad(float p) {
	return p < 0.5 ? \
		EasingQuad( p * 2 ) / 2 : \
		1 - EasingQuad( p * -2 + 2 ) / 2
}
function EaseInCubic(float p) {
	return EasingCubic(p)
}
function EaseOutCubic(float p) {
	return 1.0 - EasingCubic(1.0 - p)
}
function EaseInOutCubic(float p) {
	return p < 0.5 ? \
		EasingCubic( p * 2 ) / 2 : \
		1 - EasingCubic( p * -2 + 2 ) / 2
}
function EaseInQuart(float p) {
	return EasingQuart(p)
}
function EaseOutQuart(float p) {
	return 1.0 - EasingQuart(1.0 - p)
}
function EaseInOutQuart(float p) {
	return p < 0.5 ? \
		EasingQuart( p * 2 ) / 2 : \
		1 - EasingQuart( p * -2 + 2 ) / 2
}
function EaseInQuint(float p) {
	return EasingQuint(p)
}
function EaseOutQuint(float p) {
	return 1.0 - EasingQuint(1.0 - p)
}
function EaseInOutQuint(float p) {
	return p < 0.5 ? \
		EasingQuint( p * 2 ) / 2 : \
		1 - EasingQuint( p * -2 + 2 ) / 2
}
function EaseInExpo(float p) {
	return EasingExpo(p)
}
function EaseOutExpo(float p) {
	return 1.0 - EasingExpo(1.0 - p)
}
function EaseInOutExpo(float p) {
	return p < 0.5 ? \
		EasingExpo( p * 2 ) / 2 : \
		1 - EasingExpo( p * -2 + 2 ) / 2
}
function EaseInSine(float p) {
	return EasingSine(p)
}
function EaseOutSine(float p) {
	return 1.0 - EasingSine(1.0 - p)
}
function EaseInOutSine(float p) {
	return p < 0.5 ? \
		EasingSine( p * 2 ) / 2 : \
		1 - EasingSine( p * -2 + 2 ) / 2
}
function EaseInCirc(float p) {
	return EasingCirc(p)
}
function EaseOutCirc(float p) {
	return 1.0 - EasingCirc(1.0 - p)
}
function EaseInOutCirc(float p) {
	return p < 0.5 ? \
		EasingCirc( p * 2 ) / 2 : \
		1 - EasingCirc( p * -2 + 2 ) / 2
}
function EaseInElastic(float p) {
	return EasingElastic(p)
}
function EaseOutElastic(float p) {
	return 1.0 - EasingElastic(1.0 - p)
}
function EaseInOutElastic(float p) {
	return p < 0.5 ? \
		EasingElastic( p * 2 ) / 2 : \
		1 - EasingElastic( p * -2 + 2 ) / 2
}
function EaseInBack(float p) {
	return EasingBack(p)
}
function EaseOutBack(float p) {
	return 1.0 - EasingBack(1.0 - p)
}
function EaseInOutBack(float p) {
	return p < 0.5 ? \
		EasingBack( p * 2 ) / 2 : \
		1 - EasingBack( p * -2 + 2 ) / 2
}
function EaseInBounce(float p) {
	return EasingBounce(p)
}
function EaseOutBounce(float p) {
	return 1.0 - EasingBounce(1.0 - p)
}
function EaseInOutBounce(float p) {
	return p < 0.5 ? \
		EasingBounce( p * 2 ) / 2 : \
		1 - EasingBounce( p * -2 + 2 ) / 2
}
