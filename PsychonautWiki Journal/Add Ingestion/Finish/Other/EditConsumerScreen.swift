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

struct EditConsumerScreen: View {

    @Binding var consumerName: String

    @State private var consumerNamesInOrder: [String] = []

    var body: some View {
        EditConsumerScreenContent(
            consumerName: $consumerName,
            consumerNamesInOrder: consumerNamesInOrder)
        .onAppear {
            let ingestionFetchRequest = Ingestion.fetchRequest()
            ingestionFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
            ingestionFetchRequest.fetchLimit = 300
            let sortedIngestions = (try? PersistenceController.shared.viewContext.fetch(ingestionFetchRequest)) ?? []
            consumerNamesInOrder = sortedIngestions.compactMap { ing in
                if let consumerName = ing.consumerName, !consumerName.trimmingCharacters(in: .whitespaces).isEmpty {
                    return consumerName
                } else {
                    return nil
                }
            }.uniqued()
        }

    }
}

private struct EditConsumerScreenContent: View {

    @Binding var consumerName: String
    let consumerNamesInOrder: [String]

    @Environment(\.dismiss) private var dismiss


    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Consumer name", text: $consumerName, prompt: Text("Enter name"))
                        .autocapitalization(.words)
                        .autocorrectionDisabled()
                }
                Section {
                    Button {
                        consumerName = ""
                        dismiss()
                    } label: {
                        Label("Me", systemImage: "person")
                    }

                    ForEach(consumerNamesInOrder, id: \.self) { otherName in
                        Button {
                            consumerName = otherName
                            dismiss()
                        } label: {
                            Label(otherName, systemImage: "person")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DoneButton {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Consumer")
        }
    }
}

struct EditConsumerScreen_Previews: PreviewProvider {
    static var previews: some View {
        EditConsumerScreenContent(
            consumerName: .constant("Dave"),
            consumerNamesInOrder: ["Andrea", "Paula", "Eric"]
        )
    }
}
