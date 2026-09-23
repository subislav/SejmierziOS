import Foundation
import GRDB
import Domain

public struct MpLocalDataSource: Sendable {
    private let dbWriter: DatabaseWriter
    private let benchmark: Benchmark

    public init(dbWriter: DatabaseWriter, benchmark: Benchmark) {
        self.dbWriter = dbWriter
        self.benchmark = benchmark
    }

    public func readPage(term: Int, offset: Int, limit: Int) async throws -> [Mp] {
        return try await benchmark.measured(
            category: .db,
            name: "db.read.page",
            tags: [MetricTag.slice: "MPs"]
        ) {
            try await dbWriter.read { db in
                let entities = try MpEntity
                    .filter(Column("term") == term)
                    .limit(limit, offset: offset)
                    .fetchAll(db)
                return entities.map { $0.toDomain() }
            }
        }
    }

    public func readById(term: Int, id: Int) async throws -> Mp? {
        return try await benchmark.measured(
            category: .db,
            name: "db.read.byId",
            tags: [MetricTag.slice: "MPs"]
        ) {
            try await dbWriter.read { db in
                let entity = try MpEntity
                    .filter(Column("term") == term && Column("id") == id)
                    .fetchOne(db)
                return entity?.toDomain()
            }
        }
    }

    public func upsertAll(term: Int, mps: [Mp]) async throws {
        try await benchmark.measured(
            category: .db,
            name: "db.bulkInsert",
            tags: [
                MetricTag.slice: "MPs",
                "rows": "\(mps.count)"
            ]
        ) {
            try await dbWriter.write { db in
                for mp in mps {
                    let entity = MpEntity(term: term, mp: mp)
                    try entity.save(db)
                }
            }
        }
    }
}
