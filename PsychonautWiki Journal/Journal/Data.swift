//
//  Data.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 30.12.22.
//

import SwiftUI

func date(year: Int, month: Int = 1, day: Int = 1) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
}

struct IngestionCount: Identifiable {
    var id: String {
        substanceName
    }
    let substanceName: String
    let ingestionCount: Int
}

struct IngestionData {
    let last30Days: [IngestionCount]
    let last12Months: [IngestionCount]
    let years: [IngestionCount]
    let colorMapping: (String) -> Color
}

extension IngestionData {
    static let mock1 = IngestionData(
        last30Days: [
            .init(substanceName: "Cannabis", ingestionCount: 15),
            .init(substanceName: "Cocaine", ingestionCount: 8),
            .init(substanceName: "Amphetamine", ingestionCount: 3),
            .init(substanceName: "MDMA", ingestionCount: 1)
        ],
        last12Months: [
            .init(substanceName: "Cannabis", ingestionCount: 55),
            .init(substanceName: "Cocaine", ingestionCount: 10),
            .init(substanceName: "MDMA", ingestionCount: 4),
            .init(substanceName: "Amphetamine", ingestionCount: 3)
        ],
        years: [
            .init(substanceName: "Cannabis", ingestionCount: 60),
            .init(substanceName: "Cocaine", ingestionCount: 15),
            .init(substanceName: "MDMA", ingestionCount: 8),
            .init(substanceName: "Amphetamine", ingestionCount: 8)
        ],
        colorMapping: { substanceName in
            switch substanceName {
            case "MDMA": return Color.pink
            case "Cannabis": return .green
            case "Cocaine": return .blue
            case "Amphetamine": return .cyan
            case "LSD": return .purple
            default: return .red
            }
        }
    )
}

struct SubstanceExperienceCountForDay: Identifiable {
    var id: String {
        day.asDateAndTime + substanceName
    }
    let day: Date
    let substanceName: String
    let experienceCount: Double
}

struct SubstanceExperienceCountForMonth {
    let month: Date
    let substanceName: String
    let experienceCount: Double
}

struct SubstanceExperienceCountForYear {
    let year: Date
    let substanceName: String
    let experienceCount: Double
}

struct ExperienceData {

    let last30Days: [SubstanceExperienceCountForDay]
    let last12Months: [SubstanceExperienceCountForMonth]
    let years: [SubstanceExperienceCountForYear]
    let colorMapping: (String) -> Color

    var last30DaysTotal: Double {
        last30Days.map { $0.experienceCount }.reduce(0, +)
    }

    var last12MonthsTotal: Double {
        last12Months.map { $0.experienceCount }.reduce(0, +)
    }

    var yearsTotal: Double {
        years.map { $0.experienceCount }.reduce(0, +)
    }

    var monthlyAverage: Double {
        last12MonthsTotal / 12.0
    }

    var yearlyAverage: Double {
        guard let earliestYear = years.map({$0.year}).min() else {return 0}
        let numberOfYearsShown = Calendar.current.numberOfYearsBetweenRoundedUp(earliestYear, and: Date.now)
        guard numberOfYearsShown > 0 else {return 0}
        return yearsTotal / Double(numberOfYearsShown)
    }
}

extension Calendar {
    func numberOfYearsBetweenRoundedUp(_ from: Date, and to: Date) -> Int {
        let components = dateComponents([.year, .month], from: from, to: to)
        let year = components.year!
        let month = components.month!
        if month > 0 {
            return year + 1
        } else {
            return year
        }
    }
}


extension ExperienceData {
    static let mock1 = ExperienceData(
        last30Days: [
            .init(day: date(year: 2022, month: 5, day: 8), substanceName: "MDMA", experienceCount: 0.5),
            .init(day: date(year: 2022, month: 5, day: 8), substanceName: "Cannabis", experienceCount: 0.5),
            .init(day: date(year: 2022, month: 5, day: 9), substanceName: "Cannabis", experienceCount: 1),
            .init(day: date(year: 2022, month: 5, day: 10), substanceName: "Cannabis", experienceCount: 1),
            .init(day: date(year: 2022, month: 5, day: 13), substanceName: "Cocaine", experienceCount: 1.0/3),
            .init(day: date(year: 2022, month: 5, day: 13), substanceName: "Amphetamine", experienceCount: 1.0/3),
            .init(day: date(year: 2022, month: 5, day: 13), substanceName: "LSD", experienceCount: 1.0/3),
            .init(day: date(year: 2022, month: 5, day: 14), substanceName: "Cannabis", experienceCount: 1),
            .init(day: date(year: 2022, month: 5, day: 15), substanceName: "MDMA", experienceCount: 1),
            .init(day: date(year: 2022, month: 5, day: 25), substanceName: "Cocaine", experienceCount: 0.5),
            .init(day: date(year: 2022, month: 5, day: 25), substanceName: "MDMA", experienceCount: 0.5),
            .init(day: date(year: 2022, month: 5, day: 27), substanceName: "Cannabis", experienceCount: 0.25),
            .init(day: date(year: 2022, month: 5, day: 27), substanceName: "Amphetamine", experienceCount: 0.25),
            .init(day: date(year: 2022, month: 5, day: 27), substanceName: "MDMA", experienceCount: 0.25),
            .init(day: date(year: 2022, month: 5, day: 27), substanceName: "Cocaine", experienceCount: 0.25)
        ],
        last12Months: [
            .init(month: date(year: 2021, month: 7), substanceName: "MDMA", experienceCount: 1),
            .init(month: date(year: 2021, month: 7), substanceName: "Cocaine", experienceCount: 2),
            .init(month: date(year: 2021, month: 7), substanceName: "Cannabis", experienceCount: 10),
            .init(month: date(year: 2021, month: 8), substanceName: "Cocaine", experienceCount: 1),
            .init(month: date(year: 2021, month: 8), substanceName: "Cannabis", experienceCount: 5),
            .init(month: date(year: 2021, month: 9), substanceName: "Amphetamine", experienceCount: 2),
            .init(month: date(year: 2021, month: 9), substanceName: "Cannabis", experienceCount: 3),
            .init(month: date(year: 2022, month: 1), substanceName: "MDMA", experienceCount: 1),
            .init(month: date(year: 2022, month: 1), substanceName: "Cannabis", experienceCount: 5),
            .init(month: date(year: 2022, month: 3), substanceName: "Amphetamine", experienceCount: 3)
        ],
        years: [
            .init(year: date(year: 2021), substanceName: "MDMA", experienceCount: 3),
            .init(year: date(year: 2021), substanceName: "Cocaine", experienceCount: 4),
            .init(year: date(year: 2021), substanceName: "Cannabis", experienceCount: 20),
            .init(year: date(year: 2021), substanceName: "Amphetamine", experienceCount: 5),
            .init(year: date(year: 2022), substanceName: "MDMA", experienceCount: 5),
            .init(year: date(year: 2022), substanceName: "Cannabis", experienceCount: 15),
            .init(year: date(year: 2022), substanceName: "Amphetamine", experienceCount: 6),
            .init(year: date(year: 2022), substanceName: "Cocaine", experienceCount: 2)
        ],
        colorMapping: { substanceName in
            switch substanceName {
            case "MDMA": return Color.pink
            case "Cannabis": return .green
            case "Cocaine": return .blue
            case "Amphetamine": return .cyan
            case "LSD": return .purple
            default: return .red
            }
        }
    )
}
