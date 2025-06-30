/*:
 # Higher-Order Functions Exercises

 1. Write `curry` for functions that take 3 arguments.
 */
func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
  return { a in
    { b in
      { c in
        f(a, b, c)
      }
    }
  }
}
/*:
 2. Explore functions and methods in the Swift standard library, Foundation, and other third party code, and convert them to free functions that compose using `curry`, `zurry`, `flip`, or by hand.
 */
func map<A, B>(_ transform: @escaping (A) -> B) -> ([A]) -> [B] {
  return { a in
    a.map(transform)
  }
}

let multiply7 = map { $0 * 7}
let result = multiply7([1, 2, 3, 4, 5])


let trimmed = " hello ".trimmingCharacters(in: .whitespaces)


func trim(_ set: CharacterSet) -> (String) -> String {
  return { string in
    string.trimmingCharacters(in: set)
  }
}

let trimwhiteSpace = trim(.whitespaces)
trimwhiteSpace(" Piyush    Hi      ")
trim(.whitespaces)(" Hello    ")



let result1 = [3, 1, 2].sorted(by: >)

func sortedBy<A>(_ areInIncreasingOrder: @escaping (A, A) -> Bool) -> ([A]) -> [A] {
  return { array in
    array.sorted(by: areInIncreasingOrder)
  }
}

sortedBy(<)([4,6,7,4,33,7,8,-0])



/*:
 3. Explore the associativity of function arrow `->`. Is it fully associative, _i.e._ is `((A) -> B) -> C` equivalent to `(A) -> ((B) -> C)`, or does it associate to only one side? Where does it parenthesize as you build deeper, curried functions?
 */
// TODO
/*:
 4. Write a function, `uncurry`, that takes a curried function and returns a function that takes two arguments. When might it be useful to un-curry a function?
 */
func uncurry<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (A, B) -> C {
  return { (a: A, b: B) in
    f(a)(b)
  }
}
/*:
 5. Write `reduce` as a curried, free function. What is the configuration _vs._ the data?
 */
// TODO

[1, 2, 3].reduce(1, +)

func reduce<A, B>(_ initial: B) -> (@escaping (B, A) -> B) -> ([A]) -> B {
  return { combine in
    { array in
      array.reduce(initial, combine)
    }
  }
}


/*:
 6. In programming languages that lack sum/enum types one is tempted to approximate them with pairs of optionals. Do this by defining a type `struct PseudoEither<A, B>` of a pair of optionals, and prevent the creation of invalid values by providing initializers.

    This is “type safe” in the sense that you are not allowed to construct invalid values, but not “type safe” in the sense that the compiler is proving it to you. You must prove it to yourself.
 */
struct PseudoEither<A, B> {
  let a: A?
  let b: B?
  
  private init(a: A?, b: B?) {
    self.a = a
    self.b = b
  }
  
  static func left(_ a: A) -> Self {
    return PseudoEither(a: a, b: nil)
  }
  
  static func right(_ b: B) -> Self {
    return PseudoEither(a: nil, b: b)
  }
}


/*:
 7. Explore how the free `map` function composes with itself in order to transform a nested array. More specifically, if you have a doubly nested array `[[A]]`, then `map` could mean either the transformation on the inner array or the outer array. Can you make sense of doing `map >>> map`?
 */
// TODO


func >>> <A, B, C>(
  _ f: @escaping (A) -> B,
  _ g: @escaping (B) -> C
) -> (A) -> C {
  return { a in g(f(a)) }
}


let nested = [[1, 2], [3, 4]]

let increment = { (x: Int) in x + 1 }

// Compose to map increment over inner elements:
let doubleMap = map >>> map

let result = doubleMap(increment)(nested)
// result: [[2, 3], [4, 5]]

