@propertyWrapper
public struct RequestHeader: Sendable {
  let name: String
  public var wrappedValue = ""

  public init(name: String) {
    self.name = name
  }
}

@propertyWrapper
public struct PathArgument: Sendable {
  let name: String
  public var wrappedValue = ""

  public init(name: String) {
    self.name = name
  }
}

@propertyWrapper
public struct QueryArgument: Sendable {
  let name: String
  public var wrappedValue = ""

  public init(name: String) {
    self.name = name
  }
}

@propertyWrapper
public struct OptionalQueryArgument: Sendable {
  let name: String
  public var wrappedValue: String? = .none

  public init(name: String) {
    self.name = name
  }
}

@propertyWrapper
public struct Body: Sendable {
  public var wrappedValue: API.Body

  public init(wrappedValue: API.Body) {
    self.wrappedValue = wrappedValue
  }
}
