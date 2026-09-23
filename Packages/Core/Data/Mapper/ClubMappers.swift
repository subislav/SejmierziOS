import Foundation
import Domain

extension ClubDto {
    func toDomain() -> Club {
        return Club(
            id: id,
            name: name,
            membersCount: membersCount,
            email: email?.isEmpty == true ? nil : email,
            phone: phone?.isEmpty == true ? nil : phone,
            fax: fax?.isEmpty == true ? nil : fax
        )
    }

    func toDetailDomain() -> ClubDetail {
        return ClubDetail(
            club: toDomain(),
            members: members?.map { $0.toDomain() } ?? []
        )
    }
}

extension ClubMemberDto {
    func toDomain() -> ClubMember {
        return ClubMember(
            id: id,
            firstName: firstName,
            lastName: lastName,
            function: function
        )
    }
}

extension ClubEntity {
    func toDomain() -> Club {
        return Club(
            id: id,
            name: name,
            membersCount: membersCount,
            email: email,
            phone: phone,
            fax: fax
        )
    }
}
