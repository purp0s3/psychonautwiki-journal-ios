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

import SwiftUI

struct MissingToleranceText: View {

    let substanceNames: [String]

    var body: some View {
        Text("Excluding ") + Text(substanceNames, format: .list(type: .and)) + Text(" because of missing tolerance info")
    }
}

struct MissingToleranceText_Previews: PreviewProvider {
    static var previews: some View {
        MissingToleranceText(substanceNames: ["2C-B", "Ketamine"])
    }
}
