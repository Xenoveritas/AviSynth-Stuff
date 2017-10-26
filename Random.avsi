#: Functions for generating "random numbers." The numbers are not truly random:
#: they shouldn't be. Instead, they need to be re-seeded for every frame, to
#: ensure that the same frame is generated each time.
#:
#: Because it's necessary to generate the same random numbers for a given frame,
#: and the way this PRNG works (it's a simple linear congruential generator),
#: setting the seed to incrementing frame values will generate somewhat lousy
#: random numbers. They're likely "random enough" for generic effects, but it
#: may be worth multiplying the frame number by a large number in order to
#: "separate" the frames a bit.
#:


prng_seed = 0
# Taken from ANSI C, I guess.
prng_multiplier = 1103515245
prng_increment = 12345

#: .. function:: SeedRandom(seed)
#:
#:    :param int seed: the seed
#:
#:    This should be called **every frame** to reset the seed. It's important to
#:    note that due to the way this works, incrementing the seed each frame will
#:    result in really crappy random numbers (they'll all be very similar from
#:    frame to frame). The "best" solution is to do something to make
#:    incrementing frame values seem sort of random themselves, like multiplying
#:    by a fairly large prime number or something.
function SeedRandom(int seed, int "multiplier", int "increment") {
  global prng_seed = seed
  global prng_multiplier = Default(multiplier, 1103515245)
  global prng_increment = Default(increment, 12345)
}

#: .. function:: NextRandomInteger()
#:
#:    :return: a psuedo-random integer in the range 0-1073741823 (inclusive)
#:    :rtype: int
#:
#:    Returns the next random number. A call to :func:`SeedRandom` should be
#:    called at the start of every frame in order to ensure that the values
#:    generated are the same for each frame.
function NextRandomInteger() {
  global prng_seed = prng_multiplier * prng_seed + prng_increment
  return BitAnd(prng_seed, $3FFFFFFF)
}

#: .. function:: Random()
#:
#:    :return: a psuedo-random number from 0.0 (inclusive) - 1.0 (exclusive)
#:    :rtype: float
#:
#:    Returns the next random number. A call to :func:`SeedRandom` should be
#:    called at the start of every frame in order to ensure that the values
#:    generated are the same for each frame.
function Random() {
  return NextRandomInteger() / 1073741824.0
}


#: .. function:: RandomInteger(min=0, max=1073741824)
#:
#:    Returns the next random number. A call to :func:`SeedRandom` should be
#:    called at the start of every frame in order to ensure that the values
#:    generated are the same for each frame.
#:
#:    :param int minimum: minimum value to return (inclusive), defaults to 0
#:    :param int maximum: maximum value to return (exclusive), defaults to
#:        1073741824 (which is one more than the max value from
#:        :func:`NextRandomInteger`)
#:    :return: a psuedo-random number from min (inclusive) - max (exclusive)
#:    :rtype: int
function RandomInteger(int "minimum", int "maximum") {
  return Floor(Random() * (maximum - minimum)) + minimum
}
