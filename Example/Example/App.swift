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
                        ToolbarItem {
                            Button {
                                NotificationCenter.default.post(name: .init("Reset"), object: nil)
                            } label: {
                                Image(systemName: "arrow.counterclockwise")
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

        // 新增：初始直接渲染全部 testDocument
        let parser = MarkdownParser()
        let result = parser.parse(testDocument)
        let theme = markdownTextView.theme
        var renderedContexts: [String: RenderedItem] = [:]
        for (key, value) in result.mathContext {
            let image = MathRenderer.renderToImage(
                latex: value,
                fontSize: theme.fonts.body.pointSize,
                textColor: theme.colors.body
            )?.withRenderingMode(.alwaysTemplate)
            let renderedContext = RenderedItem(
                image: image,
                text: value
            )
            renderedContexts["math://\(key)"] = renderedContext
        }
        markdownTextView.setMarkdown(result.document, renderedContent: renderedContexts)
        view.setNeedsLayout()
        view.layoutIfNeeded()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(play),
            name: .init("Play"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetMarkdown),
            name: .init("Reset"),
            object: nil
        )
    }

    private var streamDocument = ""

    @objc func play() {
        print(#function, Date())
        DispatchQueue.global().async { [self] in
            for char in testDocument {
                streamDocument.append(char)
                autoreleasepool {
                    let parser = MarkdownParser()
                    let result = parser.parse(streamDocument)
                    let theme = markdownTextView.theme
                    var renderedContexts: [String: RenderedItem] = [:]
                    for (key, value) in result.mathContext {
                        let image = MathRenderer.renderToImage(
                            latex: value,
                            fontSize: theme.fonts.body.pointSize,
                            textColor: theme.colors.body
                        )?.withRenderingMode(.alwaysTemplate)
                        let renderedContext = RenderedItem(
                            image: image,
                            text: value
                        )
                        renderedContexts["math://\(key)"] = renderedContext
                    }
                    DispatchQueue.main.asyncAndWait {
                        let date = Date()
                        markdownTextView.setMarkdown(result.document, renderedContent: renderedContexts)
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                        let time = Date().timeIntervalSince(date)
                        self.measureLabel.text = String(format: "Time: %.4f ms", time * 1000)
                    }
                }
            }
        }
    }

    @objc func resetMarkdown() {
        markdownTextView.prepareForReuse()
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
在 Markdown 中，原生语法不支持 `<br>` 换行，但部分渲染器（如 GitHub Flavored Markdown 或某些解析器）可能支持。以下是测试表格渲染的示例：

### 基础表格测试

| 语法       | 效果          | 备注               |
|------------|---------------|--------------------|
| **加粗**   | 加粗文本      | 字体加粗           |
| *斜体*     | 斜体文本      | 字体倾斜           |
| `代码`     | 内联代码      | 单行代码块         |
| ---        | 分割线        | 需单独一行         |


### 换行测试（可能不生效）

| 场景           | 输入示例       | 预期效果              |
|----------------|----------------|-----------------------|
| 硬换行<br>测试 | 行1<br>行2     | 显示为两行文本        |
| 空格换行       | 行1<br>行2 | 需两个以上空格 + 换行 |


### 特殊内容测试

| 类型        | 示例                      | 说明                     |
|-------------|---------------------------|--------------------------|
| 链接        | [Google](https://google.com) | 超链接                   |
| 图片        | `![alt](image.png)`       | 需替换为真实图片路径     |
| 表格嵌套    | 不支持                    | 需用HTML实现             |


### 测试建议
1. 复制上述内容到你的Markdown渲染环境
2. 检查以下功能是否正常：
   - 加粗/斜体/代码高亮
   - 表格边框对齐
   - 换行效果（部分工具需开启HTML支持）
3. 如果`<br>`无效，可尝试：
   - 改用HTML表格
   - 使用两个空格 + 换行符（部分解析器支持）

如果需要更复杂的表格（如合并单元格），建议直接使用HTML编写。
"""###
