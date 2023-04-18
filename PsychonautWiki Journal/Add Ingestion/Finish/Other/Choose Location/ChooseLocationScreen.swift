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

struct ChooseLocationScreen: View {

    @ObservedObject var locationManager: LocationManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ChooseLocationScreenContent(
                selectedLocation: $locationManager.selectedLocation,
                selectedLocationName: $locationManager.selectedLocationName,
                searchText: $locationManager.searchText,
                authorizationStatus: locationManager.authorizationStatus,
                isLoadingLocationResults: locationManager.isSearchingForLocations,
                currentLocation: locationManager.currentLocation,
                searchSuggestedLocations: locationManager.searchSuggestedLocations,
                experienceLocations: locationManager.experienceLocations
            )
            .searchable(
                text: $locationManager.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search Location"
            )
            .disableAutocorrection(true)
            .onSubmit(of: .search) {
                locationManager.searchLocations()
            }
            .task {
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestPermission()
                }
                locationManager.maybeRequestLocation()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Experience Location")
        }
    }
}

