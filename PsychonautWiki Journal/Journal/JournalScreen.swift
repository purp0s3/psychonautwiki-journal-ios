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
import StoreKit

struct JournalScreen: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Experience.sortDate, ascending: false)]
    ) var experiences: FetchedResults<Experience>


    @State private var searchText = ""
    private var query: Binding<String> {
        Binding {
            searchText
        } set: { newValue in
            searchText = newValue
            setPredicate()
        }
    }

    private func setPredicate() {
        let predicateFavorite = NSPredicate(
            format: "isFavorite == %@",
            NSNumber(value: true)
        )
        let predicateTitle = NSPredicate(
            format: "title CONTAINS[cd] %@",
            searchText as CVarArg
        )
        let predicateSubstance = NSPredicate(
            format: "%K.%K CONTAINS[cd] %@",
            #keyPath(Experience.ingestions),
            #keyPath(Ingestion.substanceName),
            searchText as CVarArg
        )
        if isFavoriteFilterEnabled {
            if searchText.isEmpty {
                experiences.nsPredicate = predicateFavorite
            } else {
                let titleOrSubstancePredicate = NSCompoundPredicate(
                    orPredicateWithSubpredicates: [predicateTitle, predicateSubstance]
                )
                experiences.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateFavorite, titleOrSubstancePredicate])
            }
        } else {
            if searchText.isEmpty {
                experiences.nsPredicate = nil
            } else {
                experiences.nsPredicate = NSCompoundPredicate(
                    orPredicateWithSubpredicates: [predicateTitle, predicateSubstance]
                )
            }
        }
    }

    @State private var isShowingAddIngestionSheet = false
    @State private var isTimeRelative = false
    @State private var isFavoriteFilterEnabled = false

    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false
    @AppStorage("openUntilRatedCount") var openUntilRatedCount: Int = 0

    var body: some View {
        NavigationView {
            FabPosition {
                Button {
                    isShowingAddIngestionSheet.toggle()
                } label: {
                    Label("New Ingestion", systemImage: "plus").labelStyle(FabLabelStyle())
                }
            } screen: {
                screen
            }
            .fullScreenCover(isPresented: $isShowingAddIngestionSheet) {
                ChooseSubstanceScreen()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    favoriteButton
                    Menu {
                        Button {
                            isTimeRelative = false
                        } label: {
                            let option = TimeDisplayStyle.regular
                            if isTimeRelative {
                                Text(option.text)
                            } else {
                                Label(option.text, systemImage: "checkmark")
                            }
                        }
                        Button {
                            isTimeRelative = true
                        } label: {
                            let option = TimeDisplayStyle.relativeToNow
                            if isTimeRelative {
                                Label(option.text, systemImage: "checkmark")
                            } else {
                                Text(option.text)
                            }
                        }
                    } label: {
                        Label("Time Display", systemImage: "timer")
                    }
                }
            }
            .navigationTitle("Journal")
        }
        .navigationViewStyle(.stack)
    }

    private var newIngestionButton: some View {
        Button {
            isShowingAddIngestionSheet.toggle()
        } label: {
            Label("New Ingestion", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
        }
    }

    private var favoriteButton: some View {
        Button {
            isFavoriteFilterEnabled.toggle()
        } label: {
            if isFavoriteFilterEnabled {
                Label("Don't Filter Favorites", systemImage: "star.fill")
            } else {
                Label("Filter Favorites", systemImage: "star")
            }
        }
        .onChange(of: isFavoriteFilterEnabled) { newValue in
            setPredicate()
        }
    }

    private var screen: some View {
        ExperiencesList(
            experiences: experiences,
            isFavoriteFilterEnabled: isFavoriteFilterEnabled,
            isTimeRelative: isTimeRelative)
        .optionalScrollDismissesKeyboard()
        .searchable(text: query, prompt: "Search by title or substance")
        .disableAutocorrection(true)
        .task {
            maybeRequestAppRating()
        }
    }

    private func maybeRequestAppRating() {
        if #available(iOS 16.2, *) {
            if openUntilRatedCount < 10 {
                openUntilRatedCount += 1
            } else if openUntilRatedCount == 10 {
                if isEyeOpen && experiences.count > 5 {
                    if let windowScene = UIApplication.shared.currentWindow?.windowScene {
                        SKStoreReviewController.requestReview(in: windowScene)
                    }
                    openUntilRatedCount += 1
                }
            }
        }
    }
}
