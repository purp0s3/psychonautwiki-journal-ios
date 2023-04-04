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

struct RatingScreenContent: View {

    @Binding var selectedTime: Date
    @Binding var selectedRating: ShulginRatingOption
    let dismiss: () -> Void
    let tapDone: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section("Time") {
                    DatePicker(
                        "Ingestion Time",
                        selection: $selectedTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                }
                Section {
                    Picker("Shulgin Rating", selection: $selectedRating) {
                        ForEach(ShulginRatingOption.allCases, id: \.self) { option in
                            Text(option.stringRepresentation)
                        }
                    }.pickerStyle(.segmented)
                } header: {
                    Text("Shulgin Rating")
                } footer: {
                    Text("++++ is not on the quantitative potency scale")
                }
                Section("Shulgin Rating Explanation") {
                    ForEach(ShulginRatingOption.allCases, id: \.self) { option in
                        VStack(alignment: .leading) {
                            Text(option.stringRepresentation).font(.headline)
                            Text(option.description).foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add Rating")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        tapDone()
                    }
                }
            }
        }
    }
}

struct EditRatingScreenContent_Previews: PreviewProvider {
    static var previews: some View {
        RatingScreenContent(
            selectedTime: .constant(.now),
            selectedRating: .constant(.plus),
            dismiss: {},
            tapDone: {}
        )
    }
}
