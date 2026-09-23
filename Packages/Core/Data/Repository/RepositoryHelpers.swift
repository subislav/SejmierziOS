import Foundation
import Domain

func performSafeCall<T: Sendable>(_ block: () async throws -> T) async -> DomainResult<T> {
    do {
        let result = try await block()
        return .success(result)
    } catch let error as ApiHttpError {
        return .failure(.http(code: error.code, message: error.message))
    } catch let error as DecodingError {
        return .failure(.serialization(cause: error.localizedDescription))
    } catch let error as URLError {
        return .failure(.network(cause: error.localizedDescription))
    } catch is CancellationError {

        return .failure(.network(cause: "Cancelled"))
    } catch {
        return .failure(.unknown(cause: error.localizedDescription))
    }
}

extension Result where Failure == DomainError {
    func emptyAsNotCached<Item>(offset: Int) -> DomainResult<Page<Item>> where Success == Page<Item> {
        if case .success(let page) = self, page.items.isEmpty, offset == 0 {
            return .failure(.notCached)
        }
        return self as! DomainResult<Page<Item>>
    }
}
