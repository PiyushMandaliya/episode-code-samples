/*:
 # Algebraic Data Types: Exponents, Exercises

 1. Explore the equivalence of `1^a = a`.
 */
// 1 ^ a = a
// 1 -> (A) = A
// Void -> (A) = A
// (A) <- Void = A

func to<A>(_ f: () -> A) -> A {
  return f()
}

func from<A>(_ a: A) -> () -> A {
  return { a }
}
/*:
 2. Explore the properties of `0^a`. Consider the cases where `a = 0` and `a != 0` separately.
 */
// 0^a where  a == 0
//0 ^ 0 = 1
//Never ^ Never = 1
// (Never) <- Never = 1


// 0^a where  a != 0
//0 ^ A = 0
//Never ^ A = Never
// Never <- A = Never



/*:
 3. How do you think generics fit into algebraic data types? We've seen a bit of this with thinking of `Optional<A>` as `A + 1 = A + Void`.
 */
// TODO

enum Optional<A> {
  case none
  case some(A)
}
//Optional<A> = 1 + A

func identity<A>(_ a: A) -> A {
  return a
}


/*:
 4. Show that the set type over a type `A` can be represented as `2^A`. What does union and intersection look like in this formulation?
 */
// Set<A> = (A) -> Bool

// Each function form A to Bool represents a predicate, and thus a subset of A

typealias Set<A> = (A) -> Bool

func contains<A>(_ set: @escaping Set<A>, _ value: A) -> Bool {
  return set(value)
}

let events: Set<Int> = { $0 % 2 == 0}
contains(events, 4)
contains(events, 5)

func union<A>(_ s1: @escaping Set<A>, _ s2: @escaping Set<A>) -> Set<A> {
  return { a in
      s1(a) || s2(a)
  }
}

func intersection<A>(_ s1: @escaping Set<A>, _ s2: @escaping Set<A>) -> Set<A> {
  return { a in
      s1(a) && s2(a)
  }
}
/*:
 5. Show that the dictionary type with keys in `K`  and values in `V` can be represented by `V^K`. What does union of dictionaries look like in this formulation?
 */
// Dictionary<K, V> = (K) -> Optional<V>
// =(Optional<V>)^K

// Total Dictionary V^K = (K) ->v
// Partial Dictionary (V + 1)^K = (K) -> Optional<V>

func union<K, V>(_ d1: @escaping (K) -> V?, _ d2: @escaping (K) -> V?) -> (K) -> V? {
  return { key in
    d1(key) ?? d2(key)
  }
}

let d1: (String) -> Int? = { key in key == "a" ? 1 : nil }
let d2: (String) -> Int? = { key in key == "b" ? 2 : nil }

let merged = union(d1, d2)

merged("a") // 1
merged("b") // 2
merged("c") // nil
/*:
 6. Implement the following equivalence:
 */
func to<A, B, C>(_ f: @escaping (Either<B, C>) -> A) -> ((B) -> A, (C) -> A) {
  let fB: (B) -> A = { b in f(.left(b))}
  let fC: (C) -> A = { c in f(.right(c))}
  return (fB, fC)
}

func from<A, B, C>(_ f: ((B) -> A, (C) -> A)) -> (Either<B, C>) -> A {
  return { either in
    switch either {
    case .left(let b):
      return f.0(b)
    case .right(let c):
      return f.1(c)
    }
  }
}
/*:
 7. Implement the following equivalence:
 */
func to<A, B, C>(_ f: @escaping (C) -> (A, B)) -> ((C) -> A, (C) -> B) {
  let fa: (C) -> A = { c in f(c).0}
  let fb: (C) -> B = { c in f(c).1}
  
  return (fa, fb)
}

func from<A, B, C>(_ f: ((C) -> A, (C) -> B)) -> (C) -> (A, B) {
  return { c in
    let a = f.0(c)
    let b = f.1(c)
    
    return (a, b)
  }
}

// A × B ≅ B × A

func swap<A, B>(_ pair: (A, B)) -> (B, A) {
  return (pair.1, pair.0)
}
 
swap((42, "Hello"))


// A X (B + C) = (A X B) + (A X C)
func distribute<A, B, C>(_ pair: (A, Either<B, C>)) -> Either<(A, B), (A, C)> {
  let (a, either) = pair
  switch either {
  case .left(let b):
    return .left((a, b))
  case .right(let c):
    return .right((a, c))
  }
}


// (A X B) + (A X C) = A X (B + C)
func factor<A, B, C>(_ sum: Either<(A, B), (A, C)>) -> (A, Either<B, C>) {
  switch sum {
  case .left(let value):
    return (value.0, .left(value.1))
  case .right(let value):
    return (value.0, .right(value.1))
  }
}


// Curring (A × B) → C ≅ (A) → (B) → C

func currry<A, B, C>(_ f: @escaping (A,B) -> C) -> (A) -> (B) -> C {
  return { a in { b in f(a,b) } }
}

func uncurry<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (A, B) -> C {
  return { a, b in f(a)(b) }
}

func multiply(x: Int, y: Int) -> Int {
  return x * y
}

let curriedMultiply = currry(multiply)
let time2 = curriedMultiply(2)
time2(4)

func greet(firstName: String, lastName: String) -> String {
  return "Hello, \(firstName) \(lastName)!"
}



//Cheat Seat

//
//
//// MARK: - Currying & Uncurrying
//
//func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
//  return { a in { b in f(a, b) } }
//}
//
//func uncurry<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (A, B) -> C {
//  return { a, b in f(a)(b) }
//}
//
//// MARK: - Zurry / Unzurry
//
//func zurry<A>(_ f: () -> A) -> A {
//  return f()
//}
//
//func unzurry<A>(_ a: A) -> () -> A {
//  return { a }
//}
//
//// MARK: - Either helpers
//
//enum Either<A, B> {
//  case left(A)
//  case right(B)
//}
//
//func to<A, B, C>(_ f: @escaping (Either<B, C>) -> A) -> ((B) -> A, (C) -> A) {
//  let fb: (B) -> A = { b in f(.left(b)) }
//  let fc: (C) -> A = { c in f(.right(c)) }
//  return (fb, fc)
//}
//
//func from<A, B, C>(_ f: ((B) -> A, (C) -> A)) -> (Either<B, C>) -> A {
//  return { either in
//    switch either {
//    case let .left(b): return f.0(b)
//    case let .right(c): return f.1(c)
//    }
//  }
//}
//
//// MARK: - Tuple-returning function helpers
//
//func to<A, B, C>(_ f: @escaping (C) -> (A, B)) -> ((C) -> A, (C) -> B) {
//  let fa: (C) -> A = { c in f(c).0 }
//  let fb: (C) -> B = { c in f(c).1 }
//  return (fa, fb)
//}
//
//func from<A, B, C>(_ f: ((C) -> A, (C) -> B)) -> (C) -> (A, B) {
//  return { c in (f.0(c), f.1(c)) }
//  }
//
//// MARK: - Throwing <-> Result
//
//func unthrow<A, B>(_ f: @escaping (A) throws -> B) -> (A) -> Result<B, Error> {
//  return { a in
//    do { return .success(try f(a)) }
//    catch { return .failure(error) }
//  }
//}
//
//func throwing<A, B>(_ f: @escaping (A) -> Result<B, Error>) -> (A) throws -> B {
//  return { a in
//    switch f(a) {
//    case let .success(b): return b
//    case let .failure(e): throw e
//    }
//  }
//}
//
//// MARK: - Never absurdity
//
//func absurd<A>(_ never: Never) -> A {
//  switch never {}
//}
//
//// MARK: - Example usage
//
//let eitherFn: (Either<Int, String>) -> Bool = { either in
//  switch either {
//  case .left(let i): return i > 0
//  case .right(let s): return !s.isEmpty
//  }
//}
//
//let (intFn, strFn) = to(eitherFn)
//intFn(5)         // true
//strFn("Hello")   // true
//
//let rebuilt = from((intFn, strFn))
//rebuilt(.left(5))      // true
//rebuilt(.right("Hi")) // true
