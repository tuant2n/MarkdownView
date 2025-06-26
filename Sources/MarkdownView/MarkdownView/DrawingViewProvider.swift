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
        if let object = objects.popLast() {
            object
        } else {
            factory()
        }
    }

    open func release(_ object: T) {
        objects.append(object)
    }
}

private class ViewBox<T: UIView>: ObjectPool<T> {
    override func acquire() -> T {
        while true {
            let item = super.acquire()
            guard item.superview == nil else { continue }
            return item
        }
    }

    override func release(_ item: T) {
        item.removeFromSuperview()
        super.release(item)
    }
}

public final class DrawingViewProvider {
    private let codeViewPool: ViewBox<CodeView> = .init {
        CodeView()
    }

    private let tableViewPool: ViewBox<TableView> = .init {
        TableView()
    }

    private let mathImageViewPool: ViewBox<MathImageView> = .init {
        MathImageView()
    }

    public init() {}

    public func releaseAll() {
        while let codeView = codeViewPool.objects.popLast() {
            codeView.removeFromSuperview()
        }
        while let tableView = tableViewPool.objects.popLast() {
            tableView.removeFromSuperview()
        }
        while let mathImageView = mathImageViewPool.objects.popLast() {
            mathImageView.removeFromSuperview()
            mathImageView.reset()
        }
    }

    func acquireCodeView() -> CodeView {
        codeViewPool.acquire()
    }

    func releaseCodeView(_ codeView: CodeView) {
        codeView.removeFromSuperview()
        codeViewPool.release(codeView)
    }

    func acquireTableView() -> TableView {
        tableViewPool.acquire()
    }

    func releaseTableView(_ tableView: TableView) {
        tableView.removeFromSuperview()
        tableViewPool.release(tableView)
    }

    func acquireMathImageView() -> MathImageView {
        mathImageViewPool.acquire()
    }

    func releaseMathImageView(_ mathImageView: MathImageView) {
        mathImageView.removeFromSuperview()
        mathImageView.reset()
        mathImageViewPool.release(mathImageView)
    }
}
