// Copyright (c) 2022. Isaak Hanimann.
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

struct SubstanceBox: View {

    let substance: Substance
    let dismiss: () -> Void
    let isEyeOpen: Bool

    var body: some View {
        NavigationLink {
            if isEyeOpen {
                if !substance.saferUse.isEmpty {
                    AcknowledgeSaferUseScreen(substance: substance, dismiss: dismiss)
                } else {
                    AcknowledgeInteractionsView(substance: substance, dismiss: dismiss)
                }
            } else {
                ChooseDoseScreen(
                    substance: substance,
                    administrationRoute: .oral,
                    dismiss: dismiss
                )
            }
        } label: {
            GroupBox(substance.name) {
                if !substance.commonNames.isEmpty {
                    HStack {
                        Text(substance.commonNames, format: .list(type: .or))
                            .multilineTextAlignment(.leading)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct SubstanceBox_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LazyVStack {
                SubstanceBox(
                    substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
                    dismiss: {},
                    isEyeOpen: true
                ).padding(.horizontal)
            }
        }
    }
}
