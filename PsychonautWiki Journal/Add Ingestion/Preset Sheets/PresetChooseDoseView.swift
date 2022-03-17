import SwiftUI

struct PresetChooseDoseView: View {

    let preset: Preset
    let dismiss: (AddResult) -> Void
    let experience: Experience?
    @State private var dose = 1.0
    @State private var doseText = "1"

    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section("Choose Dose") {
                    HStack {
                        TextField("Enter Dose", text: $doseText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Text(preset.unitsUnwrapped)
                    }
                    .font(.title)
                    .onChange(of: doseText) { _ in
                        if let doseUnwrapped = Double(doseText) {
                            dose = doseUnwrapped
                        }
                    }
                }
                ForEach(preset.componentsUnwrapped) { com in
                    Section("\(com.substanceNameUnwrapped) Conversion") {
                        let roaDose = com.substance?.getDose(for: com.administrationRouteUnwrapped)
                        DoseView(roaDose: roaDose)
                        if let dosePerUnit = com.dosePerUnitOfPresetUnwrapped {
                            let comDose = dosePerUnit * dose
                            let doseText = comDose.formatted()
                            HStack(alignment: .firstTextBaseline) {
                                let type = roaDose?.getRangeType(for: comDose, with: com.unitsUnwrapped) ?? .none
                                Text("\(doseText) \(com.unitsUnwrapped) ")
                                    .foregroundColor(type.color)
                                    .font(.title)
                                Spacer()
                                Text(com.administrationRouteUnwrapped?.rawValue ?? "")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
            }
            NavigationLink(
                destination: PresetChooseTimeAndColorsView(
                    preset: preset,
                    dose: dose,
                    dismiss: dismiss,
                    experience: experience
                ),
                label: {
                    Text("Next")
                        .primaryButtonText()
                }
            )
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss(.cancelled)
                }
            }
        }
        .navigationTitle(preset.nameUnwrapped)
    }
}

struct PresetChooseDoseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PresetChooseDoseView(
                preset: PreviewHelper.shared.preset,
                dismiss: { _ in },
                experience: nil
            )
        }
    }
}
