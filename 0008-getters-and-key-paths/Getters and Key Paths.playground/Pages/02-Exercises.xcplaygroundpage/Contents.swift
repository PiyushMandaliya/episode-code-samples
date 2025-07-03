/*:
 # Getters and Key Paths Exercises

 1. Find three more standard library APIs that can be used with our `get` and `^` helpers.
 */
struct User {
  let id: Int
  let email: String
}

extension User {
  var isStaff: Bool {
    return self.email.hasSuffix("@pointfree.co")
  }
}

func get<Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
  return { root in
    root[keyPath: kp]
  }
}


extension Sequence {
  func map<Value>(_ kp: KeyPath<Element, Value>) -> [Value] {
    return self.map { $0[keyPath: kp] }
  }
}

prefix operator ^
prefix func ^ <Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
  return get(kp)
}


let users = [
  User(id: 1, email: "blob@pointfree.co"),
  User(id: 2, email: "protocol.me.maybe@appleco.example"),
  User(id: 3, email: "bee@co.domain"),
  User(id: 4, email: "a.morphism@category.theory")
]

users.map(^\.email)

users.contains(where: get(\.email) >>> { $0.hasSuffix("@example") })

users.contains(where: ^\.isStaff)


//2

struct Person {
  let nickname: String?
}

let people = [Person(nickname: "Ace"), Person(nickname: nil)]

people.compactMap(\.nickname)


//3
let nested = [[1, 2], [3, 4]]
nested.flatMap(get(\.self)) // or just `flatMap { $0 }`

// With structs
struct Group {
  let members: [String]
}

let groups = [Group(members: ["A", "B"]), Group(members: ["C"]), Group(members: ["A", "C", "D"])]

// using get or ^
groups.flatMap(get(\.members))
groups.flatMap(^\.members)

/*:
 2. The one downside to key paths being _only_ compiler generated is that we do not get to create new ones ourselves. We only get the ones the compiler gives us.

    And there are a lot of getters and setters that are not representable by key paths. For example, the “identity” key path `KeyPath<A, A>` that simply returns `self` for the getter and that setting on it leaves it unchanged. Can you think of any other interesting getters/setters that cannot be represented by key paths?
 */
// TODO
/*:
 3. In our [Setters and Key Paths](https://www.pointfree.co/episodes/ep7-setters-and-key-paths) episode we showed how `map` could kinda be seen as a “setter” by saying:

    “If you tell me how to transform an `A` into a `B`, I will tell you how to transform an `[A]` into a `[B]`.”

    There is also a way to think of `map` as a “getter” by saying:

    “If you tell me how to get a `B` out of an `A`, I will tell you how to get an `[B]` out of an `[A]`.”

    Try composing `get` with free `map` function to construct getters that go even deeper into a structure.

    You may want to use the data types we defined [last time](https://github.com/pointfreeco/episode-code-samples/blob/1998e897e1535a948324d590f2b53b6240662379/0007-setters-and-key-paths/Setters%20and%20Key%20Paths.playground/Contents.swift#L2-L20).
 */
//func get<Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
//  return { root in root[keyPath: kp] }
//}

func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
  return { $0.map(f) }
}

struct Food {
  var name: String
}

struct Location {
  var name: String
}

struct User1 {
  var favoriteFoods: [Food]
  var location: Location
  var name: String
}

let user = User1(
  favoriteFoods: [Food(name: "Tacos"), Food(name: "Nachos")],
  location: Location(name: "Brooklyn"),
  name: "Blob"
)

get(\User1.favoriteFoods)
user |>
get(\User1.name)


user |>
  get(\User1.favoriteFoods) >>> map(get(\Food.name))


user |>
get(\User1.favoriteFoods) >>> map(get(\Food.name)) >>> get(\.count)

user |>
get(\User1.favoriteFoods) >>> map(get(\Food.name) >>> { $0.prefix(2) })

user |>
get(\User1.favoriteFoods) >>> map(get(\Food.name)) >>> map { $0.prefix(1) }


/*:
 4. Repeat the above exercise by seeing how the free optional `map` can allow you to dive deeper into an optional value to extract out a part.

    Key paths even give first class support for this operation. Do you know what it is?
 */
struct OptionalUser {
  var location: Location?
}

func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
  return { $0.map(f)}
}

//func get<Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
//  return { $0[keyPath: kp] }
//}

var optionalUser: [OptionalUser] = [
  OptionalUser(location: Location(name: "Surat")),
  OptionalUser(location: Location(name: "Mumbai")),
  OptionalUser(location: Location(name: "Pune"))
]


optionalUser

dump (
  optionalUser
  |> map(get(\.location?.name))
)

let opUser = OptionalUser(location: Location(name: "Toronto"))

opUser |> get(\OptionalUser.location) >>> map(get(\Location.name))

/*:
 6. Key paths work immediately with all fields in a struct, but only work with computed properties on an enum. We saw in [Algebra Data Types](https://www.pointfree.co/episodes/ep4-algebraic-data-types) that structs and enums are really just two sides of a coin: neither one is more important or better than the other.

    What would it look like to define an `EnumKeyPath<Root, Value>` type that encapsulates the idea of “getting” and “setting” cases in an enum?
 */
// TODO

struct EnumKeyPath<Root, Value> {
  let extract: (Root) -> Value?
  let embed: (Value) -> Root
}

enum Result<A, E> {
  case success(A)
  case failure(E)
}


extension Result {
  static var successCase: EnumKeyPath<Result<A, E>, A> {
    return EnumKeyPath<Result<A, E>, A> (
      
      extract: { result in
        guard case let .success(value) = result else { return nil }
        return value
      },
      embed: { value in
          .success(value)
      }
    )
  }
  
  static var failureCase: EnumKeyPath<Result<A, E>, E> {
    return EnumKeyPath(
      extract: { result in
        guard case let .failure(error) = result else { return nil }
        return error
      }, embed: { error in
          .failure(error)
      }
    )
  }
}
/*:
 7. Given a value in `EnumKeyPath<A, B>` and `EnumKeyPath<B, C>`, can you construct a value in
 `EnumKeyPath<A, C>`?
 */
// TODO

func >>> <A, B, C>(lhs: EnumKeyPath<A, B>, rhs: EnumKeyPath<B, C>) -> EnumKeyPath<A, C> {
  return EnumKeyPath<A, C>(
    extract: { a in
      lhs.extract(a).flatMap(rhs.extract)
    }, embed: { c in
      lhs.embed(rhs.embed(c))
    }
  )
}
/*:
 8. Given a value in `EnumKeyPath<A, B>` and a value in `EnumKeyPath<A, C>`, can you construct a value in `EnumKeyPath<A, Either<B, C>>`?
 */
// TODO


struct EnumKeyPath1<Root, Value> {
  let extract: (Root) -> Value?
  let embed: (Value) -> Root
}


enum Either<A, B> {
  case left(A)
  case right(B)
}

func union<A, B, C>(
  _ lhs: EnumKeyPath1<A, B>,
  _ rhs: EnumKeyPath1<A, C>
) -> EnumKeyPath1<A, Either<B, C>> {
  return EnumKeyPath1<A, Either<B, C>>(
    extract: { a in
      if let b = lhs.extract(a) {
        return .left(b)
      } else if let c = rhs.extract(a) {
        return .right(c)
      } else {
        return nil
      }
    }, embed:   { either in
      switch either {
      case let .left(b):
        return lhs.embed(b)
      case let .right(c):
        return rhs.embed(c)
      }
    }
  )
}


