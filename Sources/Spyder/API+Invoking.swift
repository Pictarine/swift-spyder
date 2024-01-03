import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: API invoking functions

extension API {
  public func invokeAndForget(request: URLRequestBuilder) async throws {
    let urlRequest = try request.urlRequest(for: self)
    try await invokeWithCacheCheck(urlRequest)
  }

  public func invokeWaitingResponse<Output: Response>(request: URLRequestBuilder) async throws -> Output {
    let urlRequest = try request.urlRequest(for: self)
    let responseData = try await invokeWithCacheCheck(urlRequest)
    return try decodeResponseData(responseData, from: urlRequest)
  }
}

extension API {
  @discardableResult
  private func invokeWithCacheCheck(_ urlRequest: URLRequest) async throws -> Data {
    let cachedResponseData = cacheManager.findNonExpiredEntry(for: urlRequest)
    logInvoke(for: urlRequest, isCached: cachedResponseData != nil)
    guard let cachedResponseData else {
      let response = try await invokeUsingInvoker(urlRequest)
      cacheManager.registerEntryIfNeeded(response.data, for: urlRequest)
      return response.data
    }
    return cachedResponseData
  }

  private func invokeUsingInvoker(_ urlRequest: URLRequest) async throws -> HTTPResponse {
    do {
      var response = try await invoker(urlRequest)
      logResponse(for: urlRequest, response: response)
      for middleware in responseMiddlewares {
        response = try await middleware(self, response)
      }
      if (200...299).contains(response.statusCode) == false {
        throw API.Error.invalidStatusCodeInResponse(response: response)
      }
      return response
    } catch {
      logInvocationFailure(for: urlRequest, error: error)
      throw error
    }
  }

  private func decodeResponseData<Output: Response>(_ data: Data, from urlRequest: URLRequest) throws -> Output {
    do {
      return try jsonDecoder.decode(Output.self, from: data)
    } catch {
      logDecodingError(for: urlRequest, error: error)
      throw error
    }
  }
}

// MARK: Invokers

public enum Invoker {
  public static let defaultHTTPInvoker: API.Invoker = { request in
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw Invoker.DefaultHTTPInvokerError.missingHTTPResponse
    }
    return .init(
      statusCode: httpResponse.statusCode,
      headers: httpResponse.allHeaderFields.compactMap { element in
        guard
          let stringKey = element.key as? String,
          let value = element.value as? String
        else { return .none }
        return .init(name: stringKey, value: value)
      },
      data: data
    )
  }
}

extension Invoker {
  enum DefaultHTTPInvokerError: Swift.Error {
    case missingHTTPResponse
  }
}
