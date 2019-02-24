Steel
======
Examples and reference for the [Rockland Steel House](http://www.rocklandsteelhouse.com) [programming series](https://github.com/michaelkvance/steel).  
_Last updated: 23 February 2019_  
Wade Brainerd  
Michael Vance  

## Presentation

[Steel House Presentation](https://docs.google.com/presentation/d/1uCUSc1x66IUDpU3qBXkeRGB1qu1H5Vfj2eufnL1b2Ms/edit?usp=sharing)

This is the presentation material that we went over in the advanced track at Steel House.

[Bowdoin Presentation](https://docs.google.com/presentation/d/1gJwueZ-l9vxLieIigIupu9cWY4E_ky72TFB3UhD1RUg/edit#slide=id.p)

This is the variation presented at Bowdoin.

## Pico-8

We are using the Pico-8 environment in order to get started quickly and get bits up on screen. Both Wade and I have a license which supports spawning for educational purposes such as the Steel House series.

[Home page](https://www.lexaloffle.com/pico-8.php)  
[FAQ](https://www.lexaloffle.com/pico-8.php?page=faq)  
[Manual](https://www.lexaloffle.com/pico-8.php?page=manual)  
[Palette](https://www.romanzolotarev.com/pico-8-color-palette/)  

## Lua

Pico-8 uses a fairly restricted subset of Lua but it's still useful to read up on the language.

[Home page](https://www.lua.org/)  
[Documentation](https://www.lua.org/docs.html)  
[Programming in Lua](https://www.lua.org/pil/contents.html)  

Some interesting quirks of the Pico-8 implementation of Lua:

  * PICO-8 numbers only go up to 32767.99. If you add 1 to a counter each frame, it will overflow after around 18 minutes!
  * Lua arrays are 1-based by default, not 0-based. FOREACH starts at T[1], not T[0].
  * cos() and sin() take 0..1 instead of 0..PI * 2, and sin() is inverted.
  * sgn(0) returns 1.
  * It seems that line number correspondence for Lua errors is off by 3 lines, possibly due to the Pico-8 header lines.

There are some snippets in the tree that demonstrate simple Lua concepts:

  * iter.lua - Shows the difference between iterating over keys and values in a table versus a sequence of integers.
  * value-reference.lua - Shows some of the differences in behaviors between atomic value types and reference-value types.

## Linear Algebra

[Deriving Rotations](https://www.khanacademy.org/computing/computer-programming/programming-games-visualizations/programming-3d-shapes/a/rotating-3d-shapes)

A Khan walk through of deriving rotation matrices in two and three dimensions.

## Advanced Topics

These are bits that are particularly advanced/gnarly. The first discuss object-oriented approaches in Lua. Pico-8's Lua implementation supports setmetatable() but not some of the other infrastructure necessary to implement some of those approaches.

[Class-like Objects](https://www.lexaloffle.com/bbs/?tid=2951)  
[Metatables](https://www.lexaloffle.com/bbs/?tid=3342)  

Pico-8 uses a 16:16 representation as opposed to the traditional 64-bit float in Lua, which is why the maximum value of a number in Pico-8 is 32767.9,  repeating.

[Fixed-point arithmetic](https://en.wikipedia.org/wiki/Fixed-point_arithmetic)  
[Q16:16](https://en.wikipedia.org/wiki/Q_\(number_format\))  

There are also some source snippets in the tree that demonstrate some of these advanced concepts.

  * vec2d_t.lua, shim.lua - This implements a simple vec2d_t 'class' and shows how to use it, including using the \_\_call method. Ultimately this method is unworkable for Pico-8 as the global 'require' is not supported in the Pico-8 Lua subset.

[Fabien Sanglard's Website](http://fabiensanglard.net/)

For those who were interested in a history and explanation of early ray-casting software 3-D engines, I recommend Fabien's book "Game Engine Black Book - Wolfenstein 3-D".

## Asteroids!

  * ast1.p8 - In which we demonstrate some simple line drawing and TTY output, as well as discuss some simple linear algebra.
  * ast2.p8 - In which we demonstrate a composite variable (table) and correct a bug.
  * ast3.p8 - In which we attempt to build a class-like object.
  * ast4.p8 - In which we abandon an attempt to build a class-like object, move to a saner C-like interface, and also start to build an object representation for the game.
  * ast5.p8 - In which we implement impulse and world wrapping, and build a proper looking ship.
  * ast6.p8 - In which we provide ammunition for our experience, further building out state and related infrastructure.
  * ast7.p8 - In which we provide an awesome starfield because the world looks lonely, and fix a bug in our shooty bits.
  * ast8.p8 - In which we add asteroid targets and a console.
  * ast9.p8 - In which we add melodious sounds.
  * ast10.p8 - In which we add a score mechanism, and your score is reset any time the ship intersects with an asteroid.

## Ideas!

  * Add a thruster effect to the back of the ship.
  * Add particle effects and sound when the asteroids are shot.
  * Improve the acceleration curve on the ship's thruster.
  * Fix the behavior when you shoot at high ship speed.
  * Make the starfield scroll relative to the ship speed.
  * Draw the asteroids as line segments instead of circles.
  * Have the asteroids explode into other asteroids.
  * Make the asteroids rotate as they move around.
  * Add collision for the ship against the edges of the screen, rather than wrap-around.
  * Implement a game over screen and restart mechanism.
  * Add a persistent high score mechanism using the cartridge memory built-ins. Bonus points for an initials entry UI.
