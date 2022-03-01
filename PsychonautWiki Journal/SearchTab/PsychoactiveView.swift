import SwiftUI

struct PsychoactiveView: View {

    let psychoactive: PsychoactiveClass

    var body: some View {
        NavigationView {
            List {
                Section("Substances in this psychoactive class") {
                    ForEach(psychoactive.substancesUnwrapped) { sub in
                        NavigationLink(sub.nameUnwrapped) {
                            SubstanceView(substance: sub)
                        }
                    }
                }
                let hasUncertain = !psychoactive.uncertainSubstancesUnwrapped.isEmpty
                let hasUnsafe = !psychoactive.unsafeSubstancesUnwrapped.isEmpty
                let hasDangerous = !psychoactive.dangerousSubstancesUnwrapped.isEmpty
                let showInteractions = hasUncertain || hasUnsafe || hasDangerous
                if showInteractions {
                    Section("Interactions (not exhaustive)") {
                        ForEach(psychoactive.uncertainSubstancesUnwrapped) { sub in
                            NavigationLink(sub.nameUnwrapped) {
                                SubstanceView(substance: sub)
                            }.listRowBackground(Color.yellow)
                        }
                        ForEach(psychoactive.unsafeSubstancesUnwrapped) { sub in
                            NavigationLink(sub.nameUnwrapped) {
                                SubstanceView(substance: sub)
                            }.listRowBackground(Color.orange)
                        }
                        ForEach(psychoactive.dangerousSubstancesUnwrapped) { sub in
                            NavigationLink(sub.nameUnwrapped) {
                                SubstanceView(substance: sub)
                            }.listRowBackground(Color.red)
                        }
                    }
                }
            }
            .navigationTitle(psychoactive.nameUnwrapped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let url = psychoactive.url {
                        Link("Article", destination: url)
                    }
                }
            }
        }
    }
}

struct PsychoactiveView_Previews: PreviewProvider {
    static var previews: some View {
        PsychoactiveView(psychoactive: PreviewHelper.shared.substancesFile.psychoactiveClassesUnwrapped.first!)
    }
}
