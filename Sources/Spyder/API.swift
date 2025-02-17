import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class API<ConstrainedType> {
  public typealias Body = Sendable & Encodable
  public typealias HeadersBuilder = () -> Set<Header>
  public typealias Invoker = (URLRequest) async throws -> HTTPResponse
  public typealias Logger = (_ message: String, _ complementaryMessage: String) -> Void
  public typealias Response = Sendable & Decodable
  public typealias ResponseMiddleware = (API, HTTPResponse) async throws -> HTTPResponse

  let baseURLComponents: URLComponents
  public let jsonEncoder: JSONEncoder
  public let jsonDecoder: JSONDecoder
  let headersBuilder: HeadersBuilder
  var persistentHeaders: Set<Header>
  let invoker: Invoker
  let logger: Logger
  let responseMiddlewares: [ResponseMiddleware]
  var cacheManager: CacheManager

  public init(
    baseURLComponents: @escaping (inout URLComponents) -> Void,
    jsonEncoder: JSONEncoder = .init(),
    jsonDecoder: JSONDecoder = .init(),
    headersBuilder: @escaping HeadersBuilder = { .init() },
    persistentHeaders: Set<Header> = [],
    invoker: @escaping Invoker,
    logger: @escaping Logger = { _, _ in },
    responseMiddlewares: [ResponseMiddleware] = [],
    cachePolicy: CachePolicy = .none
  ) {
    var urlComponents = URLComponents()
    baseURLComponents(&urlComponents)
    self.baseURLComponents = urlComponents
    self.jsonEncoder = jsonEncoder
    self.jsonDecoder = jsonDecoder
    self.headersBuilder = headersBuilder
    self.persistentHeaders = persistentHeaders
    self.invoker = invoker
    self.logger = logger
    self.responseMiddlewares = responseMiddlewares
    self.cacheManager = .init(policy: cachePolicy)
  }
}
