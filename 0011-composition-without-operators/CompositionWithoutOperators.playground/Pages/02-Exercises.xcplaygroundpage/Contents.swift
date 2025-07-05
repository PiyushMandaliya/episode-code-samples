/*:
 # Composition without Operators

 1. Write concat for functions (inout A) -> Void.
 */
func concat<A>(_ fs: ((inout A) -> Void)...) -> (inout A) -> Void {
  return { a in
    for f in fs {
      f(&a)
    }
  }
}

/*:
 2. Write concat for functions (A) -> A.
 */
func concat<A>(_ f: ((A) -> A)...) -> (A) -> A {
  return { a in
    f.reduce(a) { value, f in
      f(value)
    }
  }
}
/*:
 3. Write compose for backward composition. Recreate some of the examples from our functional setters episodes (part 1 and part 2) using compose and pipe.
 */
func compose<A, B, C>(_ f: @escaping (B) -> C, _ g: @escaping (A) -> B) -> (A) -> C {
  return { a in
    f(g(a))
  }
}

func pipe<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
  return { a in
    g(f(a))
  }
}
