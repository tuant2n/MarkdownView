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
# 代码块测试

以下是多种语言的代码块示例：

```python
# Python 示例
def hello(name):
    print(f"Hello, {name}!")
hello("World")
```

```swift
// Swift 示例
import Foundation
print("Hello, Swift!")
```

```c++
// C++ 示例
#include <iostream>
int main() {
    std::cout << "Hello, C++!" << std::endl;
    return 0;
}
```

```javascript
// JavaScript 示例
function greet(name) {
    console.log(`Hello, ${name}!`);
}
greet('JavaScript');
```

```markdown
# Markdown 示例
- 列表项 1
- 列表项 2

**加粗文本**
```

```json
{
  "key": "value",
  "number": 123
}
```

```html
<!-- HTML 示例 -->
<!DOCTYPE html>
<html>
  <body>
    <h1>Hello, HTML!</h1>
  </body>
</html>
```

```bash
# Bash 示例
echo "Hello, Bash!"
```

```go
// Go 示例
package main
import "fmt"
func main() {
    fmt.Println("Hello, Go!")
}
```

```sql
-- SQL 示例
SELECT * FROM users WHERE active = 1;
```

```yaml
# YAML 示例
name: example
version: 1.0.0
description: 示例 YAML 文件
```

"""###
