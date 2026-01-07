# 心理自助方法表 (methods)

<cite>
**本文档引用的文件**   
- [init.sql](file://database/init.sql#L19-L36)
- [method.controller.ts](file://backend/src/controllers/method.controller.ts#L75-L98)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L130-L373)
- [method.routes.ts](file://backend/src/routes/method.routes.ts#L1-L20)
- [MethodEdit.tsx](file://home/user/nian/admin-web/src/pages/MethodEdit.tsx#L240-L393)
- [MethodApproval.tsx](file://home/user/nian/admin-web/src/pages/MethodApproval.tsx#L1-L200)
- [method_model.dart](file://flutter_app/lib/data/models/method_model.dart#L1-L54)
- [method.dart](file://flutter_app/lib/domain/entities/method.dart#L1-L77)
</cite>

## 目录
1. [引言](#引言)
2. [核心字段设计](#核心字段设计)
3. [content_json 字段的灵活性优势](#content_json-字段的灵活性优势)
4. [status 字段的状态机设计](#status-字段的状态机设计)
5. [updated_at 自动更新机制](#updated_at-自动更新机制)
6. [字段使用与业务流程](#字段使用与业务流程)
7. [总结](#总结)

## 引言
心理自助方法表（methods）是本系统的核心数据表之一，用于存储各种心理自助方法的详细信息。该表设计精良，涵盖了方法的标题、描述、分类、难度、时长、封面图片、内容、状态、统计信息、创建者、创建时间、更新时间和发布时间等关键字段。本文档将深入分析该表的设计细节，重点说明content_json字段使用JSONB类型存储结构化内容的灵活性优势，以及status字段的状态机设计。同时，结合触发器update_methods_updated_at，解释updated_at自动更新机制的实现原理及其在内容管理中的审计价值。

**Section sources**
- [init.sql](file://database/init.sql#L19-L36)

## 核心字段设计
心理自助方法表（methods）包含以下核心字段：

- **id**: 主键，自增序列。
- **title**: 方法标题，VARCHAR(50)，非空。
- **description**: 方法描述，VARCHAR(200)，非空。
- **category**: 分类，VARCHAR(50)，非空。
- **difficulty**: 难度，VARCHAR(20)，非空。
- **duration_minutes**: 建议时长（分钟），INT，非空。
- **cover_image_url**: 封面图片URL，VARCHAR(255)。
- **content_json**: 方法内容，JSONB，非空。
- **status**: 状态，VARCHAR(20)，默认值为'draft'。
- **view_count**: 浏览次数，INT，默认值为0。
- **select_count**: 选择次数，INT，默认值为0。
- **created_by**: 创建者ID，INT，外键引用users表。
- **created_at**: 创建时间，TIMESTAMP，默认值为NOW()。
- **updated_at**: 更新时间，TIMESTAMP，默认值为NOW()。
- **published_at**: 发布时间，TIMESTAMP。

这些字段共同构成了心理自助方法的完整信息模型，支持从内容创作、审核发布到用户使用的全生命周期管理。

**Section sources**
- [init.sql](file://database/init.sql#L19-L36)

## content_json 字段的灵活性优势
`content_json` 字段采用 PostgreSQL 的 `JSONB` 数据类型，这是其设计中最显著的灵活性优势所在。`JSONB` 类型允许在单个字段中存储半结构化的 JSON 数据，而无需预先定义固定的表结构。

### 灵活性优势分析
1.  **动态内容结构**：心理自助方法的内容结构可能非常多样，例如“深呼吸放松法”包含“准备阶段”和“练习步骤”两个章节，而“情绪日记”则包含“如何记录”章节和“情绪评估”问卷。使用 `JSONB` 字段，可以轻松地为每种方法定义不同的内容结构，如示例数据所示，可以包含 `chapters`（章节）、`exercises`（练习）和 `questionnaires`（问卷）等不同类型的子结构。
2.  **易于扩展**：当需要为方法添加新的内容类型（如音频引导、视频教程或互动练习）时，只需在 `content_json` 的 JSON 结构中添加新的键值对，而无需修改数据库表结构（ALTER TABLE），这极大地降低了系统升级和维护的成本。
3.  **高效的查询与索引**：PostgreSQL 对 `JSONB` 提供了强大的原生支持。可以使用 `->` 和 `->>` 操作符来查询 JSON 内部的特定字段。例如，可以查询包含特定章节标题的方法。此外，还可以在 `JSONB` 字段上创建 GIN 索引，以加速对 JSON 内容的搜索，这对于实现内容搜索功能至关重要。
4.  **与应用层无缝集成**：在后端（TypeScript）和前端（Dart）代码中，`content_json` 被映射为 `any` 或 `Map<String, dynamic>` 类型，这与 JSON 数据的天然结构完全匹配。应用层可以方便地将对象序列化为 JSON 存储，或从 JSON 反序列化为对象使用，无需复杂的 ORM 映射。

**Section sources**
- [init.sql](file://database/init.sql#L28)
- [method_model.dart](file://flutter_app/lib/data/models/method_model.dart#L15)
- [method.dart](file://flutter_app/lib/domain/entities/method.dart#L35)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L139)

## status 字段的状态机设计
`status` 字段是方法内容生命周期管理的核心，它实现了一个简单而有效的状态机，包含 `draft`（草稿）、`pending`（待审核）、`published`（已发布）和 `archived`（已归档）四种状态。

### 状态机流程与实现
1.  **初始状态 (draft)**：当管理员通过 `createMethod` 接口创建一个新方法时，其状态被初始化为 `draft`。此时，该方法仅对管理员可见，普通用户无法访问。
2.  **提交审核 (draft -> pending)**：管理员完成草稿编辑后，调用 `submitForReview` 接口。后端执行 `UPDATE methods SET status = 'pending' WHERE id = $1 AND status = 'draft'`，将状态从 `draft` 变更为 `pending`。此操作有严格的条件检查，确保只有草稿状态的方法才能被提交。
3.  **审核通过 (pending -> published)**：超级管理员在 `MethodApproval` 页面审核通过后，调用 `approveMethod` 接口。后端执行 `UPDATE methods SET status = 'published', published_at = NOW() WHERE id = $1 AND status = 'pending'`，将状态变更为 `published`，并设置 `published_at` 时间戳。此后，该方法对所有用户可见。
4.  **审核拒绝 (pending -> draft)**：如果审核不通过，超级管理员调用 `rejectMethod` 接口。后端执行 `UPDATE methods SET status = 'draft' WHERE id = $1 AND status = 'pending'`，将方法状态打回 `draft`，供内容创建者修改。
5.  **已发布 (published)**：这是方法的最终可用状态。前端 `getMethods` 和 `getMethodById` 接口在查询时，都通过 `WHERE status = 'published'` 来确保只返回已发布的方法。

这种状态机设计确保了内容发布的严谨性和安全性，防止了未审核内容的泄露。

**Section sources**
- [init.sql](file://database/init.sql#L29)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L275-L373)
- [MethodEdit.tsx](file://home/user/nian/admin-web/src/pages/MethodEdit.tsx#L371-L374)
- [MethodApproval.tsx](file://home/user/nian/admin-web/src/pages/MethodApproval.tsx#L116-L126)

## updated_at 自动更新机制
`updated_at` 字段的自动更新是通过 PostgreSQL 的触发器（Trigger）和函数（Function）实现的，这是数据库层面保证数据一致性和审计价值的关键机制。

### 实现原理
1.  **创建更新函数**：在 `init.sql` 文件中，首先定义了一个名为 `update_updated_at_column` 的函数。该函数是一个存储过程，其作用是将 `NEW.updated_at` 的值设置为当前时间 `NOW()`。
    ```sql
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
    END;
    $$ language 'plpgsql';
    ```
2.  **创建触发器**：接着，创建一个名为 `update_methods_updated_at` 的触发器。该触发器绑定在 `methods` 表上，触发时机为 `BEFORE UPDATE`（在更新操作执行前），触发范围为 `FOR EACH ROW`（对每一行生效）。
    ```sql
    CREATE TRIGGER update_methods_updated_at BEFORE UPDATE ON methods
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    ```
3.  **触发流程**：当任何 `UPDATE` 语句尝试修改 `methods` 表中的某一行时，触发器会先于该 `UPDATE` 语句执行。它会调用 `update_updated_at_column` 函数，将即将被更新的行（`NEW`）中的 `updated_at` 字段自动设置为当前时间，然后才执行原始的 `UPDATE` 操作。

### 审计价值
- **变更追踪**：`updated_at` 字段精确记录了每条方法记录最后一次被修改的时间。这对于内容运营至关重要，例如，前端可以按“最新更新”排序，向用户推荐最近优化过的方法。
- **数据一致性**：由数据库自动维护，避免了应用层代码可能因疏忽而忘记更新时间戳，保证了数据的可靠性。
- **简化应用逻辑**：应用层在执行更新操作时，无需手动设置 `updated_at` 字段，简化了业务代码。

**Section sources**
- [init.sql](file://database/init.sql#L302-L311)

## 字段使用与业务流程
以下流程图展示了 `methods` 表的核心字段如何在“创建、提交、审核、发布”这一典型业务流程中被使用。

```mermaid
flowchart TD
A[管理员创建方法] --> B[调用 createMethod API]
B --> C[数据库插入记录]
C --> D[设置: title, description, category, difficulty, duration_minutes, cover_image_url, content_json]
D --> E[设置: status='draft', created_at=NOW(), updated_at=NOW()]
E --> F[方法进入草稿状态]
F --> G[管理员提交审核]
G --> H[调用 submitForReview API]
H --> I[数据库更新状态]
I --> J[设置: status='pending', updated_at=NOW()]
J --> K[记录审核日志到 audit_logs]
K --> L[超级管理员审核]
L --> M{审核通过?}
M --> |是| N[调用 approveMethod API]
M --> |否| O[调用 rejectMethod API]
N --> P[数据库更新状态]
P --> Q[设置: status='published', published_at=NOW(), updated_at=NOW()]
Q --> R[方法对用户可见]
O --> S[数据库更新状态]
S --> T[设置: status='draft', updated_at=NOW()]
T --> U[方法返回草稿状态]
style A fill:#4CAF50, color:white
style R fill:#4CAF50, color:white
style U fill:#FF9800, color:white
```

**Diagram sources**
- [init.sql](file://database/init.sql#L21-L35)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L130-L373)

## 总结
心理自助方法表（methods）的设计体现了高内聚、低耦合和高扩展性的原则。`content_json` 字段利用 `JSONB` 类型的灵活性，完美适应了心理方法内容结构多变的需求。`status` 字段通过一个清晰的状态机，实现了从草稿到发布的严谨内容审核流程。`updated_at` 字段通过数据库触发器实现了自动更新，为内容管理和审计提供了可靠的时间依据。这些设计共同构建了一个健壮、灵活且易于维护的内容管理系统。

**Section sources**
- [init.sql](file://database/init.sql#L19-L36)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L130-L373)