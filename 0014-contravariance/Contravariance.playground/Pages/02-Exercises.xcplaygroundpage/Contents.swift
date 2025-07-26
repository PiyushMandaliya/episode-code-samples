/*:
 # Contravariance Exercises

 1.) Determine the sign of all the type parameters in the function `(A) -> (B) -> C`. Note that this is a curried function. It may be helpful to fully parenthesize the expression before determining variance.
 */
// TODO
//(A) -> ((B) -> C)
//        |-|    |-|
//         -1     +1
//|-|     |--------|
// -1       +1

//A -> -1 (Contravariant)
// B -> -1 (Contravariant)
// C -> +1 (Covariant)
/*:
 2.) Determine the sign of all the type parameters in the following function:

 `(A, B) -> (((C) -> (D) -> E) -> F) -> G`
 */
//(A, B) -> (((C) -> (D) -> E) -> F) -> G
//          |--|     |-|   |-|
//          -1        -1    +1
//|_||_|     |_______________|   |_|
//+1 +1             -1           +1
//|----|    |----------------------|  |---|
//  -1                 -1               +1

//A = -1 * +1 = -1
//B = -1 * +1 = -1
//C = -1 * -1 * -1 = -1
//D = -1 * -1 * -1 = -1
//E = -1 * -1 * +1 = +1
//F = -1 * +1 = -1
//G = +1
/*:
 3.) Recall that [a setter is just a function](https://www.pointfree.co/episodes/ep6-functional-setters#t813) `((A) -> B) -> (S) -> T`. Determine the variance of each type parameter, and define a `map` and `contramap` for each one. Further, for each `map` and `contramap` write a description of what those operations mean intuitively in terms of setters.
 */
// ((A) -> B) -> (S) -> T
//  |_|   |_|
//  -1    +1
// |________|    |_|   |_|
//     -1        -1    +1

//A = +1
//B = -1
//S = -1
//T = +1

//This means we should be able to define map on A and T, and contramap on B and S. Here are the implementations of each, with comments that show the types of all the parts we need to plug together:



typealias Setter<S,T, A, B> = (@escaping (A) -> B) -> (S) -> T
                               
                               
func map<S, T, A, B, C>(_ f: @escaping (A) -> C) -> (@escaping Setter<S, T, A, B>) -> Setter<S, T, C, B> {
  
  return { setter in
    return { update in
      return { s in
        // f: (A) -> C
        // setter: ((A) -> B) -> (S) -> T
        // update: (C) -> B
        // s: S
        // return : (C) -> B) -> (S) -> T
        setter(f >>> update)(s)
      }
    }
  }
}

func map<S, T, U, A, B>(_ f: @escaping (T) -> U) -> (@escaping Setter<S, T, A, B>) -> Setter<S, U, A, B> {
  return { setter in
    return { update in
      return { s in
        // f: (T) -> U
        // setter: ((A) -> B) -> (S) -> T
        // update: (A) -> B
        // s: S
        // return : (A) -> B) -> (S) -> U
        f(setter(update)(s))
      }
    }
  }
}

func contramap<S, T, A, B, C>(_ f: @escaping (C) -> B)
  -> (@escaping Setter<S, T, A, B>)
-> Setter<S, T, A, C> {
  return { setter in
    return { update in
      return { s in
        // update: (A) -> C
        // f: (C) -> B
        // compose: (A) -> B
        let omposedUpdate: (A) -> B = update >>> f
        // return: ((A) -> C) -> (S) -> T
        return setter(omposedUpdate)(s)
      }
    }
  }
}

func contampa<S, T, U, A, B>(_ f: @escaping (U) -> S)
  -> (@escaping Setter<S, T, A, B>)
  -> Setter<U, T, A, B> {
    return { setter in
      return  { update in
        return { u in
          // f: (U) -> S
          // setter: ((A) -> B) -> (S) -> T
          // update: (A) -> B
          // u: U
          return setter(update)(f(u))
        }
      }
    }
}

/*:
 4.) Define `union`, `intersect`, and `invert` on `PredicateSet`.
 */
struct PredicateSet<A> {
  let contains: (A) -> Bool

  func contramap<B>(_ f: @escaping (B) -> A) -> PredicateSet<B> {
    return PredicateSet<B>(contains: f >>> self.contains)
  }
}

extension PredicateSet {
  func union(_ other: PredicateSet) -> PredicateSet {
    PredicateSet { self.contains($0) || other.contains($0) }
  }
  
  func intersect(_ other: PredicateSet) -> PredicateSet {
    PredicateSet { self.contains($0) && other.contains($0) }
  }
  
  func invert(_ other: PredicateSet) -> PredicateSet {
    PredicateSet { !self.contains($0) }
  }
  
}
/*:
 This collection of exercises explores building up complex predicate sets and understanding their performance characteristics.

 5a.) Create a predicate set `isPowerOf2: PredicateSet<Int>` that determines if a value is a power of `2`, _i.e._ `2^n` for some `n: Int`.
 */
let powerOf2 = PredicateSet<Int> { n in
    n > 2 && (n & (n - 1)) == 0
}
/*:
 5b.) Use the above predicate set to derive a new one `isPowerOf2Minus1: PredicateSet<Int>` that tests if a number is of the form `2^n - 1` for `n: Int`.
 */
let isPowerOf2Minus1 = powerOf2.contramap { $0 + 1}
isPowerOf2Minus1.contains(15)
/*:
 5c.) Find an algorithm online for testing if an integer is prime, and turn it into a predicate `isPrime: PredicateSet<Int>`.
 */
let isPrime = PredicateSet<Int> { n in
  guard n != 2 else { return true }
  let upperBound = max(2, Int(floor(sqrt(Double(n)))))
    return (2...upperBound)
      .lazy
      .map { n % $0 == 0 }
      .first(where: { $0 == true }) == nil
}
/*:
 5d.) The intersection `isPrime.intersect(isPowerOf2Minus1)` consists of numbers known as [Mersenne primes](https://en.wikipedia.org/wiki/Mersenne_prime). Compute the first 10.
 */
let mersennePrimes = isPrime.intersect(isPowerOf2Minus1)

(2...)
  .lazy
  .filter(mersennePrimes.contains)
  .prefix(5)
  .forEach { n in
    print(n) // 3, 7, 31, 127, 8191
}
/*:
 5e.) Recall that `&&` and `||` are short-circuiting in Swift. How does that translate to `union` and `intersect`?
 */
// TODOunion
/*:
 6.) What is the difference between `isPrime.intersect(isPowerOf2Minus1)` and `isPowerOf2Minus1.intersect(isPrime)`? Which one represents a more performant predicate set?
 */
// TODO
/*:
 7.) It turns out that dictionaries `[K: V]` do not have `map` on `K` for all the same reasons `Set` does not. There is an alternative way to define dictionaries in terms of functions. Do that and define `map` and `contramap` on that new structure.
 */
// TODO
struct FuncDictionary<K, V> {
  let valueForKey: (K) -> V?
  
  func map<W>(_ f: @escaping (V) -> W) -> FuncDictionary<K, W> {
    FuncDictionary<K, W> { key in
      // self.valueForKey(key) = V?
      self.valueForKey(key).map(f)
    }
  }
  
  func contramap<L>(_ f: @escaping(L) -> K) -> FuncDictionary<L, V> {
    FuncDictionary<L, V> { key in
      // f(key) = (L) -> K
      // self.valueForKey(key)
      self.valueForKey(f(key))
    }
  }
}
/*:
 8.) Define `CharacterSet` as a type alias of `PredicateSet`, and construct some of the sets that are currently available in the [API](https://developer.apple.com/documentation/foundation/characterset#2850991).
 */
extension PredicateSet where A == Character {
  static var newlines: PredicateSet {
    return PredicateSet(
      contains: Set<Character>(
        [
          .init(Unicode.Scalar(0x000A)),
          .init(Unicode.Scalar(0x000B)),
          .init(Unicode.Scalar(0x000C)),
          .init(Unicode.Scalar(0x000D)),
          .init(Unicode.Scalar(0x0085))
        ]
        ).contains
    )
  }
}
/*:
 Let's explore happens when a type parameter appears multiple times in a function signature.

 9a.) Is `A` in positive or negative position in the function `(B) -> (A, A)`? Define either `map` or `contramap` on `A`.
 */
//func map<A, B, C>(_ f: @escaping (A) -> C) -> ((B) -> (A, A)) -> ((B) -> (C, C)) {
//  return { g in
//    return { b in
//      let (a1, a2) = g(b)
//      return (f(a1), f(a2))
//    }
//  }
//}


/*:
 9b.) Is `A` in positive or negative position in `(A, A) -> B`? Define either `map` or `contramap`.
 */
//func contramap<A, B, C>(_ f: (C) -> A) -> ((A, A) -> B) -> ((C, C) -> B) {
//  return { g in
//    return { c1, c2 in
//      return g(f(c1), f(c2))
//    }
//  }
//}
/*:
 9c.) Consider the type `struct Endo<A> { let apply: (A) -> A }`. This type is called `Endo` because functions whose input type is the same as the output type are called "endomorphisms". Notice that `A` is in both positive and negative position. Does that mean that _both_ `map` and `contramap` can be defined, or that neither can be defined?
 */
struct Endo<A> {
  let apply: (A) -> A
  
  func map<B>(_ f: @escaping (A) -> B) -> Endo<B> {
    Endo<B> { b in
      b // B
      f // (A) -> B
      self.apply // (A) -> A
      
      fatalError("Need to return something in B")
    }
  }
  
  func contramap<B>(_ f: @escaping (B) -> A) -> Endo<B> {
    Endo<B> { b in
      b // B
      f // (B) -> A
      
      fatalError("Need to return something in B")
    }
  }
  
}

//So, the types we have at our disposal in the Endo<B> block don’t exactly match up. In map we need to return something in B while we have b: B and f: (A) -> B. Now, of course we could just return b, but we didn’t use f at all, and that seems weird! Likewise, for contramap we need to return something in B and have b: B and f: (B) -> A at our disposal, so the only thing we can do is return b and ignore f entirely. Very strange!
//
//It seems that although map and contramap can be defined on Endo, neither one does anything interesting. They just return the identity endomorphism, regardless of what f is.

/*:
 9d.) Turns out, `Endo` has a different structure on it known as an "invariant structure", and it comes equipped with a different kind of function called `imap`. Can you figure out what it’s signature should be?
 */
extension Endo {
  func imap<B>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> A) -> Endo<B> {
    Endo<B> { b in
      f(self.apply(g(b)))
    }
  }
}
/*:
 10.) Consider the type `struct Equate<A> { let equals: (A, A) -> Bool }`. This is just a struct wrapper around an equality check. You can think of it as a kind of "type erased" `Equatable` protocol. Write `contramap` for this type.
 */
// TODO
struct Equate<A> {
  let equals: (A, A) -> Bool
  
  func contramap<B>(_ f: @escaping (B) -> A) -> Equate<B> {
    Equate<B> { self.equals(f($0), f($1)) }
  }
}
/*:
 11.) Consider the value `intEquate = Equate<Int> { $0 == $1 }`. Continuing the "type erased" analogy, this is like a "witness" to the `Equatable` conformance of `Int`. Show how to use `contramap` defined above to transform `intEquate` into something that defines equality of strings based on their character count.
 */
let intEquate = Equate<Int> { $0 == $1 }

intEquate.contramap{ (a: String) in a.count }

// Using the `get` function from episode #8: Key Paths and Getters
//intEquate.contramap(get(\String.count))

intEquate.contramap(^\String.count)

