/*:
 # The Many Faces of Zip: Part 1

 ## Exercises

 1.) In this episode we came across closures of the form `{ ($0, $1.0, $1.1) }` a few times in order to unpack a tuple of the form `(A, (B, C))` to `(A, B, C)`. Create a few overloaded functions named `unpack` to automate this.

 */
// TODO
func unpack<A, B, C>(_ tuple: (A, (B, C))) -> (A, B, C) {
  return (tuple.0, tuple.1.0, tuple.1.1)
}

func unpack<A, B, C, D>(_ tuple: (A, (B, (C, D)))) -> (A, B, C, D) {
  return (tuple.0, tuple.1.0, tuple.1.1.0, tuple.1.1.1)
  
}

func unpack<A, B, C, D, E>(
  _ tuple: (A, (B, (C, (D, E))))
) -> (A, B, C, D, E) {
  (tuple.0, tuple.1.0, tuple.1.1.0, tuple.1.1.1.0, tuple.1.1.1.1)
}
/*:
 2.) Define `zip4`, `zip5`, `zip4(with:)` and `zip5(with:)` on arrays and optionals. Bonus: [learn](https://nshipster.com/swift-gyb/) how to use Apple's `gyb` tool to generate higher-arity overloads.
 */
func zip2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  var result: [(A, B)] = []
  (0..<min(xs.count, ys.count)).forEach { idx in
    result.append((xs[idx], ys[idx]))
  }
  return result
}

zip2([1, 2, 3], ["one", "two", "three"])

func zip3<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)] {
  return zip2(xs, zip2(ys, zs)) // [(A, (B, C))]
    .map { a, bc in (a, bc.0, bc.1) }
}

func zip4<A, B, C, D>(_ a: [A], _ b: [B], _ c: [C], _ d: [D]) -> [(A, B, C, D)] {
  return zip2(a, zip3(b, c, d))
    .map{a, bcd in (a, bcd.0, bcd.1, bcd.2)}
}

func zip4<A, B, C, D, E>(_ a: [A], _ b: [B], _ c: [C], _ d: [D], _ e: [E]) -> [(A, B, C, D, E)] {
  return zip2(a, zip4(b, c, d, e))
    .map{a, bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3)}
}


func zip2<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
  guard let a = a, let b = b else { return nil }
  return (a, b)
}

func zip3<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
  return zip2(a, zip2(b, c))
    .map { a, bc in (a, bc.0, bc.1) }
}

func zip4<A, B, C, D>(_ a: A?, _ b: B?, _ c: C?, _ d: D?) -> (A, B, C, D)? {
  return zip2(a, zip3(b, c, d))
    .map{a, bcd in (a, bcd.0, bcd.1, bcd.2)}
}


/*:
 3.) Do you think `zip2` can be seen as a kind of associative infix operator? For example, is it true that `zip(xs, zip(ys, zs)) == zip(zip(xs, ys), zs)`? If it's not strictly true, can you define an equivalence between them?
 */
// TODO
// zip(xs, zip(ys, zs)) ⟹ [(Int, (String, Bool))]
//let left = zip(xs, zip(ys, zs))
// => [(1, ("a", true)), (2, ("b", false))]

// zip(zip(xs, ys), zs) ⟹ [((Int, String), Bool)]
//let right = zip(zip(xs, ys), zs)
// => [((1, "a"), true), ((2, "b"), false)]


//func associateLeft<A, B, C>(
//  _ value: (A, (B, C))
//) -> ((A, B), C) {
//  return ((value.0, value.1.0), value.1.1)
//}
//
//func associateRight<A, B, C>(
//  _ value: ((A, B), C)
//) -> (A, (B, C)) {
//  return (value.0.0, (value.0.1, value.1))
//}
//
//associateLeft((1, ("a", true))) == ((1, "a"), true)
//associateRight(((1, "a"), true)) == (1, ("a", true))
//
//zip(xs, zip(ys, zs)).map(associateLeft) == zip(zip(xs, ys), zs)

/*:
 4.) Define `unzip2` on arrays, which does the opposite of `zip2: ([(A, B)]) -> ([A], [B])`. Can you think of any applications of this function?
 */
func unzip2<A, B>(_ tuples: [(A, B)]) -> ([A], [B]) {
//  var firsts: [A] = []
//  var seconds: [B] = []
//  for (a, b) in tuples {
//    firsts.append(a)
//    seconds.append(b)
//  }
//  return (firsts, seconds)
  
  (tuples.map { $0.0}, tuples.map { $0.1})
}
/*:
 5.) It turns out, that unlike the `map` function, `zip2` is not uniquely defined. A single type can have multiple, completely different `zip2` functions. Can you find another `zip2` on arrays that is different from the one we defined? How does it differ from our `zip2` and how could it be useful?
 */
func combos2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  var result: [(A, B)] = []
  for x in xs {
    for y in ys {
      result.append((x, y))
    }
  }
  return result
}

combos2([1, 2], ["one", "two"])
// [(1, "one"), (1, "two"), (2, "one"), (2, "two")]

func combos2Another<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  xs.flatMap { x in
    ys.map { y in (x, y) }
  }
}

combos2Another([1, 2], ["one", "two"])
// [(1, "one"), (1, "two"), (2, "one"), (2, "two")]

/*:
 6.) Define `zip2` on the result type: `(Result<A, E>, Result<B, E>) -> Result<(A, B), E>`. Is there more than one possible implementation? Also define `zip3`, `zip2(with:)` and `zip3(with:)`.

 Is there anything that seems wrong or “off” about your implementation? If so, it
 will be improved in the next episode 😃.
 */
// TODO
enum Result<A, E> {
  case success(A)
  case failure(E)
}

func zip2<A, B, E>(_ res1: Result<A, E>, _ res2: Result<B, E>) -> Result<(A, B), E> {
  switch (res1, res2) {
  case let (.success(x), .success(y)):
    return .success((x, y))
  case let (.failure(e), _):
    return .failure(e)
  case let (_, .failure(e)):
    return .failure(e)
  }
}

//func zip3<A, B, C, E>(
//  _ a: Result<A, E>,
//  _ b: Result<B, E>,
//  _ c: Result<C, E>
//) -> Result<(A, B, C), E> {
//  zip2(a, zip2(b, c))
//    .map { a, bc in (a, bc.0, bc.1) }
//}

/*:
 7.) In [previous](/episodes/ep14-contravariance) episodes we've considered the type that simply wraps a function, and let's define it as `struct Func<R, A> { let apply: (R) -> A }`. Show that this type supports a `zip2` function on the `A` type parameter. Also define `zip3`, `zip2(with:)` and `zip3(with:)`.
 */
// TODO
struct Func<R, A> { let apply: (R) -> A }

extension Func {
  func map<B>(_ f: @escaping (A) -> B) -> Func<R, B> {
    Func<R, B> { r in f(self.apply(r)) }
  }
}

func zip2<R, A, B>(_ r2a: Func<R, A>, _ r2b: Func<R, B>) -> Func<R, (A, B)> {
  Func { r in
    (r2a.apply(r), r2b.apply(r))
  }
}

func zip3<R, A, B, C>(
  _ fa: Func<R, A>,
  _ fb: Func<R, B>,
  _ fc: Func<R, C>
) -> Func<R, (A, B, C)> {
  return zip2(fa, zip2(fb, fc))
    .map { a, bc in (a, bc.0, bc.1) }
}



func zip2<A, B, C>(
  with f: @escaping (A, B) -> C
  ) -> ([A], [B]) -> [C] {

  return { zip2($0, $1).map(f) }
}

func zip3<R, A, B, C>(
  with f: @escaping (A, B) -> C
) -> (Func<R, A>, Func<R, B>) -> Func<R, C> {
  return { (fa, fb) in
    zip2(fa, fb).map(f)
  }
}
/*:
 8.) The nested type `[A]? = Optional<Array<A>>` is composed of two containers, each of which has their own `zip2` function. Can you define `zip2` on this nested container that somehow involves each of the `zip2`'s on the container types?
 */
typealias OptionalArray<A> = [A]?


func zip2<A, B>(
  _ a: OptionalArray<A>, _ b: OptionalArray<B>
) -> OptionalArray<(A, B)> {
  zip2(a, b).map(zip2)
}
