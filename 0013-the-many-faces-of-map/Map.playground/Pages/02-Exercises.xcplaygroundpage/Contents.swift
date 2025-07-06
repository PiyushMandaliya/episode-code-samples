/*:
 # The Many Faces of Map Exercises

 1. Implement a `map` function on dictionary values, i.e.

    ```
    map: ((V) -> W) -> ([K: V]) -> [K: W]
    ```

    Does it satisfy `map(id) == id`?

 */
// TODO

func id<A>(_ a: A) -> A {
  return a
}

func map<K, V, W>(_ f: @escaping (V) -> W) -> ([K: V]) -> [K: W] {
  return { dict in
    var result: [K: W] = [:]
    
    dict.forEach{ k, v in
      result[k] = f(v)
    }
   
    return result
  }
}

let dict: [String: Int] = ["a": 1, "b": 2]

let mapped = map(id)(dict)
// vs
let identity = dict


map(id)(dict) == id(dict) // true

/*:
 2. Implement the following function:

    ```
    transformSet: ((A) -> B) -> (Set<A>) -> Set<B>
    ```

    We do not call this `map` because it turns out to not satisfy the properties of `map` that we saw in this episode. What is it about the `Set` type that makes it subtly different from `Array`, and how does that affect the genericity of the `map` function?
 */
// TODO
//func transformSet<A, B>(_ f: @escaping (A) -> B) -> (Set<A>) -> Set<B> {
//  return { set in
//    Set(set.map(f))
//  }
//}

//Sets remove duplicates: You can’t guarantee Set(f(x)) has the same cardinality as Set(x).
//The transformation may collapse distinct elements into the same value, losing info and breaking functor laws.

//let set: Set<Int> = [1, 2, 3, 4]
//let f: (Int) -> Int = { $0 % 2 }
//
//transformSet(f)(set) // Set { 0, 1 } → 4 elements became 2!

/*:
 3. Recall that one of the most useful properties of `map` is the fact that it distributes over compositions, _i.e._ `map(f >>> g) == map(f) >>> map(g)` for any functions `f` and `g`. Using the `transformSet` function you defined in a previous example, find an example of functions `f` and `g` such that:

    ```
    transformSet(f >>> g) != transformSet(f) >>> transformSet(g)
    ```

    This is why we do not call this function `map`.
 */
// TODO
func transformSet<A, B>(_ f: @escaping (A) -> B) -> (Set<A>) -> Set<B> where B: Hashable {
  return { set in
    Set(set.map(f))
  }
}



/*:
 4. There is another way of modeling sets that is different from `Set<A>` in the Swift standard library. It can also be defined as function `(A) -> Bool` that answers the question "is `a: A` contained in the set." Define a type `struct PredicateSet<A>` that wraps this function. Can you define the following?

     ```
     map: ((A) -> B) -> (PredicateSet<A>) -> PredicateSet<B>
     ```

     What goes wrong?
 */
// TODO
struct PredicateSet<A> {
  let contains: (A) -> Bool
}

func map<A, B>(_ f: @escaping (A) -> B) -> (PredicateSet<A>) -> PredicateSet<B> {
  return { setA in
    PredicateSet<B> { b in
      // ?? We need to check if b is in the mapped set
      // But how do we "reverse" f?
      // We need to know if there was some a: A such that f(a) == b && setA.contains(a)
      fatalError("Cannot implement in general")
    }
  }
}
/*:
 5. Try flipping the direction of the arrow in the previous exercise. Can you define the following function?

    ```
    fakeMap: ((B) -> A) -> (PredicateSet<A>) -> PredicateSet<B>
    ```
 */
// TODO
func fakeMap<A, B> (_ f: @escaping (B) -> A) -> (PredicateSet<A>) -> PredicateSet<B> {
  return { setA in
    PredicateSet<B> { b in
      setA.contains(f(b))
    }
  }
}
/*:
 6. What kind of laws do you think `fakeMap` should satisfy?
 */
// TODO
/*:
 7. Sometimes we deal with types that have multiple type parameters, like `Either` and `Result`. For those types you can have multiple `map`s, one for each generic, and no one version is “more” correct than the other. Instead, you can define a `bimap` function that takes care of transforming both type parameters at once. Do this for `Result` and `Either`.
 */
// TODO
enum Either<A, B> {
  case left(A)
  case right(B)
}

enum MyResult<Success, Failure> {
  case success(Success)
  case failure(Failure)
}


func bimap<A, B, C, D>(
  _ f: @escaping (A) -> C,
  _ g: @escaping (B) -> D
) -> (Either<A, B>) -> Either<C, D> {

  return { either in
    switch either {
    case .left(let a):
      return .left(f(a))
    case .right(let b):
      return .right(g(b))
    }
  }
}

func bimap<Success, Failure, NewSuccess, NewFailure>(
  _ f: @escaping (Success) -> NewSuccess,
  _ g: @escaping (Failure) -> NewFailure
) -> (MyResult<Success, Failure>) -> MyResult<NewSuccess, NewFailure> {
  return { result in
      switch result {
      case .success(let success):
        return MyResult.success(f(success))
      case .failure(let failure):
        return MyResult.failure(g(failure))
    }
  }
}

let e: Either<Int, String> = .left(42)

let mapped1 = bimap({ $0 + 1 }, { $0.uppercased() })(e)
print(mapped1) // .left(43)

let e2: Either<Int, String> = .right("hi")
let mapped2 = bimap({ $0 + 1 }, { $0.uppercased() })(e2)
print(mapped2) // .right("HI")



let r: MyResult<Int, String> = .success(10)

let mappedR = bimap({ $0 * 2 }, { $0 + "!" })(r)
print(mappedR) // .success(20)

let r2: MyResult<Int, String> = .failure("oops")
let mappedR2 = bimap({ $0 * 2 }, { $0 + "!" })(r2)
print(mappedR2) // .failure("oops!")
