import Foundation
import Domain

extension MpDto {
    func toDomain() -> Mp {
        let fullName = [firstName, lastName]
            .compactMap { $0 }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Mp(
            id: id,
            firstLastName: (firstLastName == nil || firstLastName!.isEmpty) ? fullName : firstLastName!,
            club: club,
            active: active ?? false,
            districtName: districtName,
            districtNum: districtNum,
            voivodeship: voivodeship,
            profession: profession,
            educationLevel: educationLevel,
            email: email,
            numberOfVotes: numberOfVotes,
            birthDate: birthDate,
            birthLocation: birthLocation
        )
    }
}

extension MpEntity {
    func toDomain() -> Mp {
        return Mp(
            id: id,
            firstLastName: firstLastName,
            club: club,
            active: active,
            districtName: districtName,
            districtNum: districtNum,
            voivodeship: voivodeship,
            profession: profession,
            educationLevel: educationLevel,
            email: email,
            numberOfVotes: numberOfVotes,
            birthDate: birthDate,
            birthLocation: birthLocation
        )
    }
}
