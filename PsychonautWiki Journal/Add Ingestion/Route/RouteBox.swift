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

struct RouteBox: View {

    let substance: Substance
    let route: AdministrationRoute
    let dismiss: () -> Void

    var body: some View {
        NavigationLink {
            if substance.name == "Cannabis" && route == .smoked {
                ChooseCannabisSmokedDoseScreen(dismiss: dismiss)
            } else if substance.name == "Alcohol" && route == .oral {
                ChooseAlcoholDoseScreen(dismiss: dismiss)
            } else if substance.name == "Caffeine" && route == .oral {
                ChooseCaffeineDoseScreen(dismiss: dismiss)
            } else if substance.name == "MDMA" && route == .oral {
                ChooseMDMADoseScreen(dismiss: dismiss)
            } else if substance.name == "Psilocybin mushrooms" && route == .oral {
                ChooseShroomsDoseScreen(dismiss: dismiss)
            } else {
                ChooseDoseScreen(
                    substance: substance,
                    administrationRoute: route,
                    dismiss: dismiss
                )
            }
        } label: {
            RouteBoxLabel(route: route)
        }
    }
}

struct RouteBoxLabel: View {

    let route: AdministrationRoute

    var body: some View {
        GroupBox {
            VStack(alignment: .center) {
                Text(route.rawValue.localizedCapitalized)
                    .font(.headline)
                Text(route.clarification)
                    .font(.footnote)
                    .multilineTextAlignment(.center)

            }
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .center
            )
        }
    }
}

#Preview {
    RouteBoxLabel(route: .oral)
}
