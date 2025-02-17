// Copyright (c) 2023. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at 
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import Foundation

class Suggestion: Identifiable {
    var id: String {
        substanceName + route.rawValue
    }
    let substanceName: String
    let substance: Substance?
    let units: String
    let route: AdministrationRoute
    let substanceColor: SubstanceColor
    var dosesAndUnit: [DoseAndUnit]
    let lastTimeUsed: Date

    init(substanceName: String, substance: Substance?, units: String, route: AdministrationRoute, substanceColor: SubstanceColor, dosesAndUnit: [DoseAndUnit], lastTimeUsed: Date) {
        self.substanceName = substanceName
        self.substance = substance
        self.units = units
        self.route = route
        self.substanceColor = substanceColor
        self.dosesAndUnit = dosesAndUnit
        self.lastTimeUsed = lastTimeUsed
    }
}
