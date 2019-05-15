//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import GRDBCipher
import SignalCoreKit

// NOTE: This file is generated by /Scripts/sds_codegen/sds_generate.py.
// Do not manually edit it, instead run `sds_codegen.sh`.

// MARK: - Record

public struct LinkedDeviceReadReceiptRecord: Codable, FetchableRecord, PersistableRecord, TableRecord {
    public static let databaseTableName: String = OWSLinkedDeviceReadReceiptSerializer.table.tableName

    public let id: UInt64

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    public let recordType: SDSRecordType
    public let uniqueId: String

    // Base class properties
    public let messageIdTimestamp: UInt64
    public let readTimestamp: UInt64
    public let senderId: String

    public enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case recordType
        case uniqueId
        case messageIdTimestamp
        case readTimestamp
        case senderId
    }

    public static func columnName(_ column: LinkedDeviceReadReceiptRecord.CodingKeys, fullyQualified: Bool = false) -> String {
        return fullyQualified ? "\(databaseTableName).\(column.rawValue)" : column.rawValue
    }

}

// MARK: - StringInterpolation

public extension String.StringInterpolation {
    mutating func appendInterpolation(linkedDeviceReadReceiptColumn column: LinkedDeviceReadReceiptRecord.CodingKeys) {
        appendLiteral(LinkedDeviceReadReceiptRecord.columnName(column))
    }
    mutating func appendInterpolation(linkedDeviceReadReceiptColumnFullyQualified column: LinkedDeviceReadReceiptRecord.CodingKeys) {
        appendLiteral(LinkedDeviceReadReceiptRecord.columnName(column, fullyQualified: true))
    }
}

// MARK: - Deserialization

// TODO: Remove the other Deserialization extension.
// TODO: SDSDeserializer.
// TODO: Rework metadata to not include, for example, columns, column indices.
extension OWSLinkedDeviceReadReceipt {
    // This method defines how to deserialize a model, given a
    // database row.  The recordType column is used to determine
    // the corresponding model class.
    class func fromRecord(_ record: LinkedDeviceReadReceiptRecord) throws -> OWSLinkedDeviceReadReceipt {

        switch record.recordType {
        case .linkedDeviceReadReceipt:

            let uniqueId: String = record.uniqueId
            let messageIdTimestamp: UInt64 = record.messageIdTimestamp
            let readTimestamp: UInt64 = record.readTimestamp
            let senderId: String = record.senderId

            return OWSLinkedDeviceReadReceipt(uniqueId: uniqueId,
                                              messageIdTimestamp: messageIdTimestamp,
                                              readTimestamp: readTimestamp,
                                              senderId: senderId)

        default:
            owsFailDebug("Unexpected record type: \(record.recordType)")
            throw SDSError.invalidValue
        }
    }
}

// MARK: - SDSSerializable

extension OWSLinkedDeviceReadReceipt: SDSSerializable {
    public var serializer: SDSSerializer {
        // Any subclass can be cast to it's superclass,
        // so the order of this switch statement matters.
        // We need to do a "depth first" search by type.
        switch self {
        default:
            return OWSLinkedDeviceReadReceiptSerializer(model: self)
        }
    }
}

// MARK: - Table Metadata

extension OWSLinkedDeviceReadReceiptSerializer {

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    static let recordTypeColumn = SDSColumnMetadata(columnName: "recordType", columnType: .int, columnIndex: 0)
    static let idColumn = SDSColumnMetadata(columnName: "id", columnType: .primaryKey, columnIndex: 1)
    static let uniqueIdColumn = SDSColumnMetadata(columnName: "uniqueId", columnType: .unicodeString, columnIndex: 2)
    // Base class properties
    static let messageIdTimestampColumn = SDSColumnMetadata(columnName: "messageIdTimestamp", columnType: .int64, columnIndex: 3)
    static let readTimestampColumn = SDSColumnMetadata(columnName: "readTimestamp", columnType: .int64, columnIndex: 4)
    static let senderIdColumn = SDSColumnMetadata(columnName: "senderId", columnType: .unicodeString, columnIndex: 5)

    // TODO: We should decide on a naming convention for
    //       tables that store models.
    public static let table = SDSTableMetadata(tableName: "model_OWSLinkedDeviceReadReceipt", columns: [
        recordTypeColumn,
        idColumn,
        uniqueIdColumn,
        messageIdTimestampColumn,
        readTimestampColumn,
        senderIdColumn
        ])

}

// MARK: - Deserialization

extension OWSLinkedDeviceReadReceiptSerializer {
    // This method defines how to deserialize a model, given a
    // database row.  The recordType column is used to determine
    // the corresponding model class.
    class func sdsDeserialize(statement: SelectStatement) throws -> OWSLinkedDeviceReadReceipt {

        if OWSIsDebugBuild() {
            guard statement.columnNames == table.selectColumnNames else {
                owsFailDebug("Unexpected columns: \(statement.columnNames) != \(table.selectColumnNames)")
                throw SDSError.invalidResult
            }
        }

        // SDSDeserializer is used to convert column values into Swift values.
        let deserializer = SDSDeserializer(sqliteStatement: statement.sqliteStatement)
        let recordTypeValue = try deserializer.int(at: 0)
        guard let recordType = SDSRecordType(rawValue: UInt(recordTypeValue)) else {
            owsFailDebug("Invalid recordType: \(recordTypeValue)")
            throw SDSError.invalidResult
        }
        switch recordType {
        case .linkedDeviceReadReceipt:

            let uniqueId = try deserializer.string(at: uniqueIdColumn.columnIndex)
            let messageIdTimestamp = try deserializer.uint64(at: messageIdTimestampColumn.columnIndex)
            let readTimestamp = try deserializer.uint64(at: readTimestampColumn.columnIndex)
            let senderId = try deserializer.string(at: senderIdColumn.columnIndex)

            return OWSLinkedDeviceReadReceipt(uniqueId: uniqueId,
                                              messageIdTimestamp: messageIdTimestamp,
                                              readTimestamp: readTimestamp,
                                              senderId: senderId)

        default:
            owsFail("Invalid record type \(recordType)")
        }
    }
}

// MARK: - Save/Remove/Update

@objc
extension OWSLinkedDeviceReadReceipt {
    public func anySave(transaction: SDSAnyWriteTransaction) {
        switch transaction.writeTransaction {
        case .yapWrite(let ydbTransaction):
            save(with: ydbTransaction)
        case .grdbWrite(let grdbTransaction):
            SDSSerialization.save(entity: self, transaction: grdbTransaction)
        }
    }

    // This method is used by "updateWith..." methods.
    //
    // This model may be updated from many threads. We don't want to save
    // our local copy (this instance) since it may be out of date.  We also
    // want to avoid re-saving a model that has been deleted.  Therefore, we
    // use "updateWith..." methods to:
    //
    // a) Update a property of this instance.
    // b) If a copy of this model exists in the database, load an up-to-date copy,
    //    and update and save that copy.
    // b) If a copy of this model _DOES NOT_ exist in the database, do _NOT_ save
    //    this local instance.
    //
    // After "updateWith...":
    //
    // a) Any copy of this model in the database will have been updated.
    // b) The local property on this instance will always have been updated.
    // c) Other properties on this instance may be out of date.
    //
    // All mutable properties of this class have been made read-only to
    // prevent accidentally modifying them directly.
    //
    // This isn't a perfect arrangement, but in practice this will prevent
    // data loss and will resolve all known issues.
    public func anyUpdateWith(transaction: SDSAnyWriteTransaction, block: (OWSLinkedDeviceReadReceipt) -> Void) {
        guard let uniqueId = uniqueId else {
            owsFailDebug("Missing uniqueId.")
            return
        }

        guard let dbCopy = type(of: self).anyFetch(uniqueId: uniqueId,
                                                   transaction: transaction) else {
            return
        }

        block(self)
        block(dbCopy)

        dbCopy.anySave(transaction: transaction)
    }

    public func anyRemove(transaction: SDSAnyWriteTransaction) {
        switch transaction.writeTransaction {
        case .yapWrite(let ydbTransaction):
            remove(with: ydbTransaction)
        case .grdbWrite(let grdbTransaction):
            SDSSerialization.delete(entity: self, transaction: grdbTransaction)
        }
    }
}

// MARK: - OWSLinkedDeviceReadReceiptCursor

@objc
public class OWSLinkedDeviceReadReceiptCursor: NSObject {
    private let cursor: RecordCursor<LinkedDeviceReadReceiptRecord>?

    init(cursor: RecordCursor<LinkedDeviceReadReceiptRecord>?) {
        self.cursor = cursor
    }

    public func next() throws -> OWSLinkedDeviceReadReceipt? {
        guard let cursor = cursor else {
            return nil
        }
        guard let record = try cursor.next() else {
            return nil
        }
        return try OWSLinkedDeviceReadReceipt.fromRecord(record)
    }

    public func all() throws -> [OWSLinkedDeviceReadReceipt] {
        var result = [OWSLinkedDeviceReadReceipt]()
        while true {
            guard let model = try next() else {
                break
            }
            result.append(model)
        }
        return result
    }
}

// MARK: - Obj-C Fetch

// TODO: We may eventually want to define some combination of:
//
// * fetchCursor, fetchOne, fetchAll, etc. (ala GRDB)
// * Optional "where clause" parameters for filtering.
// * Async flavors with completions.
//
// TODO: I've defined flavors that take a read transaction.
//       Or we might take a "connection" if we end up having that class.
@objc
extension OWSLinkedDeviceReadReceipt {
    public class func grdbFetchCursor(transaction: GRDBReadTransaction) -> OWSLinkedDeviceReadReceiptCursor {
        let database = transaction.database
        do {
            let cursor = try LinkedDeviceReadReceiptRecord.fetchCursor(database)
            return OWSLinkedDeviceReadReceiptCursor(cursor: cursor)
        } catch {
            owsFailDebug("Read failed: \(error)")
            return OWSLinkedDeviceReadReceiptCursor(cursor: nil)
        }
    }

    // Fetches a single model by "unique id".
    public class func anyFetch(uniqueId: String,
                               transaction: SDSAnyReadTransaction) -> OWSLinkedDeviceReadReceipt? {
        assert(uniqueId.count > 0)

        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return OWSLinkedDeviceReadReceipt.fetch(uniqueId: uniqueId, transaction: ydbTransaction)
        case .grdbRead(let grdbTransaction):
            let sql = "SELECT * FROM \(LinkedDeviceReadReceiptRecord.databaseTableName) WHERE \(linkedDeviceReadReceiptColumn: .uniqueId) = ?"
            return grdbFetchOne(sql: sql, arguments: [uniqueId], transaction: grdbTransaction)
        }
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    // Traversal aborts if the visitor returns false.
    public class func anyVisitAll(transaction: SDSAnyReadTransaction, visitor: @escaping (OWSLinkedDeviceReadReceipt) -> Bool) {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            OWSLinkedDeviceReadReceipt.enumerateCollectionObjects(with: ydbTransaction) { (object, stop) in
                guard let value = object as? OWSLinkedDeviceReadReceipt else {
                    owsFailDebug("unexpected object: \(type(of: object))")
                    return
                }
                guard visitor(value) else {
                    stop.pointee = true
                    return
                }
            }
        case .grdbRead(let grdbTransaction):
            do {
                let cursor = OWSLinkedDeviceReadReceipt.grdbFetchCursor(transaction: grdbTransaction)
                while let value = try cursor.next() {
                    guard visitor(value) else {
                        return
                    }
                }
            } catch let error as NSError {
                owsFailDebug("Couldn't fetch models: \(error)")
            }
        }
    }

    // Does not order the results.
    public class func anyFetchAll(transaction: SDSAnyReadTransaction) -> [OWSLinkedDeviceReadReceipt] {
        var result = [OWSLinkedDeviceReadReceipt]()
        anyVisitAll(transaction: transaction) { (model) in
            result.append(model)
            return true
        }
        return result
    }
}

// MARK: - Swift Fetch

extension OWSLinkedDeviceReadReceipt {
    public class func grdbFetchCursor(sql: String,
                                      arguments: [DatabaseValueConvertible]?,
                                      transaction: GRDBReadTransaction) -> OWSLinkedDeviceReadReceiptCursor {
        var statementArguments: StatementArguments?
        if let arguments = arguments {
            guard let statementArgs = StatementArguments(arguments) else {
                owsFailDebug("Could not convert arguments.")
                return OWSLinkedDeviceReadReceiptCursor(cursor: nil)
            }
            statementArguments = statementArgs
        }
        let database = transaction.database
        do {
            let statement: SelectStatement = try database.cachedSelectStatement(sql: sql)
            let cursor = try LinkedDeviceReadReceiptRecord.fetchCursor(statement, arguments: statementArguments)
            return OWSLinkedDeviceReadReceiptCursor(cursor: cursor)
        } catch {
            Logger.error("sql: \(sql)")
            owsFailDebug("Read failed: \(error)")
            return OWSLinkedDeviceReadReceiptCursor(cursor: nil)
        }
    }

    public class func grdbFetchOne(sql: String,
                                   arguments: StatementArguments,
                                   transaction: GRDBReadTransaction) -> OWSLinkedDeviceReadReceipt? {
        assert(sql.count > 0)

        do {
            guard let record = try LinkedDeviceReadReceiptRecord.fetchOne(transaction.database, sql: sql, arguments: arguments) else {
                return nil
            }

            return try OWSLinkedDeviceReadReceipt.fromRecord(record)
        } catch {
            owsFailDebug("error: \(error)")
            return nil
        }
    }
}

// MARK: - SDSSerializer

// The SDSSerializer protocol specifies how to insert and update the
// row that corresponds to this model.
class OWSLinkedDeviceReadReceiptSerializer: SDSSerializer {

    private let model: OWSLinkedDeviceReadReceipt
    public required init(model: OWSLinkedDeviceReadReceipt) {
        self.model = model
    }

    public func serializableColumnTableMetadata() -> SDSTableMetadata {
        return OWSLinkedDeviceReadReceiptSerializer.table
    }

    public func insertColumnNames() -> [String] {
        // When we insert a new row, we include the following columns:
        //
        // * "record type"
        // * "unique id"
        // * ...all columns that we set when updating.
        return [
            OWSLinkedDeviceReadReceiptSerializer.recordTypeColumn.columnName,
            uniqueIdColumnName()
            ] + updateColumnNames()

    }

    public func insertColumnValues() -> [DatabaseValueConvertible] {
        let result: [DatabaseValueConvertible] = [
            SDSRecordType.linkedDeviceReadReceipt.rawValue
            ] + [uniqueIdColumnValue()] + updateColumnValues()
        if OWSIsDebugBuild() {
            if result.count != insertColumnNames().count {
                owsFailDebug("Update mismatch: \(result.count) != \(insertColumnNames().count)")
            }
        }
        return result
    }

    public func updateColumnNames() -> [String] {
        return [
            OWSLinkedDeviceReadReceiptSerializer.messageIdTimestampColumn,
            OWSLinkedDeviceReadReceiptSerializer.readTimestampColumn,
            OWSLinkedDeviceReadReceiptSerializer.senderIdColumn
            ].map { $0.columnName }
    }

    public func updateColumnValues() -> [DatabaseValueConvertible] {
        let result: [DatabaseValueConvertible] = [
            self.model.messageIdTimestamp,
            self.model.readTimestamp,
            self.model.senderId

        ]
        if OWSIsDebugBuild() {
            if result.count != updateColumnNames().count {
                owsFailDebug("Update mismatch: \(result.count) != \(updateColumnNames().count)")
            }
        }
        return result
    }

    public func uniqueIdColumnName() -> String {
        return OWSLinkedDeviceReadReceiptSerializer.uniqueIdColumn.columnName
    }

    // TODO: uniqueId is currently an optional on our models.
    //       We should probably make the return type here String?
    public func uniqueIdColumnValue() -> DatabaseValueConvertible {
        // FIXME remove force unwrap
        return model.uniqueId!
    }
}
