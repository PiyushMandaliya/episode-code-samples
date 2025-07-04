/*:
 # A Tale of Two Flat-Maps, Exercises

 1. Define `filtered` as a function from `[A?]` to `[A]`.
 */
func filtered<A>(_ xs: [A?]) -> [A] {
  return xs.compactMap { $0 }
}
/*:
 2. Define `partitioned` as a function from `[Either<A, B>]` to `(left: [A], right: [B])`. What does this function have in common with `filtered`?
 */
enum Either<A, B> {
  case left(A)
  case right(B)
}

func partitioned<A, B> (_ xs: [Either<A, B>]) -> (left: [A], right: [B]) {
  var left: [A] = []
  var right: [B] = []
  
  xs.forEach { x in
    switch x {
    case .left(let a):
      left.append(a)
    case .right(let b):
      right.append(b)
    }
  }

  return (left, right)
}
/*:
 3. Define `partitionMap` on `Optional`.
 */
func partitionMap<A, B, C> (_ f: @escaping (A) -> Either<B, C>) -> (A?) -> (left: B?, right: C?) {
  return { optional in
    guard let value = optional else { return (nil, nil) }
    
    switch f(value) {
    case .left(let b):
      return (b, nil)
    case .right(let c):
      return (nil, c)
    }
  }
}
/*:
 4. Dictionary has `mapValues`, which takes a transform function from `(Value) -> B` to produce a new dictionary of type `[Key: B]`. Define `filterMapValues` on `Dictionary`.
 */
extension Dictionary {
  func filterMapValues<B>(_ f: @escaping (Value) -> B?) -> [Key: B] {
    var result: [Key: B] = [:]
    
    for (key, value) in self {
      if let transformed = f(value) {
        result[key] = transformed
      }
    }
    
    return result
  }
}

let scores: [String: String] = [
  "Alice": "90",
  "Bob": "eighty",
  "Charlie": "85"
]

let numericScores = scores.filterMapValues { Int($0) }

print(numericScores)
// Output: ["Alice": 90, "Charlie": 85]

/*:
 5. Define `partitionMapValues` on `Dictionary`.
 */
extension Dictionary {
  
  func partitionMapValues<Left, Right>( _ f: (Value) -> Either<Left, Right>)
  -> (lefts: [Key: Left], rights: [Key: Right]) {
    
    var left: [Key: Left] = [:]
    var right: [Key: Right] = [:]
    
    for (key, value) in self {
      switch f(value) {
        
      case .left(let a):
        left[key] = a
      case .right(let b):
        right[key] = b
      }
    }
    
    return (left, right)
  }
}


//let data: [String: String] = [
//  "Alice": "90",
//  "Bob": "eighty",
//  "Charlie": "85"
//]
//
//let partitioned = data.partitionMapValues { str in
//  if let intValue = Int(str) {
//    return .left(intValue)
//  } else {
//    return .right(str)
//  }
//}
//
//print(partitioned.lefts)  // ["Alice": 90, "Charlie": 85]
//print(partitioned.rights) // ["Bob": "eighty"]

/*:
 6. Rewrite `filterMap` and `filter` in terms of `partitionMap`.
 */
/*:
 7. Is it possible to define `partitionMap` on `Either`?
 */

func partitionMap<A, B, C>(
  _ f: @escaping (A) -> Either<B, C>
) -> ([A]) -> (lefts: [B], rights: [C]) {
  return { xs in
    var lefts: [B] = []
    var rights: [C] = []
    for x in xs {
      switch f(x) {
      case .left(let l): lefts.append(l)
      case .right(let r): rights.append(r)
      }
    }
    return (lefts, rights)
  }
}

func filterMap<A, B>(
  _ transform: @escaping (A) -> B?
) -> ([A]) -> [B] {
  return { xs in
    partitionMap(
      { a -> Either<Void, B> in
        transform(a).map(Either.right) ?? .left(())
      }
    )(xs).rights
  }
}

