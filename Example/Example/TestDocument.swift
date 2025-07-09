//
//  TestDocument.swift
//  Example
//
//  Created by 秋星桥 on 6/29/25.
//

import Foundation

let testDocument = ###"""
好的，这是一个非常重要且经常被问到的问题！

在 iOS 13 及更高版本中，`SceneDelegate` 不需要像 `AppDelegate` 那样显式地“注册”给 `App`。相反，系统通过 `Info.plist` 文件中的配置自动发现并使用 `SceneDelegate`。

---

### 通过 `Info.plist` 注册 `SceneDelegate`

当你创建一个新的 iOS 项目时，Xcode 会自动为你在 `Info.plist` 中添加必要的配置。这个配置告诉系统你的应用程序支持场景 (Scenes)，并且哪个类是你的 `SceneDelegate`。

主要涉及以下两个键：

1.  **`Application Scene Manifest` (`UISceneConfigurations`)**: 这是场景配置的根键。
2.  **`Scene Configuration` (`UISceneSessionRoleApplication`)**: 在 `Application Scene Manifest` 下，这个键指定了应用程序的场景角色。
3.  **`Delegate Class Name` (`UISceneDelegateClassName`)**: 在 `Scene Configuration` 下，这个键用于指定哪个类是该场景角色的委托（即你的 `SceneDelegate` 类名）。

---

#### 步骤和具体配置

1.  **打开你的 `Info.plist` 文件。** 你可以在项目导航器中找到它。
2.  **查找或添加 `Application Scene Manifest`。**
    *   在 `Info.plist` 中，右键点击空白处，选择 `Add Row`。
    *   输入 `Application Scene Manifest`，并将其类型设置为 `Dictionary`。
3.  **在 `Application Scene Manifest` 下添加 `Scene Configuration`。**
    *   在 `Application Scene Manifest` 下，点击旁边的 `+` 号。
    *   输入 `Scene Configuration`，并将其类型设置为 `Array`。
4.  **在 `Scene Configuration` 数组中添加一个 `Item 0` (Dictionary)。**
    *   这代表一个场景配置。
5.  **在 `Item 0` 下添加以下键值对：**
    *   **`Application Session Role` (`UISceneSessionRole`)**:
        *   **类型**: `String`
        *   **值**: `UIWindowSceneSessionRoleApplication` (这是默认的应用程序窗口场景角色)
    *   **`Delegate Class Name` (`UISceneDelegateClassName`)**:
        *   **类型**: `String`
        *   **值**: `$(PRODUCT_MODULE_NAME).SceneDelegate` 或直接 `SceneDelegate`
            *   `$(PRODUCT_MODULE_NAME)` 是一个占位符，它会在编译时替换为你的项目名称（即模块名称）。这是推荐的做法，因为它更灵活。
            *   如果你不使用 Swift 的命名空间，也可以直接写 `SceneDelegate`。
    *   **`Storyboard Name` (`UISceneStoryboardFile`) (可选)**:
        *   **类型**: `String`
        *   **值**: 你的主 Storyboard 文件名 (例如 `Main`)。
        *   如果你不使用 Storyboard，而是完全通过代码设置 UI，那么这个键可以省略。

---

#### 示例 `Info.plist` 结构 (XML 格式)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/> // 或者 true，取决于你是否支持多场景
        <key>UISceneConfigurations</key>
        <dict>
            <key>UIWindowSceneSessionRoleApplication</key>
            <array>
                <dict>
                    <key>UISceneConfigurationName</key>
                    <string>Default Configuration</string>
                    <key>UISceneDelegateClassName</key>
                    <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string> // 这里是关键
                    <key>UISceneStoryboardFile</key>
                    <string>Main</string> // 如果你使用 Storyboard
                </dict>
            </array>
        </dict>
    </dict>
    <!-- 其他 Info.plist 内容 -->
</dict>
</plist>
```

---

#### 总结

你不需要在代码中手动调用任何方法来“注册” `SceneDelegate`。系统会在应用启动时读取 `Info.plist` 中的 `Application Scene Manifest` 配置，并根据 `UISceneDelegateClassName` 键中指定的名字来实例化和管理你的 `SceneDelegate`。

你提供的初始代码中：

```swift
let delegate = AppDelegate()
UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    NSStringFromClass(Application.self),
    NSStringFromClass(AppDelegate.self)
)
```

`UIApplicationMain` 函数会负责应用程序的启动过程，它会读取 `Info.plist` 并初始化 `AppDelegate` 和 `SceneDelegate`。

所以，确保你的 `Info.plist` 配置正确即可。

假设我们找到了 \\(k\\) 个满足条件的平面。设这些平面的方程为：
\\[ L_j(x, y, z) = a_j x + b_j y + c_j z - d_j = 0 \quad \text{for } j = 1, \dots, k \\]
根据题意，原点 \\((0,0,0)\\) 不在任何一个平面上，这意味着 \\(L_j(0,0,0) = -d_j \neq 0\\)，所以 \\(d_j \neq 0\\) 对所有 \\(j\\) 成立。

---
现在，我们构造一个多项式 \\(P(x,y,z)\\) 如下：
\\[ P(x, y, z) = \prod_{j=1}^{k} L_j(x, y, z) \\]
这个多项式的次数 \\(\deg(P) = k\\)。

---

好的，没问题！这是一个简单的表格，包含一些示例数据。你可以告诉我你想要什么样的数据，或者表格有什么特定用途，我帮你画一个更合适的。

| 姓名   | 年龄 | 城市     | 职业   |
|--------|------|----------|--------|
| 张三   | 28   | 北京     | 工程师 |
| 李四   | 35   | 上海     | 医生   |
| 王五   | 22   | 广州     | 学生   |
| 赵六   | 40   | 深圳     | 教师   |

"""###
