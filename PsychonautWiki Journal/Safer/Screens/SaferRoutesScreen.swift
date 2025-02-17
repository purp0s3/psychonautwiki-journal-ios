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

struct SaferRoutesScreen: View {
    var body: some View {
        List {
            Text("Don’t share snorting equipment (straws, banknotes, bullets) to avoid blood-borne diseases such as Hepatitis C that can be transmitted through blood amounts so small you can’t notice. Injection is the the most dangerous route of administration and highly advised against. If you are determined to inject, don’t share injection materials and refer to the safer injection guide.")
            Link(destination: URL(string: "https://www.youtube.com/watch?v=31fuvYXxeV0&list=PLkC348-BeCu6Ut-iJy8xp9_LLKXoMMroR")!
            ) {
                Label("Safer Snorting Video", systemImage: "play")
            }
            Link(destination: URL(string: "https://www.youtube.com/watch?v=lBlS2e46CV0&list=PLkC348-BeCu6Ut-iJy8xp9_LLKXoMMroR")!
            ) {
                Label("Safer Smoking Video", systemImage: "play")
            }
            Link(destination: URL(string: "https://www.youtube.com/watch?v=N7HjCPz4A7Y&list=PLkC348-BeCu6Ut-iJy8xp9_LLKXoMMroR")!
            ) {
                Label("Safer Injecting Video", systemImage: "play")
            }
            NavigationLink("Administration Routes Info") {
                AdministrationRouteScreen()
            }
        }
        .navigationTitle("Safer Routes")
        .dismissWhenTabTapped()
    }
}

struct SaferRoutesScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SaferRoutesScreen()
        }
    }
}
