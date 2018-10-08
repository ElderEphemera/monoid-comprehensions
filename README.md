# monoid-comprehensions

An experimental GHC plugin for monoid comprehensions.

## Example

Using this plugin, we can replace something like

```haskell
sum [ x * y | x <- [1..3], y <- [1..3] ]
```

with

```haskell
getSum ([ Sum (x * y) | x <- [1..3], y <- [1..3] ])
```

## How it works

Currently the translation is fairly naive; it simply replaces expressions of the
form:

```haskell
([ f x ... z | x <- xs, p x, ..., z <- zs, q x ... z ])
```

with something of the form:

```haskell
fold [ f x ... z | x <- toList xs, p x, ..., z <- toList zs, q x ... z ]
```

*Note*: `-XParallelListComp` and `-XTransformListComp` are not supported, but
`-XMonadComprehensions` should work just fine.

## Links

- [An excellent blog post about monoid comprehensions](https://lptk.github.io/programming/2018/10/04/comprehending-monoids-with-class.html)
- [Inspiration for the syntax](https://github.com/phadej/idioms-plugins)
