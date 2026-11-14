//
//  PlaybackSequenceTableView.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 11/13/26.
//

import SwiftUI
import AppKit

struct PlaybackSequenceTableView: NSViewRepresentable {

    @Bindable var vm: PlaybackSequencesViewModel
    @Binding var selectedRow: Int?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(vm: vm, selectedRow: $selectedRow)
    }

    func makeNSView(context: Context) -> NSScrollView {

        let tableView = NSTableView()

        tableView.usesAlternatingRowBackgroundColors = true
        tableView.allowsColumnReordering = false
        tableView.allowsColumnResizing = true

        let orderColumn = NSTableColumn(
            identifier: .init("playOrder")
        )
        orderColumn.title = "Order"
        orderColumn.width = 60

        let valueColumn = NSTableColumn(
            identifier: .init("value")
        )
        valueColumn.title = "Value"

        let timesColumn = NSTableColumn(
            identifier: .init("timesToPlay")
        )
        timesColumn.title = "Times To Play"

        tableView.addTableColumn(orderColumn)
        tableView.addTableColumn(valueColumn)
        tableView.addTableColumn(timesColumn)

        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator

        context.coordinator.tableView = tableView

        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true

        return scrollView
    }

    func updateNSView(
        _ scrollView: NSScrollView,
        context: Context
    ) {
        context.coordinator.vm = vm

        guard let tableView = context.coordinator.tableView else {
            return
        }

        tableView.reloadData()

        context.coordinator.isProgrammaticallySelectingRow = true
        
        if let selectedRow {
            tableView.selectRowIndexes(
                IndexSet(integer: selectedRow),
                byExtendingSelection: false
            )
        }
        else {
            tableView.deselectAll(nil)
        }
        
        context.coordinator.isProgrammaticallySelectingRow = false
    }
}

extension PlaybackSequenceTableView {

    final class Coordinator: NSObject {

        var vm: PlaybackSequencesViewModel
        var selectedRow: Binding<Int?>
        var isProgrammaticallySelectingRow = false
        weak var tableView: NSTableView?

        init(vm: PlaybackSequencesViewModel, selectedRow: Binding<Int?>) {
            self.vm = vm
            self.selectedRow = selectedRow
        }
    }
}

extension PlaybackSequenceTableView.Coordinator:
    NSTableViewDataSource
{
    func numberOfRows(
        in tableView: NSTableView
    ) -> Int {
        vm.sequenceVMs.count
    }
}

extension PlaybackSequenceTableView.Coordinator:
    NSTableViewDelegate
{
    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {

        let sequence = vm.sequenceVMs[row]

        guard let columnId = tableColumn?.identifier.rawValue
        else {
            return nil
        }

        switch columnId {

        case "playOrder":
            return makeOrderCell(
                order: row + 1
            )

        case "value":
            return makeValueCell(
                sequence: sequence,
                row: row
            )

        case "timesToPlay":
            return makeTimesToPlayCell(
                sequence: sequence,
                row: row
            )

        default:
            return nil
        }
    }
    
    func tableViewSelectionDidChange(
            _ notification: Notification
        ) {
            guard !isProgrammaticallySelectingRow else {
                return
            }

            guard let tableView else {
                return
            }

            let row = tableView.selectedRow

            selectedRow.wrappedValue =
                row >= 0
                ? row
                : nil
        }
}

private extension PlaybackSequenceTableView.Coordinator {

    func makeOrderCell(
        order: Int
    ) -> NSView {

        let field = NSTextField(labelWithString: "\(order)")
        field.alignment = .center

        return field
    }
}

private extension PlaybackSequenceTableView.Coordinator {

    func makeValueCell(
        sequence: PlaybackSequenceViewModel,
        row: Int
    ) -> NSView {

        let field = EditableTextField()

        field.stringValue = sequence.valueString
        field.isBordered = false
        field.backgroundColor = .clear

        configureValidationAppearance(
            field,
            error: sequence.valueError
        )

        field.onCommit = { [weak self] newValue in

            sequence.valueString = newValue

            self?.tableView?.reloadData(
                forRowIndexes: IndexSet(integer: row),
                columnIndexes: IndexSet(integer: 1)
            )
        }

        return field
    }
}

private extension PlaybackSequenceTableView.Coordinator {

    func makeTimesToPlayCell(
        sequence: PlaybackSequenceViewModel,
        row: Int
    ) -> NSView {

        let field = EditableTextField()

        field.stringValue = sequence.timesToPlayString
        field.isBordered = false
        field.backgroundColor = .clear

        configureValidationAppearance(
            field,
            error: sequence.timesToPlayError
        )

        field.onCommit = { [weak self] newValue in

            sequence.timesToPlayString = newValue

            self?.tableView?.reloadData(
                forRowIndexes: IndexSet(integer: row),
                columnIndexes: IndexSet(integer: 2)
            )
        }

        return field
    }
}

private extension PlaybackSequenceTableView.Coordinator {

    func configureValidationAppearance(
        _ field: NSTextField,
        error: String?
    ) {
        if error != nil {

            field.drawsBackground = true
            field.backgroundColor =
                NSColor.systemRed.withAlphaComponent(0.15)

            field.textColor = .systemRed

        } else {

            field.drawsBackground = false
            field.textColor = .labelColor
        }
    }
}
