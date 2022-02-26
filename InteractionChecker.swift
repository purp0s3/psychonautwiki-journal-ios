import Foundation

enum InteractionChecker {

    static func getUnsafeIngestions(
        of substance: Substance,
        with previousIngestions: [Ingestion]
    ) -> [Ingestion] {
        previousIngestions.filter { ingestion in
            substance.unsafeSubstanceInteractionsUnwrapped.contains { unsafeSubstance in
                unsafeSubstance.name == ingestion.substanceName
            }
        }
    }

    static func getDangerousIngestions(
        of substance: Substance,
        with previousIngestions: [Ingestion]
    ) -> [Ingestion] {
        previousIngestions.filter { ingestion in
            substance.dangerousSubstanceInteractionsUnwrapped.contains { dangerousSubstance in
                dangerousSubstance.name == ingestion.substanceName
            }
        }
    }
}
