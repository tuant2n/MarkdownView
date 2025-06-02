//
//  App.swift
//  Example
//
//  Created by 秋星桥 on 1/20/25.
//

import SwiftUI

@main
struct TheApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Content()
                    .toolbar {
                        ToolbarItem {
                            Button {
                                NotificationCenter.default.post(name: .init("Play"), object: nil)
                            } label: {
                                Image(systemName: "play")
                            }
                        }
                    }
                    .navigationTitle("MarkdownView")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(.stack)
            .frame(minWidth: 200, maxWidth: .infinity)
        }
    }
}

import MarkdownParser
import MarkdownView

final class ContentController: UIViewController {
    let scrollView = UIScrollView()
    let measureLabel = UILabel()

    private var markdownTextView: MarkdownTextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)

        markdownTextView = MarkdownTextView()
        scrollView.addSubview(markdownTextView)

        measureLabel.numberOfLines = 0
        measureLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        measureLabel.textColor = .label

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(play),
            name: .init("Play"),
            object: nil
        )
    }

    @objc func play() {
        let parser = MarkdownParser()
        print(#function, Date())
        DispatchQueue.global().async { [self] in
            parser.reset()
            for char in testDocument {
                autoreleasepool {
                    let document = parser.feed(.init(char))
                    DispatchQueue.main.asyncAndWait {
                        let date = Date()
                        self.markdownTextView.nodes = document
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                        let time = Date().timeIntervalSince(date)
                        self.measureLabel.text = String(format: "Time: %.4f ms", time * 1000)
                    }
                }
            }
            parser.reset()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        scrollView.frame = view.bounds
        let width = view.bounds.width - 32

        let contentSize = markdownTextView.boundingSize(for: width)
        scrollView.contentSize = contentSize
        markdownTextView.frame = .init(
            x: 16,
            y: 16,
            width: width,
            height: contentSize.height
        )

        measureLabel.removeFromSuperview()
        measureLabel.frame = .init(
            x: 16,
            y: (scrollView.subviews.map(\.frame.maxY).max() ?? 0) + 16,
            width: width,
            height: 50
        )
        scrollView.addSubview(measureLabel)
        scrollView.contentSize = .init(
            width: width,
            height: measureLabel.frame.maxY + 16
        )

        let offset = CGPoint(
            x: 0,
            y: scrollView.contentSize.height - scrollView.frame.height
        )
        _ = offset
        scrollView.setContentOffset(offset, animated: false)
    }
}

struct Content: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> ContentController {
        ContentController()
    }

    func updateUIViewController(_: ContentController, context _: Context) {}
}

let testDocument = ###"""
## Markdown 测试数据

平方根公式通常是指求一个数的平方根的公式，最常见的形式是对于非负数 \( a \)，有：

\[
\sqrt{a} = b \quad \Leftrightarrow \quad b^2 = a
\]

### 证明步骤

1. **定义平方根**：
   根据平方根的定义，假设 \( b = \sqrt{a} \)，这意味着 \( b \) 是一个数，使得 \( b^2 = a \)。

2. **正数的平方根**：
   - 对于正数 \( a > 0 \)，我们可以通过构造一个正方形来理解平方根的几何意义。设正方形的边长为 \( b \)，则该正方形的面积为 \( b^2 \)。
   - 当 \( b^2 = a \) 时，我们可以得到边长 \( b = \sqrt{a} \)。

3. **特殊情况 - 0**：
   - 当 \( a = 0 \) 时，显然 \( \sqrt{0} = 0 \)，因为 \( 0^2 = 0 \)。

4. **负数的平方根**：
   - 对于负数 \( a < 0 \)，在实数范围内没有平方根，因为没有任何一个实数的平方是负数。
   - 但在复数范围内，可以定义平方根为 \( \sqrt{a} = \sqrt{|a|} i \)，其中 \( i \) 是虚数单位。

### 一些算数

当 $a \ne 0$ 时，方程 $ax^2 + bx + c = 0$ 有两个解，分别为 $x = {-b \pm \sqrt{b^2-4ac} \over 2a}$。
"""###
