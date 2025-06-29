//
//  TestDocument.swift
//  Example
//
//  Created by 秋星桥 on 6/29/25.
//

import Foundation

let testDocument = ###"""
### 麦克斯韦方程组 (Maxwell's Equations)

这组方程是经典电磁学的核心，优美地描述了电场、磁场与电荷、电流之间的关系。它们以微分形式写出来时，充满了各种奇妙的数学符号，非常酷炫！

#### 最终效果

\\[
\begin{cases}
\nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0} \\\\
\nabla \cdot \mathbf{B} = 0 \\\\
\nabla \times \mathbf{E} = -\frac{\partial \mathbf{B}}{\partial t} \\\\
\nabla \times \mathbf{B} = \mu_0 \left( \mathbf{J} + \varepsilon_0 \frac{\partial \mathbf{E}}{\partial t} \right)
\end{cases}
\\]

#### 公式解读

这四个方程分别是：
1.  **高斯电场定律 (Gauss's law for electricity):** 电荷如何产生电场。
2.  **高斯磁场定律 (Gauss's law for magnetism):** 磁单极子不存在。
3.  **法拉第电磁感应定律 (Faraday's law of induction):** 变化的磁场如何产生电场。
4.  **安培-麦克斯韦定律 (Ampère-Maxwell's circuital law):** 电流和变化的电场如何产生磁场。

#### LaTeX 源码

```latex
\\[
\begin{cases}
\nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0} \\\\
\nabla \cdot \mathbf{B} = 0 \\\\
\nabla \times \mathbf{E} = -\frac{\partial \mathbf{B}}{\partial t} \\\\
\nabla \times \mathbf{B} = \mu_0 \left( \mathbf{J} + \varepsilon_0 \frac{\partial \mathbf{E}}{\partial t} \right)
\end{cases}
\\]
```
"""###
