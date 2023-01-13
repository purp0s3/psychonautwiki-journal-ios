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

struct EditIngestionScreen: View {

    let ingestion: Ingestion
    let substanceName: String
    let substance: Substance?
    @State private var time = Date()
    @State private var dose: Double? = nil
    @State private var units: String? = "mg"
    @State private var isEstimate = false
    @State private var note = ""
    @State private var route = AdministrationRoute.oral
    @Environment(\.dismiss) var dismiss

    var body: some View {
        EditIngestionContent(
            substanceName: substanceName,
            roaDose: substance?.getDose(for: route),
            route: $route,
            time: $time,
            dose: $dose,
            units: $units,
            isEstimate: $isEstimate,
            note: $note,
            save: save,
            delete: delete
        ).onAppear {
            time = ingestion.timeUnwrapped
            dose = ingestion.doseUnwrapped
            units = ingestion.units
            isEstimate = ingestion.isEstimate
            note = ingestion.noteUnwrapped
            route = ingestion.administrationRouteUnwrapped
        }
    }

    private func save() {
        ingestion.time = time
        ingestion.dose = dose ?? 0
        ingestion.units = units
        ingestion.isEstimate = isEstimate
        ingestion.note = note
        ingestion.administrationRoute = route.rawValue
        PersistenceController.shared.saveViewContext()
        dismiss()
    }

    private func delete() {
        PersistenceController.shared.viewContext.delete(ingestion)
        PersistenceController.shared.saveViewContext()
        dismiss()
    }
}

struct EditIngestionContent: View {

    let substanceName: String
    let roaDose: RoaDose?
    @Binding var route: AdministrationRoute
    @Binding var time: Date
    @Binding var dose: Double?
    @Binding var units: String?
    @Binding var isEstimate: Bool
    @Binding var note: String
    let save: () -> Void
    let delete: () -> Void

    var body: some View {
        Form {
            Section("Administration Route") {
                Picker("Route", selection: $route) {
                    ForEach(AdministrationRoute.allCases) { oneRoute in
                        Text(oneRoute.rawValue.localizedCapitalized).tag(oneRoute)
                    }
                }
            }
            Section("\(route.rawValue.localizedCapitalized) Dose") {
                DoseRow(roaDose: roaDose)
                DosePicker(
                    roaDose: roaDose,
                    doseMaybe: $dose,
                    selectedUnits: $units
                )
                Toggle("Is an Estimate", isOn: $isEstimate).tint(.accentColor)
            }.listRowSeparator(.hidden)
            Section("Ingestion Time") {
                DatePicker(
                    "Enter Ingestion Time",
                    selection: $time,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.wheel)
            }
            Section("Notes") {
                TextField("Enter Note", text: $note)
                    .autocapitalization(.sentences)
            }
            Section("Delete") {
                Button(action: delete) {
                    Label("Delete Ingestion", systemImage: "trash").foregroundColor(.red)
                }
            }
        }
        .optionalScrollDismissesKeyboard()
        .navigationTitle("Edit \(substanceName)")
        .onDisappear {
            save()
        }
    }
}

struct EditIngestionScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditIngestionContent(
                substanceName: "MDMA",
                roaDose: SubstanceRepo.shared.getSubstance(name: "MDMA")!.getDose(for: .oral)!,
                route: .constant(.oral),
                time: .constant(Date()),
                dose: .constant(50),
                units: .constant("mg"),
                isEstimate: .constant(false),
                note: .constant("These are my notes"),
                save: {},
                delete: {}
            )
        }
    }
}
