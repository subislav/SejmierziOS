import Foundation

public struct Club: Sendable, Equatable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let membersCount: Int
    public let email: String?
    public let phone: String?
    public let fax: String?

    public init(id: String, name: String, membersCount: Int, email: String?, phone: String?, fax: String?) {
        self.id = id
        self.name = name
        self.membersCount = membersCount
        self.email = email
        self.phone = phone
        self.fax = fax
    }

    public func logoUrl(term: Term) -> String {
        return "https://api.sejm.gov.pl/sejm/term\(term.number)/clubs/\(id)/logo"
    }
}
