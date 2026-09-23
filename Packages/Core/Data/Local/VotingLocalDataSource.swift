import Foundation
import GRDB
import Domain

public struct VotingLocalDataSource: Sendable {
    private let dbWriter: DatabaseWriter
    private let benchmark: Benchmark

    public init(dbWriter: DatabaseWriter, benchmark: Benchmark) {
        self.dbWriter = dbWriter
        self.benchmark = benchmark
    }

    public func readPage(term: Int, offset: Int, limit: Int) async throws -> [Voting] {
        return try await benchmark.measured(
            category: .db,
            name: "db.read.page",
            tags: [MetricTag.slice: "Votings"]
        ) {
            try await dbWriter.read { db in
                let entities = try VotingEntity
                    .filter(Column("term") == term)
                    .limit(limit, offset: offset)
                    .fetchAll(db)
                return entities.map { $0.toDomain() }
            }
        }
    }

    public func readById(term: Int, sitting: Int, votingNumber: Int) async throws -> Voting? {
        return try await benchmark.measured(
            category: .db,
            name: "db.read.byId",
            tags: [MetricTag.slice: "Votings"]
        ) {
            try await dbWriter.read { db in
                let entity = try VotingEntity
                    .filter(Column("term") == term && Column("sitting") == sitting && Column("votingNumber") == votingNumber)
                    .fetchOne(db)
                return entity?.toDomain()
            }
        }
    }

    public func upsertAll(term: Int, votings: [Voting]) async throws {
        try await benchmark.measured(
            category: .db,
            name: "db.bulkInsert",
            tags: [
                MetricTag.slice: "Votings",
                "rows": "\(votings.count)"
            ]
        ) {
            try await dbWriter.write { db in
                for voting in votings {
                    let entity = VotingEntity(term: term, voting: voting)
                    try entity.save(db)
                }
            }
        }
    }
}
