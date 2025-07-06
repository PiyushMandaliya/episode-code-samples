/*:
 # Tagged Exercises

 1. Conditionally conform Tagged to ExpressibleByStringLiteral in order to restore the ergonomics of initializing our User’s email property. Note that ExpressibleByStringLiteral requires a couple other prerequisite conformances.
 */

struct Tagged<Tag, RawValue> {
  let rawValue: RawValue
}

extension Tagged: Decodable where RawValue: Decodable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(rawValue: try container.decode(RawValue.self))
  }
}

extension Tagged: Equatable where RawValue: Equatable {
  static func == (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }

}

extension Tagged: ExpressibleByStringLiteral,
                  ExpressibleByExtendedGraphemeClusterLiteral,
                  ExpressibleByUnicodeScalarLiteral
where RawValue: ExpressibleByStringLiteral {
  init(stringLiteral value: RawValue.StringLiteralType) {
    self.init(rawValue: RawValue(stringLiteral: value))
  }

  typealias StringLiteralType = RawValue.StringLiteralType
}
/*:
 2. Conditionally conform Tagged to Comparable and sort users by their id in descending order.
 */
extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
  init(integerLiteral value: RawValue.IntegerLiteralType) {
    self.rawValue = RawValue(integerLiteral: value)
  }
  
  typealias IntegerLiteralType = RawValue.IntegerLiteralType
}

extension Tagged: Comparable where RawValue: Comparable {
  static func < (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

enum EmailTag {}
typealias Email = Tagged<EmailTag, String>

struct Subscription: Decodable {
  //  struct Id: Decodable, RawRepresentable, Equatable { let rawValue: Int }
  typealias Id = Tagged<Subscription, Int>

  let id: Id
  let ownerId: User.Id
}

//struct User: Decodable {
//  typealias Id = Tagged<User, Int>
//
//  let id: Id
//  let name: String
//  let email: Email
//  let subscriptionId: Subscription.Id?
//}

//let users: [User] = [
//  User(id: 1, name: "Blob", email: "blob@pointfree.co", subscriptionId: 1),
//  User(id: 2, name: "Stephen", email: "stephen@pointfree.co", subscriptionId: nil),
//  User(id: 3, name: "Brandon", email: "brandon@pointfree.co", subscriptionId: 1)
//]
//
//let sortedUsers = users.sorted { $0.id > $1.id }
//
//for user in sortedUsers {
//  print("\(user.id.rawValue): \(user.name)")
//}
/*:
 3. Let’s explore what happens when you have multiple fields in a struct that you want to strengthen at the type level. Add an age property to User that is tagged to wrap an Int value. Ensure that it doesn’t collide with User.Id. (Consider how we tagged Email.)
 */
enum UserIdTag {}
enum UserAgeTag {}

struct User: Decodable {
  typealias Id = Tagged<UserIdTag, Int>
  typealias Age = Tagged<UserAgeTag, Int>
  
  let id: Id
  let name: String
  let email: Email
  let age: Age
  let subscriptionId: Subscription.Id?
}

let user = User(
  id: Tagged(rawValue: 1),
  name: "Blob",
  email: Tagged(rawValue: "blob@pointfree.co"),
  age: Tagged(rawValue: 30),
  subscriptionId: Tagged(rawValue: 1)
)

print(user.id.rawValue)   // 1
print(user.age.rawValue)  // 30

// Compiler prevents:
// let oops: User.Id = user.age  // ❌ type mismatch

/*:
 4. Conditionally conform Tagged to Numeric and alias a tagged type to Int representing Cents. Explore the ergonomics of using mathematical operators and literals to manipulate these values.
 */
extension Tagged: AdditiveArithmetic where RawValue: Numeric {
  static var zero: Tagged {
    Tagged(rawValue: .zero)
  }
  
  init?<T>(exactly source: T) where T : BinaryInteger {
    guard let value = RawValue(exactly: source) else { return nil }
    self.init(rawValue: value)
  }

  static func + (lhs: Tagged, rhs: Tagged) -> Tagged {
    Tagged(rawValue: lhs.rawValue + rhs.rawValue)
  }
  
  static func - (lhs: Tagged, rhs: Tagged) -> Tagged {
    Tagged(rawValue: lhs.rawValue - rhs.rawValue)
  }
  
  static func * (lhs: Tagged, rhs: Tagged) -> Tagged {
    Tagged(rawValue: lhs.rawValue * rhs.rawValue)
  }
  
  static func += (lhs: inout Tagged, rhs: Tagged) {
    lhs = lhs + rhs
  }
  
  static func -= (lhs: inout Tagged, rhs: Tagged) {
    lhs = lhs - rhs
  }
  
  static func *= (lhs: inout Tagged, rhs: Tagged) {
    lhs = lhs * rhs
  }
  
  var magnitude: RawValue.Magnitude {
    rawValue.magnitude
  }
}



enum CentsTag {}
typealias Cents = Tagged<CentsTag, Int>

let price1: Cents = 150
let price2: Cents = 50

let total = price1 + price2
print(total.rawValue) // 200

var subtotal: Cents = 100
subtotal += 50
print(subtotal.rawValue) // 150

let discounted = total - 30
print(discounted.rawValue) // 170


/*:
 5. Create a tagged type, Light<A> = Tagged<A, Color>, where A can represent whether the light is on or off. Write turnOn and turnOff functions to toggle this state.
 */
import UIKit

enum On { }
enum Off { }

typealias Light<State> = Tagged<State, UIColor>

func turnOn(_ light: Light<Off>) -> Light<On> {
  Light<On>(rawValue: light.rawValue)
}

func turnOff(_ light: Light<On>) -> Light<Off> {
  Light<Off>(rawValue: light.rawValue)
}

let redLight: Light<Off> = Light<Off>(rawValue: .red)

let onLight = turnOn(redLight)
print(onLight.rawValue)  // UIDeviceRGBColorSpace 1 0 0 1

let offLight = turnOff(onLight)
print(offLight.rawValue)  // UIDeviceRGBColorSpace 1 0 0 1

/*:
 6. Write a function, changeColor, that changes a Light’s color when the light is on. This function should produce a compiler error when passed a Light that is off.
 */
// TODO

func changeColor(_ light: Light<On>, to color: UIColor) -> Light<On> {
   Light<On>(rawValue: color)
}
/*:
 7. Create two tagged types with Double raw values to represent Celsius and Fahrenheit temperatures. Write functions celsiusToFahrenheit and fahrenheitToCelsius that convert between these units.
 */
enum CelsiusTag {}
enum FahrenheitTag { }

typealias Celsius = Tagged<CelsiusTag, Double>
typealias Fahrenheit = Tagged<FahrenheitTag, Double>

func celsiusToFahrenheit(_ celsius: Celsius) -> Fahrenheit {
  let f = celsius.rawValue * 9 / 5 + 32
  return Fahrenheit(rawValue: f)
}

func fahrenheitToCelsius(_ f: Fahrenheit) -> Celsius {
  let c = (f.rawValue - 32) * 5 / 9
  return Celsius(rawValue: c)
}
/*:
 8. Create Unvalidated and Validated tagged types so that you can create a function that takes an Unvalidated<User> and returns an Optional<Validated<User>> given a valid user. A valid user may be one with a non-empty name and an email that contains an @.
 */
enum ValidatedTag { }
enum UnvalidatedTag { }

typealias Validated = Tagged<ValidatedTag, User>
typealias Unvalidated = Tagged<UnvalidatedTag, User>

func createValidatedUser(_ user: Unvalidated) -> Validated? {
  guard !user.rawValue.email.rawValue.contains("@") else {
    return nil
  }
  
  return Validated(rawValue: user.rawValue)
}
