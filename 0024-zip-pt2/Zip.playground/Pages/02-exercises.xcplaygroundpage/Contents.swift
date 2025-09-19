/*:
 # The Many Faces of Zip: Part 2

 ## Exercises

 1.) Can you make the `zip2` function on our `F3` type thread safe?
 */
import Foundation

func map<A, B, E>(_ f: @escaping (A) -> B) -> (Result<A, E>) -> Result<B, E> {
  return { result in
    switch result {
    case let .success(a):
      return .success(f(a))
    case let .failure(e):
      return .failure(e)
    }
  }
}


struct F3<A> {
  let run: (@escaping (A) -> Void) -> Void
}

//func zip2<A, B>(
//  _ pa: F3<A>, _ pb: F3<B>
//) -> F3<(A, B)> {
//  return .init { callback in
//    let group = DispatchGroup()
//    var a: A!
//    var b: B!
//
//    group.enter()
//    pa.run { a = $0; group.leave() }
//
//    group.enter()
//    pb.run { b = $0; group.leave() }
//
//    group.notify(queue: .main) {
//      callback((a, b))
//    }
//  }
//}
/*:
 2.) Generalize the `F3` type to a type that allows returning values other than `Void`: `struct F4<A, R> { let run: (@escaping (A) -> R) -> R }`. Define `zip2` and `zip2(with:)` on the `A` type parameter.
 */
struct F4<A, R> { let run: (@escaping (A) -> R) -> R }

func zip2<A, B, R>(_ fa: F4<A, R>, _ fb: F4<B, R>) -> F4<(A, B), R>{
  return F4<(A,B), R> { callBack in
    fa.run { a in
      fb.run { b in
        callBack((a,b))
      }
    }
  }
}


extension F4 {
  func map<B>(_ f: @escaping (A) -> B) -> F4<B, R> {
    F4<B, R> { callback in
      self.run { a in callback(f(a)) }
    }
  }
}

func zip2<A, B, C, R>(with f: @escaping (A, B) -> C) -> (F4<A, R>, F4<B, R>) -> F4<C, R> {
  return { fa, fb in
    zip2(fa, fb).map { f($0, $1) }
  }
}

  /*:
   3.) Find a function in the Swift standard library that resembles the function above. How could you use `zip2` on it?
   */
  // TODO


// Simulate fetching an Int
let fetchNumber = F4<Int, Void> { callback in
  DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
    print("Fetched number")
    callback(42)
  }
}

// Simulate fetching a String
let fetchString = F4<String, Void> { callback in
  DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
    print("Fetched string")
    callback("Hello")
  }
}

let combined = zip2(fetchNumber, fetchString)

let formatted = zip2(
  with: { number, string in
    return "\(string), your lucky number is \(number)"
  }
)(fetchNumber, fetchString)

formatted.run {
  print($0)
}

  /*:
   4.) This exercise explore what happens when you nest two types that each support a `zip` operation.
   
   - Consider the type `[A]? = Optional<Array<A>>`. The outer layer `Optional`  has `zip2` defined, but also the inner layer `Array`  has a `zip2`. Can we define a `zip2` on `[A]?` that makes use of both of these zip structures? Write the signature of such a function and implement it.
   */
  
func zip2<A>(_ xs: [A]?, _ ys: [A]?) -> [(A, A)]? {
  guard let xs =  xs, let ys = ys else { return nil}
  return Swift.zip(xs, ys).map { ($0, $1) }
}


  /*:
   - Using the `zip2` defined above write an example usage of it involving two `[A]?` values.
   */

let xs: [Int]? = [1, 2, 3]
let ys: [Int]? = [4, 5, 6]

let zipped = zip2(xs, ys) // Optional([(1, 4), (2, 5), (3, 6)])
print(zipped ?? [])       // [(1, 4), (2, 5), (3, 6)]


/*:
   - Consider the type `[Validated<A, E>]`. We again have have a nesting of types, each of which have their own `zip2` operation. Can you define a `zip2` on this type that makes use of both `zip` structures? Write the signature of such a function and implement it.
   */

import NonEmpty

enum Validated<A, E> {
  case valid(A)
  case invalid(NonEmptyArray<E>)
}

func zip2<A, B, E>(_ a: Validated<A, E>, _ b: Validated<B, E>) -> Validated<(A, B), E> {

  switch (a, b) {
  case let (.valid(a), .valid(b)):
    return .valid((a, b))
  case let (.valid, .invalid(e)):
    return .invalid(e)
  case let (.invalid(e), .valid):
    return .invalid(e)
  case let (.invalid(e1), .invalid(e2)):
    return .invalid(e1 + e2)
  }
}

func zip2<A, B, E>(
  _ xs: [Validated<A, E>],
  _ ys: [Validated<B, E>]
) -> [Validated<(A, B), E>] {
  return Swift.zip(xs, ys).map { zip2($0, $1) }
}



  /*:
   - Using the `zip2` defined above write an example usage of it involving two `[Validated<A, E>]` values.
   */


let xs1: [Validated<Int, String>] = [
  .valid(1), .invalid(.init("Missing age")), .valid(3)
]

let ys1: [Validated<String, String>] = [
  .valid("a"), .valid("b"), .invalid(.init("Missing name"))
]

let result = zip2(xs1, ys1)

for value in result {
  print(value)
}

// Expected Output
//  .valid((1, "a"))
//  .invalid(["Missing age"])
//  .invalid(["Missing name"])


  /*:
   - Consider the type `Func<R, A?>`. Again we have a nesting of types, each of which have their own `zip2` operation. Can you define a `zip2` on this type that makes use of both structures? Write the signature of such a function and implement it.
   */

struct Func<R, A> {
  let apply: (R) -> A
}

func zip2<R, A, B>(_ fa: Func<R, A?>, _ fb: Func<R, B?>) -> Func<R, (A, B)?> {
  return Func<R, (A, B)?> { r in
    guard let a = fa.apply(r), let b = fb.apply(r) else { return nil}
    return (a, b)
  }
}



  /*:
   - Consider the type `Func<R, [A]>`. Again we have a nesting of types, each of which have their own `zip2` operation. Can you define a `zip2` on this type that makes use of both structures? Write the signature of such a function and implement it.
   */


func zip2<R, A, B>(_ fa: Func<R, [A]>, _ fb: Func<R, [B]>) -> Func<R, [(A, B)]> {
  return Func<R, [(A, B)]> { r in
    Swift.zip(fa.apply(r), fb.apply(r)).map{  ($0, $1) }
  }
}
/*:
   - Do you see anything common in the implementation of all of your functions?
   */


// TODO
  /*:
   5.) In this series of episodes on `zip` we have described zipping types as a kind of way to swap the order of containers, e.g. we can transform a tuple of arrays to an array of tuples `([A], [B]) -> [(A, B)]`. There’s a more general concept that aims to flip contains of any type. Implement the following to the best of your ability, and describe in words what they represent:
   
   - `sequence: ([A?]) -> [A]?`
   
   
   
   - `sequence: ([Result<A, E>]) -> Result<[A], E>`
   - `sequence: ([Validated<A, E>]) -> Validated<[A], E>`
   - `sequence: ([F3<A>]) -> F3<[A]`
   - `sequence: (Result<A?, E>) -> Result<A, E>?`
   - `sequence: (Validated<A?, E>) -> Validated<A, E>?`
   - `sequence: ([[A]]) -> [[A]]`.
   
   Note that you can still flip the order of these containers even though they are both the same container type. What does this represent? Evaluate the function on a few sample nested arrays.
   
   Note that all of these functions also represent the flipping of containers, e.g. an array of optionals transforms into an optional array, an array of results transforms into a result of an array, or a validated optional transforms into an optional validation, etc.
   */
  // TODO

//All elements must be non-nil → return [A] •  If any element is nil → return nil

  
func sequence<A>(_ xs: [A?]) -> [A]? {
  var result: [A] = []
  for x in xs {
    guard let value = x else { return nil }
    result.append(value)
  }
  return result
}

sequence([1, 2, 3])      // => Optional([1, 2, 3])
sequence([1, nil, 3])


//`sequence: ([Validated<A, E>]) -> Validated<[A], E>`
func sequence<A, E>(_ xs: [Validated<A, E>]) -> Validated<[A], E> {
  var result: [A] = []
  for x in xs {
    switch x {
    case .valid(let value):
      result.append(value)
    case .invalid(let error):
      return .invalid(error)
    }
  }
  return .valid(result)
}



func sequence1<A, E>(_ xs: [Validated<A, E>]) -> Validated<[A], E> {
  var result: [A] = []
  var errors: NonEmptyArray<E>? = nil

  for x in xs {
    switch x {
    case .valid(let a):
      result.append(a)
    case .invalid(let e):
      errors = errors.map { $0 + e } ?? e
    }
  }

  return errors.map(Validated.invalid) ?? .valid(result)
}

sequence1([
  .valid(1),
  .invalid(.init("Too short")),
  .invalid(.init("Too old"))
])


// => .invalid(["Too short", "Too old"])

//- `sequence: ([F3<A>]) -> F3<[A]`
func sequence<A>(_ xs: [F3<A>]) -> F3<[A]> {
  return F3<[A]> { callback in
    var result = Array<A?>(repeating: nil, count: xs.count)
    let lock = DispatchQueue(label: "sequence.f3.lock")
    var completed = 0

    for (i, fa) in xs.enumerated() {
      fa.run { value in
        lock.async {
          result[i] = value
          completed += 1
          if completed == xs.count {
            callback(result.compactMap { $0 }) // safe since all filled
          }
        }
      }
    }
  }
}


//- `sequence: (Result<A?, E>) -> Result<A, E>?`

func sequence<A, E>(_ result: Result<A?, E>) -> Result<A, E>? {
  switch result {
  case .failure(let e):
    return .some(.failure(e))
  case .success(let maybeA):
    return maybeA.map(Result.success)
  }
}
//sequence(.success(nil))        // => nil
//sequence(.success(Optional(5))) // => .some(.success(5))
//sequence(.failure("Oops"))     // => .some(.failure("Oops"))


//- `sequence: (Validated<A?, E>) -> Validated<A, E>?`

func sequence<A, E>(_ v: Validated<A?, E>) -> Validated<A, E>? {
  switch v {
  case .invalid(let e):
    return .some(.invalid(e))
  case .valid(let maybeA):
    return maybeA.map(Validated.valid)
  }
}

//- `sequence: ([[A]]) -> [[A]]`.
func sequence<A>(_ xss: [[A]]) -> [[A]] {
  guard let firstRow = xss.first else { return [] }

  return (0..<firstRow.count).map { i in
    xss.map { $0[i] }
  }
}
