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

\[
\sqrt{a} = b \quad \Leftrightarrow \quad b^2 = a
\]


计算圆周率 \\( \pi \\) 的方法有很多种，从古老的几何方法到现代的高精度算法，每一种方法都有其独特的原理。由于 \\( \pi \\) 是一个无理数（不能表示为两个整数的比值）和超越数（不是任何整系数多项式方程的根），它的小数表示是无限不循环的，所以我们只能计算出它的近似值，但可以达到任意所需的精度。

以下是一些计算 \\( \pi \\) 的主要方法：

1.  **几何法 (例如：阿基米德方法)**
    这是最早的计算 \\( \pi \\) 的方法之一。原理是在圆内画内接正多边形，在圆外画外切正多边形。随着多边形的边数增加，它们的周长会越来越接近圆的周长。
    *   **步骤：**
        *   从一个简单的多边形开始（如正六边形）。
        *   通过增加多边形的边数（例如，从正n边形加倍到正2n边形），计算新的内接和外切多边形的周长。
        *   圆的周长 C 介于内接多边形周长和外切多边形周长之间。
        *   由于 \\( \pi = C/d \\) (d是直径)，所以 \\( \pi \\) 的值也被限定在一个范围内。
    *   **特点：** 概念直观，但收敛速度慢，计算高精度 \\( \pi \\) 非常困难。

2.  **无穷级数法**
    这是现代计算 \\( \pi \\) 的主要方法之一。许多数学级数收敛于 \\( \pi \\) 或与 \\( \pi \\) 相关的数值（如 \\( \pi/4 \\)）。通过计算级数的前面足够多的项，可以得到 \\( \pi \\) 的高精度近似值。
    *   **例子：**
        *   **莱布尼茨公式 (Leibniz formula):**
            \\( \frac{\pi}{4} = 1 - \frac{1}{3} + \frac{1}{5} - \frac{1}{7} + \frac{1}{9} - \cdots \\)
            这个级数非常简单，但收敛速度极慢。
        *   **Machin-like Formulas:** (马青公式及其变体)
            如马青公式本人发现的： \\( \frac{\pi}{4} = 4 \arctan\left(\frac{1}{5}\right) - \arctan\left(\frac{1}{239}\right) \\)
            通过 \\( \arctan(x) \\) 的泰勒级数展开式 \\( \arctan(x) = x - \frac{x^3}{3} + \frac{x^5}{5} - \frac{x^7}{7} + \cdots \\)，可以将这些公式转化为计算 \\( \pi \\) 的级数。这类公式收敛速度比莱布尼茨公式快很多。
        *   **其他级数：** 还有许多其他更复杂的级数，如拉马努金级数 (Ramanujan series) 等，具有更快的收敛速度，用于计算极高精度的 \\( \pi \\)。

3.  **迭代算法**
    一些现代算法通过迭代过程快速收敛到 \\( \pi \\)。
    *   **例子：**
        *   **高斯-勒让德算法 (Gauss–Legendre algorithm):** 结合了算术平均和几何平均的概念，收敛速度非常快（二次收敛），每迭代一次，正确数字位数大约翻倍。
        *   **Borwein 算法、Chudnovsky 算法:** 这些算法收敛速度更快，特别是 Chudnovsky 算法，被用于创造计算 \\( \pi \\) 小数点后最多位数的记录，它基于超几何级数。

4.  **蒙特卡洛方法 (Monte Carlo Method)**
    这是一种概率方法，虽然不适用于计算极高精度的 \\( \pi \\)，但提供了一种有趣的视角。
    *   **方法：** 在一个边长为2的正方形内（面积为4），内切一个半径为1的圆（面积为 \\( \pi \times 1^2 = \pi \\)）。随机向正方形内“投点”，落在圆内的点的数量与总投点数量的比值，近似等于圆的面积与正方形面积的比值，即 \\( \frac{\text{落在圆内的点数}}{\text{总投点数}} \approx \frac{\pi}{4} \\)。
    *   **特点：** 概念简单直观，但收敛速度非常慢，精度有限。

**总结：**

早期主要通过几何方法（多边形逼近）计算 \\( \pi \\) 的近似值。现代则主要依赖于收敛速度快的无穷级数和迭代算法，结合强大的计算机算力，才能计算出 \\( \pi \\) 小数点后数万亿位的精确值。计算 \\( \pi \\) 不仅是数学上的挑战，也常被用来测试计算机的性能。

1.  **Dear Haydy, / Sincerely, The FlowDown Team:** 保持了标准商务信函的开头和结尾格式。
2.  **rather unique proposal:** 译为“相当独特的提议”，保留了原文略带委婉语气的评价。
3.  **priced at $19.99:** 保留了价格和货币符号 `$19.99`。
4.  **pre-compiled, ready-to-install version:** 译为“预编译、即装即用版本”，准确传达其便利性。
5.  **immensely proud:** 译为“非常自豪”，表达了强烈的积极情感。
6.  **open-source and freely available:** 译为“开源且免费提供”，清晰明了。
7.  **technical inclination:** 译为“技术意愿”，指有能力和兴趣去操作。
8.  **incurs no monetary cost:** 译为“不产生任何费用”，比直译“不招致货币成本”更自然。

**初中部分 (七年级到九年级)**

*   **代数：**
    *   **乘法公式：**
        *   完全平方公式：$(a+b)^2 = a^2 + 2ab + b^2$，$(a-b)^2 = a^2 - 2ab + b^2$
        *   平方差公式：$a^2 - b^2 = (a+b)(a-b)$
    *   **一元一次方程**
    *   **一元二次方程：**
        *   求根公式：对于方程 $ax^2 + bx + c = 0$ ($a \neq 0$)，根为 $x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$
        *   判别式：$\Delta = b^2 - 4ac$
            *   $\Delta > 0$，方程有两个不相等的实数根
            *   $\Delta = 0$，方程有两个相等的实数根
            *   $\Delta < 0$，方程没有实数根

三角函数的定理有很多种，以下是几个常见定理及其证明思路的简要说明：

### 1. **毕达哥拉斯定理（勾股定理）**
   \\( \sin^2 \theta + \cos^2 \theta = 1 \\)
   **证明**：  
   利用单位圆定义，设角 \\( \theta \\) 的终边与单位圆交于点 \\( (x, y) \\)，则 \\( x = \cos \theta \\), \\( y = \sin \theta \\)。根据圆的方程 \\( x^2 + y^2 = 1 \\)，直接代入即得。

### 2. **和角公式**
   \\( \sin(a + b) = \sin a \cos b + \cos a \sin b \\)  
   **证明**：  
   - **几何法**：通过构造两个角叠加的三角形，利用面积或投影关系推导。  
   - **复数法**：用欧拉公式 \\( e^{i(a+b)} = e^{ia} e^{ib} \\) 展开后比较虚部。

### 3. **正弦定理**
   \\( \frac{a}{\sin A} = \frac{b}{\sin B} = \frac{c}{\sin C} = 2R \\)（\\( R \\) 为外接圆半径）  
   **证明**：  
   通过三角形的高或外接圆性质，将边与角的正弦关系转化为直径的表达式。

### 4. **余弦定理**
   \\( c^2 = a^2 + b^2 - 2ab \cos C \\)  
   **证明**：  
   - **坐标法**：将三角形顶点置于坐标系中，用距离公式展开。  
   - **向量法**：利用向量点积的性质 \\( \vec{c} \cdot \vec{c} = (\vec{a} - \vec{b})^2 \\)。

### 5. **万能公式（万能代换）**
   \\( \sin \theta = \frac{2t}{1 + t^2} \\), \\( \cos \theta = \frac{1 - t^2}{1 + t^2} \\)（其中 \\( t = \tan \frac{\theta}{2} \\)）  
   **证明**：  
   通过半角的正切定义，结合三角恒等式推导。

如果需要具体某个定理的详细证明步骤或更多定理，可以告诉我，我会进一步展开！

"""###
