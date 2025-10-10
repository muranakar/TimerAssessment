//
//  DataBackupManager.swift
//  TimerAssessment
//
//  Created by Claude on 2025/10/10.
//

import Foundation
import RealmSwift

// MARK: - Codable Data Models for Backup

struct BackupData: Codable {
    let version: Int
    let createdAt: String
    let assessors: [BackupAssessor]
}

struct BackupAssessor: Codable {
    let uuidString: String
    let name: String
    let targetPersons: [BackupTargetPerson]
}

struct BackupTargetPerson: Codable {
    let uuidString: String
    let name: String
    let assessmentItems: [BackupAssessmentItem]
}

struct BackupAssessmentItem: Codable {
    let uuidString: String
    let name: String
    let timerAssessments: [BackupTimerAssessment]
}

struct BackupTimerAssessment: Codable {
    let uuidString: String
    let resultTimer: Double
    let memo: String?
    let createdAt: String?
    let updatedAt: String?
}

// MARK: - DataBackupManager

final class DataBackupManager {
    private let repository = TimerAssessmentRepository()
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    // MARK: - Export

    func exportData() throws -> Data {
        let assessors = repository.loadAssessor()
        let backupAssessors = assessors.map { createBackupAssessor(from: $0) }

        let backup = BackupData(
            version: 2,
            createdAt: dateFormatter.string(from: Date()),
            assessors: backupAssessors
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(backup)
    }

    private func createBackupAssessor(from assessor: Assessor) -> BackupAssessor {
        let targetPersons = repository.loadTargetPerson(assessor: assessor)
        let backupTargetPersons = targetPersons.map { createBackupTargetPerson(from: $0) }

        return BackupAssessor(
            uuidString: assessor.uuidString,
            name: assessor.name,
            targetPersons: backupTargetPersons
        )
    }

    private func createBackupTargetPerson(from targetPerson: TargetPerson) -> BackupTargetPerson {
        let assessmentItems = repository.loadAssessmentItem(targetPerson: targetPerson)
        let backupAssessmentItems = assessmentItems.map { createBackupAssessmentItem(from: $0) }

        return BackupTargetPerson(
            uuidString: targetPerson.uuidString,
            name: targetPerson.name,
            assessmentItems: backupAssessmentItems
        )
    }

    private func createBackupAssessmentItem(from assessmentItem: AssessmentItem) -> BackupAssessmentItem {
        let timerAssessments = repository.loadTimerAssessment(
            assessmentItem: assessmentItem,
            sortBy: "createdAt",
            ascending: true
        )
        let backupTimerAssessments = timerAssessments.map { createBackupTimerAssessment(from: $0) }

        return BackupAssessmentItem(
            uuidString: assessmentItem.uuidString,
            name: assessmentItem.name,
            timerAssessments: backupTimerAssessments
        )
    }

    private func createBackupTimerAssessment(from timerAssessment: TimerAssessment) -> BackupTimerAssessment {
        return BackupTimerAssessment(
            uuidString: timerAssessment.uuidString,
            resultTimer: timerAssessment.resultTimer,
            memo: timerAssessment.memo,
            createdAt: timerAssessment.createdAt.map { dateFormatter.string(from: $0) },
            updatedAt: timerAssessment.updatedAt.map { dateFormatter.string(from: $0) }
        )
    }

    // MARK: - Import

    func importData(from data: Data, mergeStrategy: MergeStrategy = .skipExisting) throws -> ImportResult {
        let decoder = JSONDecoder()
        let backup = try decoder.decode(BackupData.self, from: data)

        var imported = 0
        var skipped = 0
        var updated = 0

        for backupAssessor in backup.assessors {
            let result = importAssessor(backupAssessor, mergeStrategy: mergeStrategy)
            imported += result.imported
            skipped += result.skipped
            updated += result.updated
        }

        return ImportResult(imported: imported, skipped: skipped, updated: updated)
    }

    private func importAssessor(_ backupAssessor: BackupAssessor, mergeStrategy: MergeStrategy) -> ImportResult {
        var result = ImportResult(imported: 0, skipped: 0, updated: 0)

        let assessor = Assessor(uuidString: backupAssessor.uuidString, name: backupAssessor.name)
        let existingAssessor = repository.loadAssessor(assessor: assessor)

        if existingAssessor == nil {
            repository.apppendAssessor(assesor: assessor)
            result.imported += 1
        } else {
            switch mergeStrategy {
            case .skipExisting:
                result.skipped += 1
            case .overwrite:
                repository.updateAssessor(assessor: assessor)
                result.updated += 1
            }
        }

        // Import target persons
        for backupTargetPerson in backupAssessor.targetPersons {
            let targetPersonResult = importTargetPerson(backupTargetPerson, assessor: assessor, mergeStrategy: mergeStrategy)
            result.imported += targetPersonResult.imported
            result.skipped += targetPersonResult.skipped
            result.updated += targetPersonResult.updated
        }

        return result
    }

    private func importTargetPerson(_ backupTargetPerson: BackupTargetPerson, assessor: Assessor, mergeStrategy: MergeStrategy) -> ImportResult {
        var result = ImportResult(imported: 0, skipped: 0, updated: 0)

        let targetPerson = TargetPerson(uuidString: backupTargetPerson.uuidString, name: backupTargetPerson.name)
        let existingTargetPerson = repository.loadTargetPerson(targetPerson: targetPerson)

        if existingTargetPerson == nil {
            repository.appendTargetPerson(assessor: assessor, targetPerson: targetPerson)
            result.imported += 1
        } else {
            switch mergeStrategy {
            case .skipExisting:
                result.skipped += 1
            case .overwrite:
                repository.updateTargetPerson(targetPerson: targetPerson)
                result.updated += 1
            }
        }

        // Import assessment items
        for backupAssessmentItem in backupTargetPerson.assessmentItems {
            let assessmentItemResult = importAssessmentItem(backupAssessmentItem, targetPerson: targetPerson, mergeStrategy: mergeStrategy)
            result.imported += assessmentItemResult.imported
            result.skipped += assessmentItemResult.skipped
            result.updated += assessmentItemResult.updated
        }

        return result
    }

    private func importAssessmentItem(_ backupAssessmentItem: BackupAssessmentItem, targetPerson: TargetPerson, mergeStrategy: MergeStrategy) -> ImportResult {
        var result = ImportResult(imported: 0, skipped: 0, updated: 0)

        let assessmentItem = AssessmentItem(uuidString: backupAssessmentItem.uuidString, name: backupAssessmentItem.name)
        let existingAssessmentItem = repository.loadAssessmentItem(targetPerson: targetPerson).first(where: { $0.uuidString == assessmentItem.uuidString })

        if existingAssessmentItem == nil {
            repository.appendAssessmentItem(targetPerson: targetPerson, assessmentItem: assessmentItem)
            result.imported += 1
        } else {
            switch mergeStrategy {
            case .skipExisting:
                result.skipped += 1
            case .overwrite:
                repository.updateAssessmentItem(assessmentItem: assessmentItem)
                result.updated += 1
            }
        }

        // Import timer assessments
        for backupTimerAssessment in backupAssessmentItem.timerAssessments {
            let timerAssessmentResult = importTimerAssessment(backupTimerAssessment, assessmentItem: assessmentItem, mergeStrategy: mergeStrategy)
            result.imported += timerAssessmentResult.imported
            result.skipped += timerAssessmentResult.skipped
            result.updated += timerAssessmentResult.updated
        }

        return result
    }

    private func importTimerAssessment(_ backupTimerAssessment: BackupTimerAssessment, assessmentItem: AssessmentItem, mergeStrategy: MergeStrategy) -> ImportResult {
        var result = ImportResult(imported: 0, skipped: 0, updated: 0)

        let createdAt = backupTimerAssessment.createdAt.flatMap { dateFormatter.date(from: $0) }
        let updatedAt = backupTimerAssessment.updatedAt.flatMap { dateFormatter.date(from: $0) }

        var timerAssessment = TimerAssessment(
            uuidString: backupTimerAssessment.uuidString,
            resultTimer: backupTimerAssessment.resultTimer,
            memo: backupTimerAssessment.memo
        )
        timerAssessment.createdAt = createdAt
        timerAssessment.updatedAt = updatedAt

        let existingTimerAssessments = repository.loadTimerAssessment(assessmentItem: assessmentItem, sortBy: "createdAt", ascending: true)
        let exists = existingTimerAssessments.contains(where: { $0.uuidString == timerAssessment.uuidString })

        if !exists {
            repository.appendTimerAssessment(assessmentItem: assessmentItem, timerAssessment: timerAssessment)
            result.imported += 1
        } else {
            switch mergeStrategy {
            case .skipExisting:
                result.skipped += 1
            case .overwrite:
                repository.updateTimerAssessment(timerAssessment: timerAssessment)
                result.updated += 1
            }
        }

        return result
    }

    enum MergeStrategy {
        case skipExisting
        case overwrite
    }

    struct ImportResult {
        var imported: Int
        var skipped: Int
        var updated: Int

        var total: Int {
            imported + skipped + updated
        }
    }
}
