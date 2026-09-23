import Foundation
import GRDB
import Domain

public struct ClubLocalDataSource: Sendable {
    private let dbWriter: DatabaseWriter
    private let benchmark: Benchmark

    public init(dbWriter: DatabaseWriter, benchmark: Benchmark) {
        self.dbWriter = dbWriter
        self.benchmark = benchmark
    }

    public func readPage(term: Int, offset: Int, limit: Int) async throws -> [Club] {
        return try await benchmark.measured(
            category: .db,
            name: "db.read.page",
            tags: [MetricTag.slice: "Clubs"]
        ) {
            try await dbWriter.read { db in
                let entities = try ClubEntity
                    .filter(Column("term") == term)
                    .limit(limit, offset: offset)
                    .fetchAll(db)
                return entities.map { $0.toDomain() }
            }
        }
    }

    public func readById(term: Int, id: String) async throws -> Club? {
        return try await benchmark.measured(
            category: .db,
            name: "db.read.byId",
            tags: [MetricTag.slice: "Clubs"]
        ) {
            try await dbWriter.read { db in
                let entity = try ClubEntity
                    .filter(Column("term") == term && Column("id") == id)
                    .fetchOne(db)
                return entity?.toDomain()
            }
        }
    }

    public func upsertAll(term: Int, clubs: [Club]) async throws {
        try await benchmark.measured(
            category: .db,
            name: "db.bulkInsert",
            tags: [
                MetricTag.slice: "Clubs",
                "rows": "\(clubs.count)"
            ]
        ) {
            try await dbWriter.write { db in
                for club in clubs {
                    let entity = ClubEntity(term: term, club: club)
                    try entity.save(db)
                }
            }
        }
    }
}
