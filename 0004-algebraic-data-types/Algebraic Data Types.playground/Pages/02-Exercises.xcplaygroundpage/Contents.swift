/*:
 # Algebraic Data Types Exercises

 1. What algebraic operation does the function type `(A) -> B` correspond to? Try explicitly enumerating all the values of some small cases like `(Bool) -> Bool`, `(Unit) -> Bool`, `(Bool) -> Three` and `(Three) -> Bool` to get some intuition.
 */
// (A) -> B = B^A
//(Bool) - > Bool = 2^2 = 4
//(Unit) -> Bool = 1^2 = 2
//(Bool) -> Three = 3^2 = 9
// (Three) -> Bool = 2^3 =8

/*:
 2. Consider the following recursively defined data structure. Translate this type into an algebraic equation relating `List<A>` to `A`.
 */
indirect enum List<A> {
  case empty
  case cons(A, List<A>)
}
// TODO
// List<A> = 1 + (A × List<A>)
// empty has no value = 1 possible Void
// cons(A, List<A>) = A * List<A>
// List<A> = A + (A * List<A>)

//A^0 = empty list (length 0)
//A^1 = list of 1 element
//A^2 = list of 2 elements
//A^N = list of N elements


//Concept  Algebraic View
//List<A> (recursive) ---- 1 + A * List<A>
//Empty list ---- 1
//Non-empty list ---- A * List<A>
//All lists ---- List<A> = A^0 + A^1 + A^2 + ...
//Infinite sum  Represents all finite-length lists
/*:
 3. Is `Optional<Either<A, B>>` equivalent to `Either<Optional<A>, Optional<B>>`? If not, what additional values does one type have that the other doesn’t?
 */
// No, it's not the same
//One side has more value than other side

//Optional<T> = T + 1 -> either some(T) or none
// Either<A, B> = A + B

//Optional<Either<A, B>> = (A + B) + 1

//Either<Optional<A>, Optional<B>> == (A + 1) + (B + 1) = A + B + 2
/*:
 4. Is `Either<Optional<A>, B>` equivalent to `Optional<Either<A, B>>`?
 */
// Optional<T> = T + 1
// Either<A, B> = A + B

//Either<Optinal<A>, B> =  (A + B) + 1
//Optianl<Either<A, B>> = (A + B) + 1
/*:
 5. Swift allows you to pass types, like `A.self`, to functions that take arguments of `A.Type`. Overload the `*` and `+` infix operators with functions that take any type and build up an algebraic representation using `Pair` and `Either`. Explore how the precedence rules of both operators manifest themselves in the resulting types.
 */
struct Pair<A, B> {
  let first: A.Type
  let second: B.Type
}

enum Either<A, B> {
  case left(A.Type)
  case right(B.Type)
}

infix operator .+ : AdditionPrecedence
infix operator .* : MultiplicationPrecedence

func .+<A, B>(lhs: A.Type, rhs: B.Type) -> Pair<A, B> {
  return Pair(first: lhs, second: rhs)
}

func .*<A, B>(lhs: Pair<A, B>, rhs: B.Type) -> Either<A, B> {
  return .right(rhs)
}


