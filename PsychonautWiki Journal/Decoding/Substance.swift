import Foundation
import CoreData

struct Substance: Decodable, Identifiable {
    // swiftlint:disable identifier_name
    var id: String {
        name
    }
    let name: String
    let url: URL
    let commonNames: [String]
    let isApproved: Bool
    let tolerance: Tolerance?
    let crossTolerances: [String]
    let addictionPotential: String?
    let toxicities: [String]
    let categories: [String]
    let interactions: Interactions?
    let roas: [Roa]
    let summary: String?
    let effectsSummary: String?
    let dosageRemark: String?
    let generalRisks: String?
    let longtermRisks: String?
    let saferUse: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case url
        case commonNames
        case isApproved
        case tolerance
        case crossTolerances
        case addictionPotential
        case toxicities
        case categories
        case interactions
        case roas
        case summary
        case effectsSummary
        case dosageRemark
        case generalRisks
        case longtermRisks
        case saferUse
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(URL.self, forKey: .url)
        self.commonNames = try container.decode([String].self, forKey: .commonNames)
        self.isApproved = try container.decode(Bool.self, forKey: .isApproved)
        self.tolerance = try? container.decodeIfPresent(Tolerance.self, forKey: .tolerance)
        self.crossTolerances = (try? container.decodeIfPresent([String].self, forKey: .crossTolerances)) ?? []
        self.addictionPotential = try? container.decodeIfPresent(
            String.self,
            forKey: .addictionPotential
        )
        self.toxicities = (try? container.decodeIfPresent(
            [String].self,
            forKey: .toxicities
        )) ?? []
        self.categories = (try? container.decodeIfPresent(
            [String].self,
            forKey: .categories
        )) ?? []
        self.interactions = try? container.decodeIfPresent(Interactions.self, forKey: .interactions)
        self.roas = (try? container.decodeIfPresent([Roa].self, forKey: .roas)) ?? []
        self.summary = try? container.decodeIfPresent(String.self, forKey: .summary)
        self.effectsSummary = try? container.decodeIfPresent(String.self, forKey: .effectsSummary)
        self.dosageRemark = try? container.decodeIfPresent(String.self, forKey: .dosageRemark)
        self.generalRisks = try? container.decodeIfPresent(String.self, forKey: .generalRisks)
        self.longtermRisks = try? container.decodeIfPresent(String.self, forKey: .longtermRisks)
        self.saferUse = (try? container.decodeIfPresent([String].self, forKey: .saferUse)) ?? []
    }

    var administrationRoutesUnwrapped: [AdministrationRoute] {
        roas.map { roa in
            roa.name
        }
    }

    func getDuration(for administrationRoute: AdministrationRoute) -> RoaDuration? {
        let filteredRoas = roas.filter { roa in
            roa.name == administrationRoute
        }

        guard let duration = filteredRoas.first?.duration else {
            return nil
        }
        return duration
    }

    func getDose(for administrationRoute: AdministrationRoute?) -> RoaDose? {
        guard let administrationRoute = administrationRoute else {
            return nil
        }
        let filteredRoas = roas.filter { roa in
            roa.name == administrationRoute
        }
        guard let dose = filteredRoas.first?.dose else {
            return nil
        }
        return dose
    }
}
