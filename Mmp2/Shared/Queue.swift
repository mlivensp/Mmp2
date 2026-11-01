//
//  Queue.swift
//  Mmp2
//
//  Created by Michael Livenspargar on 10/31/26.
//

import Foundation
struct Queue<T> {
    private var elements: [T] = []
    private var head = 0

    mutating func enqueue(_ item: T) {
        elements.append(item)
    }

    mutating func dequeue() -> T? {
        guard head < elements.count else {
            return nil
        }

        let item = elements[head]
        head += 1

        // Periodically reclaim memory
        if head > 50 && head * 2 > elements.count {
            elements.removeFirst(head)
            head = 0
        }

        return item
    }

    var front: T? {
        head < elements.count ? elements[head] : nil
    }

    var isEmpty: Bool {
        count == 0
    }

    var count: Int {
        elements.count - head
    }
}
