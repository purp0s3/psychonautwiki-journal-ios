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

enum StomachFullness: String, CaseIterable, Identifiable, Codable {
    case empty, halfFull, full, veryFull

    var id: StomachFullness {
        self
    }

    var text: String {
        switch self {
        case .empty:
            return "Empty"
        case .halfFull:
            return "Half Full"
        case .full:
            return "Full"
        case .veryFull:
            return "Very Full"
        }
    }

    var onsetDelayForOralInHours: Double {
        switch self {
        case .empty:
            return 0
        case .halfFull:
            return 1.5
        case .full:
            return 3
        case .veryFull:
            return 4
        }
    }
}
