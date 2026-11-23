//
//  SourceGroupPickerSheetViewModel.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/21/26.
//

import Foundation
import SwiftData

extension SourceGroupPickerSheet {
    @Observable
    final class ViewModel {
        let sourceVM: SourceEditView.ViewModel
        let context: ModelContext

        var groups: [SourceGroup] = []
        var newGroupName = ""

        init(sourceVM: SourceEditView.ViewModel, context: ModelContext) {
            self.sourceVM = sourceVM
            self.context = context
            loadGroups()
        }

        func loadGroups() {
            let mediaCollectionId = sourceVM.mediaCollection.persistentModelID
            let descriptor = FetchDescriptor<SourceGroup>(
                predicate: #Predicate {
                    $0.mediaCollection.persistentModelID == mediaCollectionId
                }, sortBy: [
                    SortDescriptor(\.name_normalized),
                    SortDescriptor(\.primitiveName)
                ]
            )

            groups =
                (try? context.fetch(descriptor))
                ?? []
        }

        func isAlreadyInGroup(
            _ group: SourceGroup
        ) -> Bool {
            sourceVM.sourceGroup?.id == group.id
        }

        func addSourceToGroup(
            _ group: SourceGroup
        ) {
            guard !isAlreadyInGroup(group) else {
                return
            }
            
            sourceVM.sourceGroup = group
        }
        
        func createGroup() {
            let name = newGroupName
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            guard !name.isEmpty
            else {
                return
            }

            let maxGroupSortOrder = sourceVM.mediaCollection.sourceGroups.map { $0.sortOrder }.max() ?? 1
            let maxSourceSortOrder = sourceVM.mediaCollection.sources.map { $0.sortOrder }.max() ?? 1
            let maxSortOrder = max(maxGroupSortOrder, maxSourceSortOrder)
            let group = SourceGroup(
                name: name,
                sortOrder: maxSortOrder + 1,
                mediaCollection: sourceVM.mediaCollection
            )

            sourceVM.sourceGroup = group
        }
    }
}
