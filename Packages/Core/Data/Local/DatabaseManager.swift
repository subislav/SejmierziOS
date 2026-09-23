import Foundation
import GRDB

public struct DatabaseManager: Sendable {
    public let writer: DatabaseWriter

    public init(databaseURL: URL) throws {
        let dbPool = try DatabasePool(path: databaseURL.path)

        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1") { db in

            try db.create(table: "mpEntity") { t in
                t.column("term", .integer).notNull()
                t.column("id", .integer).notNull()
                t.column("firstLastName", .text).notNull()
                t.column("club", .text)
                t.column("active", .boolean).notNull()
                t.column("districtName", .text)
                t.column("districtNum", .integer)
                t.column("voivodeship", .text)
                t.column("profession", .text)
                t.column("educationLevel", .text)
                t.column("email", .text)
                t.column("numberOfVotes", .integer)
                t.column("birthDate", .text)
                t.column("birthLocation", .text)

                t.primaryKey(["term", "id"])
            }
            try db.execute(sql: "CREATE INDEX mpEntity_term ON mpEntity(term)")

            try db.create(table: "clubEntity") { t in
                t.column("term", .integer).notNull()
                t.column("id", .text).notNull()
                t.column("name", .text).notNull()
                t.column("membersCount", .integer).notNull()
                t.column("email", .text)
                t.column("phone", .text)
                t.column("fax", .text)

                t.primaryKey(["term", "id"])
            }
            try db.execute(sql: "CREATE INDEX clubEntity_term ON clubEntity(term)")

            try db.create(table: "votingEntity") { t in
                t.column("term", .integer).notNull()
                t.column("sitting", .integer).notNull()
                t.column("votingNumber", .integer).notNull()
                t.column("sittingDay", .integer)
                t.column("date", .text)
                t.column("title", .text)
                t.column("topic", .text)
                t.column("description", .text)
                t.column("kind", .text)
                t.column("majorityType", .text)
                t.column("yes", .integer).notNull()
                t.column("no", .integer).notNull()
                t.column("abstain", .integer).notNull()
                t.column("notParticipating", .integer).notNull()
                t.column("totalVoted", .integer).notNull()

                t.primaryKey(["term", "sitting", "votingNumber"])
            }
            try db.execute(sql: "CREATE INDEX votingEntity_term ON votingEntity(term)")
        }

        try migrator.migrate(dbPool)
        self.writer = dbPool
    }
}
