import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    let container: NSPersistentContainer
    // use viewContext to view objects and edit visible objects
    let viewContext: NSManagedObjectContext
    // use backgroundContext to parse new file and delete old one
    private let backgroundContext: NSManagedObjectContext
    static let hasBeenSetupBeforeKey = "hasBeenSetupBefore"
    static let isEyeOpenKey = "isEyeOpen"
    static let needsToUpdateWatchFaceKey = "needsToUpdateWatchFace"
    static let hasCleanedUpCoreDataKey = "hasCleanedUpCoreData"

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Main", managedObjectModel: Self.model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
        viewContext = container.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext = container.newBackgroundContext()
    }

    func createPreviewHelper() -> PreviewHelper {
        PreviewHelper(context: container.viewContext)
    }

    func findSubstance(with name: String) -> Substance? {
        let fetchRequest: NSFetchRequest<SubstancesFile> = SubstancesFile.fetchRequest()
        guard let file = try? container.viewContext.fetch(fetchRequest).first else {return nil}
        return file.getSubstance(with: name)
    }

    func findGeneralInteraction(with name: String) -> GeneralInteraction? {
        let fetchRequest: NSFetchRequest<SubstancesFile> = SubstancesFile.fetchRequest()
        guard let file = try? container.viewContext.fetch(fetchRequest).first else {return nil}
        return file.getGeneralInteraction(with: name)
    }

    func getLatestExperience() -> Experience? {
        let fetchRequest: NSFetchRequest<Experience> = Experience.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
        guard let experiences = try? container.viewContext.fetch(fetchRequest) else {return nil}
        return experiences.first
    }

    func getOrCreateLatestExperience() -> Experience? {
        if let resultExperience = getLatestExperience() {
            if !resultExperience.isOver {
                return resultExperience
            } else {
                return createNewExperienceNow()
            }
        } else {
            return createNewExperienceNow()
        }
    }

    func getOrCreateLatestExperienceWithoutSave() -> Experience {
        if let resultExperience = getLatestExperience() {
            if !resultExperience.isOver {
                return resultExperience
            } else {
                return createNewExperienceNowWithoutSave()
            }
        } else {
            return createNewExperienceNowWithoutSave()
        }
    }

    func getCurrentFile() -> SubstancesFile? {
        let fetchRequest: NSFetchRequest<SubstancesFile> = SubstancesFile.fetchRequest()
        guard let file = try? viewContext.fetch(fetchRequest).first else {return nil}
        return file

    }

    func createNewExperienceNow() -> Experience? {
        var result: Experience?
        viewContext.performAndWait {
            let experience = Experience(context: viewContext)
            let now = Date()
            experience.creationDate = now
            experience.title = now.asDateString
            try? viewContext.save()
            result = experience
        }

        return result
    }

    func createNewExperienceNowWithoutSave() -> Experience {
        let experience = Experience(context: viewContext)
        let now = Date()
        experience.creationDate = now
        experience.title = now.asDateString

        return experience
    }

    func updateIngestion(
        ingestionToUpdate: Ingestion,
        time: Date,
        route: Roa.AdministrationRoute,
        color: Ingestion.IngestionColor,
        dose: Double
    ) {
        viewContext.perform {
            ingestionToUpdate.time = time
            ingestionToUpdate.administrationRoute = route.rawValue
            ingestionToUpdate.color = color.rawValue
            ingestionToUpdate.dose = dose

            try? viewContext.save()
        }
    }

    func delete(ingestion: Ingestion) {
        viewContext.perform {
            viewContext.delete(ingestion)

            try? viewContext.save()
        }
    }

    // swiftlint:disable function_parameter_count
    func createIngestionWithoutSave(
        context: NSManagedObjectContext,
        identifier: UUID,
        addTo experience: Experience,
        substance: Substance,
        ingestionTime: Date,
        ingestionRoute: Roa.AdministrationRoute,
        color: Ingestion.IngestionColor,
        dose: Double
    ) {
        let ingestion = Ingestion(context: context)
        ingestion.identifier = identifier
        ingestion.experience = experience
        ingestion.time = ingestionTime
        ingestion.administrationRoute = ingestionRoute.rawValue
        ingestion.color = color.rawValue
        ingestion.dose = dose
        ingestion.substanceCopy = SubstanceCopy(basedOn: substance, context: context)
        substance.lastUsedDate = Date()
    }

    func addInitialSubstances() {
        let fileName = "InitialSubstances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(fileName) from bundle.")
        }

        viewContext.perform {
            do {
                let dateString = "2021/09/26 15:00"
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let creationDate = formatter.date(from: dateString)!

                let substancesFile = try decodeSubstancesFile(from: data, with: viewContext)
                substancesFile.creationDate = creationDate
                substancesFile.enableUncontrolledSubstances()
                substancesFile.generalInteractionsUnwrapped.forEach({$0.isEnabled = false})

                try viewContext.save()
            } catch {
                fatalError("Failed to decode \(fileName) from bundle: \(error.localizedDescription)")
            }
        }
    }

    enum DecodingFileError: Error {
        case failedToSave
    }

    func decodeAndSaveFile(from data: Data) throws {
        var didSaveSubstances = false
        backgroundContext.performAndWait {
            let fetchRequest: NSFetchRequest<SubstancesFile> = SubstancesFile.fetchRequest()
            let earlierFileToDelete = try? backgroundContext.fetch(fetchRequest).first
            do {
                let substancesFile = try decodeSubstancesFile(from: data, with: backgroundContext)
                substancesFile.creationDate = Date()
                if let fileToDelete = earlierFileToDelete {
                    substancesFile.inheritFrom(otherfile: fileToDelete)
                    backgroundContext.delete(fileToDelete)
                }
                do {
                    try backgroundContext.save()
                    didSaveSubstances = true
                } catch {
                    backgroundContext.rollback()
                    return
                }
            } catch {
                backgroundContext.rollback()
            }
        }
        if !didSaveSubstances {
            throw DecodingFileError.failedToSave
        }
    }

    func cleanupCoreData() {
        deleteSubstancesWithoutCategory()
        deleteRoasWithoutSubstancesOrSubstanceCopies()
        deleteDoseTypesWithoutRoas()
        deleteDurationTypesWithoutRoas()
        deleteDoseRangeWithoutDoseType()
        deleteDurationRangeWithoutDurationType()
    }

    private func deleteSubstancesWithoutCategory() {
        backgroundContext.performAndWait {
            let fetchRequest: NSFetchRequest<Substance> = Substance.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "category == nil")
            fetchRequest.includesPropertyValues = false
            let substances = (try? backgroundContext.fetch(fetchRequest)) ?? []
            for substance in substances {
                backgroundContext.delete(substance)
            }
            if backgroundContext.hasChanges {
                try? backgroundContext.save()
            }
        }
    }

    private func deleteRoasWithoutSubstancesOrSubstanceCopies() {
        backgroundContext.performAndWait {
            let fetchRequest: NSFetchRequest<Roa> = Roa.fetchRequest()
            let pred1 = NSPredicate(format: "substance == nil")
            let pred2 = NSPredicate(format: "substanceCopy == nil")
            let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [pred1, pred2])
            fetchRequest.predicate = compound
            fetchRequest.includesPropertyValues = false
            let roas = (try? backgroundContext.fetch(fetchRequest)) ?? []
            for roa in roas {
                backgroundContext.delete(roa)
            }
            if backgroundContext.hasChanges {
                try? backgroundContext.save()
            }
        }
    }

    private func deleteDoseTypesWithoutRoas() {
        backgroundContext.performAndWait {
            let fetchRequest: NSFetchRequest<DoseTypes> = DoseTypes.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "substanceRoa == nil")
            fetchRequest.includesPropertyValues = false
            let doseTypes = (try? backgroundContext.fetch(fetchRequest)) ?? []
            for doseT in doseTypes {
                backgroundContext.delete(doseT)
            }
            if backgroundContext.hasChanges {
                try? backgroundContext.save()
            }
        }
    }

    private func deleteDurationTypesWithoutRoas() {
        backgroundContext.performAndWait {
            let fetchRequest: NSFetchRequest<DurationTypes> = DurationTypes.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "substanceRoa == nil")
            fetchRequest.includesPropertyValues = false
            let durationTypes = (try? backgroundContext.fetch(fetchRequest)) ?? []
            for durationT in durationTypes {
                backgroundContext.delete(durationT)
            }
            if backgroundContext.hasChanges {
                try? backgroundContext.save()
            }
        }
    }

    private func deleteDoseRangeWithoutDoseType() {
        backgroundContext.performAndWait {
            let fetchRequest: NSFetchRequest<DoseRange> = DoseRange.fetchRequest()
            let pred1 = NSPredicate(format: "lightDoseType == nil")
            let pred2 = NSPredicate(format: "commonDoseType == nil")
            let pred3 = NSPredicate(format: "strongDoseType == nil")
            let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [pred1, pred2, pred3])
            fetchRequest.predicate = compound
            fetchRequest.includesPropertyValues = false
            let doseRanges = (try? backgroundContext.fetch(fetchRequest)) ?? []
            for doseR in doseRanges {
                backgroundContext.delete(doseR)
            }
            if backgroundContext.hasChanges {
                try? backgroundContext.save()
            }
        }
    }

    private func deleteDurationRangeWithoutDurationType() {
        backgroundContext.performAndWait {
            let fetchRequest: NSFetchRequest<DoseRange> = DoseRange.fetchRequest()
            let pred1 = NSPredicate(format: "onsetType == nil")
            let pred2 = NSPredicate(format: "comeupType == nil")
            let pred3 = NSPredicate(format: "peakType == nil")
            let pred4 = NSPredicate(format: "offsetType == nil")
            let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [pred1, pred2, pred3, pred4])
            fetchRequest.predicate = compound
            fetchRequest.includesPropertyValues = false
            let durationRanges = (try? backgroundContext.fetch(fetchRequest)) ?? []
            for durationR in durationRanges {
                backgroundContext.delete(durationR)
            }
            if backgroundContext.hasChanges {
                try? backgroundContext.save()
            }
        }
    }

    func toggleEye(to isOpen: Bool, modifyFile: SubstancesFile) {
        viewContext.perform {
            if isOpen {
                modifyFile.toggleAllOn()
            } else {
                modifyFile.toggleAllControlledOff()
            }
            if viewContext.hasChanges {
                try? viewContext.save()
            }
        }
    }

}
