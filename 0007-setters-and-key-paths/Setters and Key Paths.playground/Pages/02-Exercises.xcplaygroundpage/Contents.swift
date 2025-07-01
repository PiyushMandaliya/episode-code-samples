/*:
 # Setters and Key Paths Exercises

 1. In this episode we used `Dictionary`’s subscript key path without explaining it much. For a `key: Key`, one can construct a key path `\.[key]` for setting a value associated with `key`. What is the signature of the setter `prop(\.[key])`? Explain the difference between this setter and the setter `prop(\.[key]) <<< map`, where `map` is the optional map.
 */
// | Expression              | Type                                   | Behavior                                                         |
// | ----------------------- | -------------------------------------- | ---------------------------------------------------------------- |
// | `prop(\.[key])`         | `(Value?) -> Value?` → `Dict` → `Dict` | You’re responsible for handling nils (can add/remove keys)       |
// | `prop(\.[key]) <<< map` | `(Value) -> Value` → `Dict` → `Dict`   | Only applies if key exists (non-nil); otherwise, leaves it alone |

//var headers: [String: String] = [:]
//headers
//  |> (prop(\.[“Content-Type”])) { _ in "application/json" }


///Uppercase an existing header (if any):
//headers
//  |> (prop(\.[“Content-Type”]) <<< map) { $0.uppercased() }
/*:
 2. The `Set<A>` type in Swift does not have any key paths that we can use for adding and removing values. However, that shouldn't stop us from defining a functional setter! Define a function `elem` with signature `(A) -> ((Bool) -> Bool) -> (Set<A>) -> Set<A>`, which is a functional setter that allows one to add and remove a value `a: A` to a set by providing a transformation `(Bool) -> Bool`, where the input determines if the value is already in the set and the output determines if the value should be included.
 */
func elem<A: Hashable>(_ a: A) -> (@escaping (Bool) -> Bool) -> (Set<A>) -> Set<A> {
  return { updatePresence in
    return { set in
      var copy = set
      let currentlyPresent = set.contains(a)
      let shouldBePresent = updatePresence(currentlyPresent)

      if shouldBePresent {
        copy.insert(a)
      } else {
        copy.remove(a)
      }

      return copy
    }
  }
}


//let set: Set<Int> = [1, 2, 3]
//
//// Toggle 2 (remove it)
//let toggledSet = set |> elem(2) { !$0 }  // [1, 3]
//
//// Ensure 4 is present (add it)
//let updatedSet = set |> elem(4) { _ in true } // [1, 2, 3, 4]
//
//// Remove 1 if it's already present
//let result = set |> elem(1) { $0 && false } // [2, 3]

/*:
 3. Generalizing exercise #1 a bit, it turns out that all subscript methods on a type get a compiler generated key path. Use array’s subscript key path to uppercase the first favorite food for a user. What happens if the user’s favorite food array is empty?
 */

//func prop<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
//  -> (@escaping (Value) -> Value)
//  -> (Root)
//  -> Root {
//  return { update in
//    { root in
//      var copy = root
//      copy[keyPath: kp] = update(copy[keyPath: kp])
//      return copy
//    }
//  }
//}
//
//struct Food {
//  var name: String
//}
//
//struct User {
//  var favoriteFoods: [Food]
//}
//
//let update = prop(\User.favoriteFoods[0]) <<< prop(\.name)
//
//let user = User(favoriteFoods: [Food(name: "Tacos"), Food(name: "Nachos")])
//
//let updatedUser = user
//  |> update { $0.uppercased() }
//
//public func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
//  return { $0.map(f) }
//}
//
//let user1 = User(favoriteFoods: [])
//user
//  |> update { $0.uppercased() } // ❌ Crash!
/*:
 4. Recall from a [previous episode](https://www.pointfree.co/episodes/ep5-higher-order-functions) that the free `filter` function on arrays has the signature `((A) -> Bool) -> ([A]) -> [A]`. That’s kinda setter-like! What does the composed setter `prop(\\User.favoriteFoods) <<< filter` represent?
 */
func filter<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> [A] {
  return { $0.filter(p) }
}

func prop<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
  -> (@escaping (Value) -> Value)
  -> (Root)
  -> Root {

    return { update in
      { root in
        var copy = root
        copy[keyPath: kp] = update(copy[keyPath: kp])
        return copy
      }
    }
}


struct Food {
  var name: String
}

struct User {
  var favoriteFoods: [Food]
}

let user = User(favoriteFoods: [
  Food(name: "Tacos"),
  Food(name: "Nachos"),
  Food(name: "Salad")
])

let noNachosUser = user
  |> (prop(\User.favoriteFoods) <<< filter) { $0.name != "Nachos" }




/*:
 5. Define the `Result<Value, Error>` type, and create `value` and `error` setters for safely traversing into those cases.
 */
enum Result<Value, Error> {
  case success(Value)
  case failure(Error)
}

func value<Value, Error>(_ f: @escaping(Value) -> Value)
-> (Result<Value, Error>) -> Result<Value, Error> {
  return { result in
    switch result {
    case .success(let value):
      return .success(f(value))
    case .failure(let error):
      return .failure(error)
    }
  }
}

let r1: Result<Int, String> = .success(42)
let r2: Result<Int, String> = .failure("Not found")

r1
  |> value { $0 + 1 }

//// Uppercase the error
//let uppercasedError = error { $0.uppercased() }(r2) // .failure("NOT FOUND")
/*:
 6. Is it possible to make key path setters work with `enum`s?
 */
func propInout<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
  -> (@escaping (inout Value) -> Void)
  -> (inout Root) -> Void {
    return { update in
      { root in
        update(&root[keyPath: kp])
      }
    }
}

