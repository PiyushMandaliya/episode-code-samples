/*:
 # Functional Setters Exercises

 1. As we saw with free `map` on `Array`, define free `map` on `Optional` and use it to compose setters that traverse into an optional field.
 */
func map<A, B> (_ f: @escaping (A) -> B) -> (A?) -> B? {
  return { a in
    a.map(f)
  }
}
/*:
 2. Take a `struct`, _e.g._:

```
struct User {
  let name: String
}
```

 Write a setter for its property. Take (or add) another property, and add a setter for it. What are some potential issues with building these setters?
 */
//struct User {
//  var name: String
//}
//
//
//func setName(_ name: String) -> (User) -> User {
//  return { user in
//    var copy = user
//    copy.name = name
//    return copy
//  }
//}
/*:
 3. Take a `struct` with a nested `struct`, _e.g._:

```
struct Location {
  let name: String
}

struct User {
  let location: Location
}
```

 Write a setter for `userLocationName`. Now write setters for `userLocation` and `locationName`. How do these setters compose?
 */
struct Location {
  let name: String
}

struct User {
  let location: Location
}

func setUserLocationName(_ name: String) -> (User) -> User {
  return { user in
    return User(location:  Location(name: name))
  }
}

func setLocationName(_ name: String) -> (Location) -> Location {
  return { location in
    return Location(name: name)
  }
}

func setUserLocation(_ newLocation: Location) -> (User) -> User {
  return { user in
    User(location: newLocation)
  }
}
/*:
 4. Do `first` and `second` work with tuples of three or more values? Can we write `first`, `second`,`third`, and `nth` for tuples of _n_ values?
 */
func third<A, B, C>(_ f: @escaping (C) -> C) -> ((A, B, C)) -> (A, B, C) {
  return { (arg) -> (A, B, C) in
    
    let (a, b, c) = arg
    return (a, b, f(c))
  }
}

let t = (1, "hello", true)
let updated = third { !$0 }(t)  // (1, "hello", false)

//We cannot write the setter for the nth touple as it doesn't support recursive map.
/*:
 5. Write a setter for a dictionary that traverses into a key to set a value.
 */
func over<K: Hashable, V> (_ key: K, _ value: V) -> ([K: V]) -> [K: V] {
  return { dict in
    var copy = dict
    copy[key] = value
    return copy
  }
}

let dict = ["name": "piyush", "lang": "swift"]

over("name", "ABC")(dict)
over("role", "Manager")(dict)

/*:
 6. What is the difference between a function of the form `((A) -> B) -> (C) -> (D)` and one of the form `(A) -> (B) -> (C) -> D`?
 */
// TODO
