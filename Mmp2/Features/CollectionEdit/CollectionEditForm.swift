//
//  CollectionEditForm.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/6/26.
//

import SwiftData
import SwiftUI

struct CollectionEditForm: View {
    @Environment(AppRootManager.self) private var appRootManager
    @Environment(\.dismiss) private var dismiss

    @State private var vm: CollectionEditView.ViewModel
    
    init(collection: MediaCollection, context: ModelContext) {
        _vm = State(initialValue: CollectionEditView.ViewModel(collection: collection, context: context))
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Name") {
                    ErrorFieldContainer(
                        hasError: vm.nameError != nil,
                        errorMessage: vm.nameError
                    ) {
                        TextField("", text: $vm.nameString)
                    }
                }

                Section("Notes") {
                    TextField("", text: $vm.notes)
                }
            }
            .frame(height: 180)

            CollectionEditSourceListView(
                vm: vm
            ) { source in
                appRootManager.editSource(
                    source,
                    in: vm.collection
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.leading, .trailing], formPadding)

            Divider()

            HStack {
                Spacer()

                Button("Save") {
                    do {
                        if try vm.save() {
                            dismiss()
                        }
                    } catch {
                        let _ = print(error.localizedDescription)
                        // TODO: notify user
                    }
                }
                .buttonStyle(.borderedProminent)

                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
        }
    }
}

//#Preview {
//    CollectionEditForm()
//}
