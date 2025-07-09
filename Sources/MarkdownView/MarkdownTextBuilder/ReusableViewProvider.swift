//
//  Created by ktiays on 2025/1/31.
//  Copyright (c) 2025 ktiays. All rights reserved.
//

import DequeModule
import UIKit

private class ObjectPool<T> {
    private let factory: () -> T
    fileprivate lazy var objects: Deque<T> = .init()

    public init(_ factory: @escaping () -> T) {
        self.factory = factory
    }

    open func acquire() -> T {
        if let object = objects.popFirst() {
            return object
        } else {
            let object = factory()
            return object
        }
    }

    open func stash(_ object: T) {
        objects.append(object)
    }
}

private class ViewBox<T: UIView>: ObjectPool<T> {
    override func acquire() -> T {
        super.acquire()
    }

    override func stash(_ item: T) {
        super.stash(item)
    }
}

public final class ReusableViewProvider {
    private let codeViewPool: ViewBox<CodeView> = .init {
        CodeView()
    }

    private let tableViewPool: ViewBox<TableView> = .init {
        TableView()
    }

    public init() {}

    func removeAll() {
        codeViewPool.objects.removeAll()
        tableViewPool.objects.removeAll()
    }

    func acquireCodeView() -> CodeView {
        codeViewPool.acquire()
    }

    func stashCodeView(_ codeView: CodeView) {
        codeViewPool.stash(codeView)
    }

    func acquireTableView() -> TableView {
        tableViewPool.acquire()
    }

    func stashTableView(_ tableView: TableView) {
        tableViewPool.stash(tableView)
    }
}
