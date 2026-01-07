# 通用UI组件库

<cite>
**本文档引用的文件**
- [app_button.dart](file://flutter_app/lib/presentation/widgets/app_button.dart)
- [app_card.dart](file://flutter_app/lib/presentation/widgets/app_card.dart)
- [app_text_field.dart](file://flutter_app/lib/presentation/widgets/app_text_field.dart)
- [method_card.dart](file://flutter_app/lib/presentation/widgets/method_card.dart)
- [practice_card.dart](file://flutter_app/lib/presentation/widgets/practice_card.dart)
- [stat_card.dart](file://flutter_app/lib/presentation/widgets/stat_card.dart)
- [loading_indicator.dart](file://flutter_app/lib/presentation/widgets/loading_indicator.dart)
- [error_widget.dart](file://flutter_app/lib/presentation/widgets/error_widget.dart)
- [empty_state.dart](file://flutter_app/lib/presentation/widgets/empty_state.dart)
- [method.dart](file://flutter_app/lib/domain/entities/method.dart)
- [practice_record.dart](file://flutter_app/lib/domain/entities/practice_record.dart)
- [theme.dart](file://flutter_app/lib/config/theme.dart)
- [method_discover_page.dart](file://flutter_app/lib/presentation/methods/pages/method_discover_page.dart)
</cite>

## 目录
1. [简介](#简介)
2. [基础控件](#基础控件)
3. [业务卡片组件](#业务卡片组件)
4. [状态指示组件](#状态指示组件)
5. [组件设计原则](#组件设计原则)
6. [组件扩展与常见问题](#组件扩展与常见问题)

## 简介
本项目包含一套完整的通用UI组件库，旨在为心理自助应用提供统一、可复用的界面元素。组件库分为三大类：基础控件（app_button.dart、app_card.dart、app_text_field.dart）提供基本的交互元素；业务卡片组件（method_card.dart、practice_card.dart、stat_card.dart）用于展示特定业务数据；状态指示组件（loading_indicator.dart、error_widget.dart、empty_state.dart）处理各种应用状态的视觉呈现。所有组件都遵循统一的设计语言，支持主题适配，并通过合理的抽象提高了代码的可维护性和可复用性。

## 基础控件

### AppButton 组件
`AppButton` 是应用中的通用按钮组件，提供统一的样式和交互行为。该组件支持多种类型（主要、次要、边框、文本、危险），可根据不同场景选择合适的样式。按钮支持加载状态、图标显示、全宽模式等特性，确保在各种使用场景下都能提供一致的用户体验。

**属性定义**
- `text`: 按钮显示的文本内容
- `onPressed`: 点击回调函数
- `isLoading`: 是否处于加载状态
- `isFullWidth`: 是否全宽显示
- `type`: 按钮类型（AppButtonType枚举）
- `icon`: 可选的前置图标
- `height`: 自定义高度
- `padding`: 自定义内边距

**样式定制**
按钮样式通过 `ButtonStyle` 进行配置，根据不同的 `AppButtonType` 枚举值应用相应的视觉样式。主要按钮使用主题主色填充，次要按钮使用主题次色，边框按钮和文本按钮则提供更轻量的视觉表现。危险按钮使用红色调，用于警示性操作。

**交互行为**
当 `isLoading` 为 `true` 时，按钮进入加载状态，禁用点击并显示加载动画。按钮的点击热区通过 `SizedBox` 包裹确保足够大，提升移动端的触摸体验。全宽模式下按钮会占据父容器的全部宽度，适用于表单提交等场景。

**Section sources**
- [app_button.dart](file://flutter_app/lib/presentation/widgets/app_button.dart#L1-L200)

### AppCard 组件
`AppCard` 是统一样式的卡片容器，用于组织和展示相关内容。该组件基于Material Design的Card组件构建，提供一致的圆角、阴影和内边距，是构建列表项和信息模块的基础。

**属性定义**
- `child`: 卡片内容
- `padding`: 内边距
- `margin`: 外边距
- `onTap`: 点击回调
- `borderRadius`: 圆角半径
- `color`: 背景色

**样式定制**
卡片默认使用12dp的圆角半径和8dp的内边距，外边距为8dp。当设置 `onTap` 回调时，组件会自动包装 `InkWell` 以提供水波纹点击效果，同时保持圆角的完整性。背景色可自定义，适用于不同主题场景。

**交互行为**
当 `onTap` 不为空时，卡片变为可点击状态，提供水波纹反馈。点击区域与卡片视觉边界一致，确保良好的用户体验。卡片的 `InkWell` 使用与卡片相同的圆角半径，避免水波纹超出视觉边界。

**Section sources**
- [app_card.dart](file://flutter_app/lib/presentation/widgets/app_card.dart#L1-L47)

### AppTextField 组件
`AppTextField` 是应用中的通用输入框组件，提供统一的样式和验证功能。该组件封装了 `TextFormField`，简化了表单输入的开发工作，同时保持了足够的灵活性。

**属性定义**
- `controller`: 文本控制器
- `label`: 标签文本
- `hint`: 提示文本
- `errorText`: 错误文本
- `obscureText`: 是否为密码输入
- `keyboardType`: 键盘类型
- `textInputAction`: 输入动作
- `maxLines`: 最大行数
- `maxLength`: 最大长度
- `enabled`: 是否启用
- `readOnly`: 是否只读
- `prefixIcon`: 前置图标
- `suffixIcon`: 后置图标
- `onSuffixIconPressed`: 后置图标点击回调
- `validator`: 验证函数
- `onChanged`: 文本变化回调
- `onSubmitted`: 提交回调
- `focusNode`: 焦点节点
- `inputFormatters`: 输入格式化器
- `autofocus`: 是否自动聚焦

**样式定制**
输入框使用8dp的圆角边框，启用状态下边框颜色为主题分割线颜色，聚焦时边框颜色为主题主色且宽度增加。错误状态下边框颜色为错误色。背景色在启用时为主题表面色，禁用时为半透明的禁用色。

**交互行为**
对于密码输入框，组件自动添加可见性切换图标，用户点击可切换密码的显示与隐藏。自定义后置图标也可通过 `suffixIcon` 和 `onSuffixIconPressed` 属性实现。输入框的 `filled` 属性为 `true`，提供填充式外观。

**Section sources**
- [app_text_field.dart](file://flutter_app/lib/presentation/widgets/app_text_field.dart#L1-L231)

## 业务卡片组件

### MethodCard 组件
`MethodCard` 是方法卡片组件，用于展示心理自助方法的信息。该组件基于 `Method` 实体构建，通过合理的布局展示方法的关键信息，是方法列表页面的核心展示单元。

**布局结构**
卡片采用水平布局，左侧为80x80的封面图区域，右侧为信息区域。信息区域包含方法名称、描述和信息标签（难度、时长等）。整体布局使用 `Row` 和 `Column` 组合实现，确保在不同屏幕尺寸下都能良好显示。

**数据绑定**
组件接收 `Method` 实体作为数据源，通过属性绑定展示相关信息。封面图使用 `Image.network` 加载网络图片，同时提供错误处理和占位图标。信息标签使用自定义的 `_buildInfoChip` 方法生成，确保样式统一。

**交互行为**
卡片包装了 `InkWell` 组件，提供点击交互。点击后会触发 `onTap` 回调，通常用于跳转到方法详情页面。水波纹效果的圆角与卡片一致，提供完整的视觉反馈。

**Section sources**
- [method_card.dart](file://flutter_app/lib/presentation/widgets/method_card.dart#L1-L120)
- [method.dart](file://flutter_app/lib/domain/entities/method.dart#L1-L77)

### PracticeCard 组件
`PracticeCard` 是练习记录卡片组件，用于展示用户的练习记录。该组件基于 `PracticeRecord` 实体构建，重点展示练习前后的心理状态变化。

**布局结构**
卡片采用垂直布局，顶部为方法名称和练习时间，中间为练习时长，底部为心理状态评分对比。心理状态使用线性进度条可视化展示，直观体现练习效果。如果有备注，会在底部显示备注区域。

**数据绑定**
组件接收 `PracticeRecord` 实体作为数据源，关联的 `Method` 信息可选。心理状态评分（1-10分）通过 `_getMoodColor` 方法转换为相应的颜色（红-橙-绿），反映情绪状态。时间格式化通过 `_formatTime` 方法实现。

**交互行为**
卡片同样包装了 `InkWell` 组件，提供点击交互。点击后会触发 `onTap` 回调，通常用于查看练习记录详情。卡片的视觉层次清晰，重要信息（心理状态变化）得到突出展示。

**Section sources**
- [practice_card.dart](file://flutter_app/lib/presentation/widgets/practice_card.dart#L1-L174)
- [practice_record.dart](file://flutter_app/lib/domain/entities/practice_record.dart#L1-L67)

### StatCard 组件
`StatCard` 是统计数据卡片，用于展示关键指标。该组件设计简洁，突出显示数值和图标，适用于仪表盘等数据概览场景。

**布局结构**
卡片采用垂直居中布局，从上到下依次为图标、数值和标题。图标使用主题主色或自定义颜色，数值使用较大的字号和粗体突出显示，标题使用较小的字号和灰色显示。

**数据绑定**
组件接收标题、数值、图标和可选颜色作为属性。颜色可自定义，若未指定则使用主题主色。这种设计使得组件既可使用主题色保持一致性，又可自定义颜色用于特定场景。

**交互行为**
卡片支持点击交互，通过 `onTap` 属性实现。水波纹效果的圆角与卡片一致，提供良好的触觉反馈。卡片的简洁设计使其在网格布局中能有效展示多个关键指标。

**Section sources**
- [stat_card.dart](file://flutter_app/lib/presentation/widgets/stat_card.dart#L1-L66)

## 状态指示组件

### LoadingIndicator 组件
`LoadingIndicator` 是加载指示器组件，提供统一的加载动画样式。该组件包含多种变体，满足不同场景的加载指示需求。

**适用场景**
- `LoadingIndicator`: 中心化的加载指示器，适用于页面或模块的加载状态
- `LoadingOverlay`: 全屏加载覆盖层，遮挡内容并显示加载状态
- `LinearLoadingIndicator`: 线性加载指示器，通常置于页面顶部
- `ShimmerPlaceholder`: 骨架屏占位符，用于内容加载时的占位
- `SkeletonPlaceholder`: 简单的骨架屏占位符，用于特定元素的占位

**集成方法**
这些组件可直接在需要的地方使用。`LoadingOverlay` 通过 `Stack` 叠加在内容之上，当 `isLoading` 为 `true` 时显示。`ShimmerPlaceholder` 使用动画实现渐变效果，模拟内容加载的视觉感受。

**Section sources**
- [loading_indicator.dart](file://flutter_app/lib/presentation/widgets/loading_indicator.dart#L1-L196)

### ErrorWidget 组件
`ErrorWidget` 是错误显示组件，用于展示错误信息和重试操作。该组件提供多种预设的错误类型，简化错误处理的开发工作。

**适用场景**
- `AppErrorWidget`: 通用错误组件，可自定义消息、图标和重试按钮
- `NetworkErrorWidget`: 网络连接失败的专用组件
- `ServerErrorWidget`: 服务器错误的专用组件
- `UnauthorizedErrorWidget`: 未授权访问的专用组件
- `ErrorBanner`: 错误提示横幅，通常置于页面顶部

**集成方法**
错误组件通常与状态管理结合使用。当业务逻辑出现错误时，显示相应的错误组件，并提供重试操作。`ErrorBanner` 可与其他内容并存，不影响主要功能的使用。

**Section sources**
- [error_widget.dart](file://flutter_app/lib/presentation/widgets/error_widget.dart#L1-L170)

### EmptyState 组件
`EmptyState` 是空状态组件，用于显示无数据时的占位界面。该组件提供多种预设的空状态，引导用户进行下一步操作。

**适用场景**
- `EmptyState`: 通用空状态组件
- `NoSearchResults`: 搜索无结果的专用组件
- `NoMethodsState`: 无方法数据的专用组件
- `NoPracticeRecordsState`: 无练习记录的专用组件
- `NoFavoritesState`: 收藏夹空状态的专用组件

**集成方法**
空状态组件通常在数据列表为空时显示。除了显示图标和消息外，还可提供操作按钮（如"开始练习"、"浏览方法"），引导用户进行相关操作，提升用户体验。

**Section sources**
- [empty_state.dart](file://flutter_app/lib/presentation/widgets/empty_state.dart#L1-L171)

## 组件设计原则

### 可复用性
所有组件都设计为高度可复用的独立单元。通过合理的属性定义，组件可以在不同场景下灵活使用。例如，`AppButton` 的 `type` 属性使其能适应各种按钮场景，而无需创建多个相似的按钮组件。

### 可维护性
组件遵循单一职责原则，每个组件只负责一个特定的UI功能。代码结构清晰，注释完整，便于后续维护。样式与逻辑分离，修改视觉样式不会影响组件的核心行为。

### 响应式支持
所有组件都考虑了不同屏幕尺寸的适配。使用 `Expanded`、`Flexible` 等布局组件确保在小屏幕上也能良好显示。字体大小、间距等都使用相对单位，适应不同设备的显示需求。

### 无障碍访问
组件遵循无障碍设计原则。按钮和可点击元素有足够的点击热区，文本有足够的对比度，图标配合文字使用确保信息传达。语义化标签的使用使屏幕阅读器能正确识别组件功能。

**Section sources**
- [app_button.dart](file://flutter_app/lib/presentation/widgets/app_button.dart#L1-L200)
- [app_card.dart](file://flutter_app/lib/presentation/widgets/app_card.dart#L1-L47)
- [app_text_field.dart](file://flutter_app/lib/presentation/widgets/app_text_field.dart#L1-L231)

## 组件扩展与常见问题

### 点击热区不足
对于小的可点击元素（如图标按钮），应使用 `SizedBox` 或 `Padding` 扩大点击区域。`AppIconButton` 组件已内置此优化，确保24x24的最小点击热区。

### 文本溢出截断
长文本应使用 `TextOverflow.ellipsis` 进行截断，并设置 `maxLines` 限制行数。这在 `MethodCard` 和 `PracticeCard` 中都有应用，确保界面布局的稳定性。

### 主题颜色冲突
组件应优先使用主题定义的颜色（如 `Theme.of(context).primaryColor`），而非硬编码颜色值。`theme.dart` 文件中定义了统一的主题颜色，确保整个应用的视觉一致性。

### 组件扩展指南
如需扩展组件功能，建议遵循现有设计模式。对于基础控件，可通过添加新属性来支持新功能；对于业务组件，可创建新的专用组件（如已有的 `NoSearchResults` 基于 `EmptyState` 扩展）。

**Section sources**
- [theme.dart](file://flutter_app/lib/config/theme.dart#L1-L77)
- [method_discover_page.dart](file://flutter_app/lib/presentation/methods/pages/method_discover_page.dart#L1-L449)