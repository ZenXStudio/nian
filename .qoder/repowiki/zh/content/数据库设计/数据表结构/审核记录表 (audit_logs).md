# 审核记录表 (audit_logs)

<cite>
**本文档引用文件**   
- [init.sql](file://database/init.sql#L109-L124)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L266-L387)
- [admin.routes.ts](file://backend/src/routes/admin.routes.ts#L42-L45)
</cite>

## 目录
1. [引言](#引言)
2. [核心字段协同工作机制](#核心字段协同工作机制)
3. [外键策略与历史记录保留](#外键策略与历史记录保留)
4. [状态变更轨迹重构](#状态变更轨迹重构)
5. [索引优化与查询效率](#索引优化与查询效率)
6. [合规性审查与操作回溯价值](#合规性审查与操作回溯价值)

## 引言
审核记录表（audit_logs）是心理自助应用系统中内容审核流程的核心审计追踪组件。该表系统性地记录了心理自助方法从创建到发布的全生命周期中的关键操作，为内容管理提供了完整的操作历史和审计能力。通过精确记录每次审核操作的上下文信息，该表不仅支持操作回溯和责任认定，还为合规性审查提供了可靠的数据基础。

## 核心字段协同工作机制
审核记录表通过多个关键字段的协同工作，完整记录了内容审核过程中的操作细节和状态变化。

**audit_logs表字段说明**
| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| method_id | INT | REFERENCES methods(id) ON DELETE SET NULL | 关联的心理自助方法ID，外键删除时设为NULL以保留历史记录 |
| admin_id | INT | REFERENCES admins(id) ON DELETE SET NULL | 执行操作的管理员ID，外键删除时设为NULL以保留历史记录 |
| action | VARCHAR(20) | NOT NULL, CHECK IN ('submit', 'approve', 'reject') | 操作类型：提交审核、批准发布或拒绝修改 |
| status_before | VARCHAR(20) |  | 操作前的内容状态 |
| status_after | VARCHAR(20) |  | 操作后的内容状态 |
| comment | TEXT |  | 审核意见或拒绝原因 |
| created_at | TIMESTAMP | DEFAULT NOW() | 记录创建时间 |

**Section sources**
- [init.sql](file://database/init.sql#L110-L119)

## 外键策略与历史记录保留
审核记录表采用ON DELETE SET NULL外键策略，在保留历史记录方面具有显著优势。

```mermaid
erDiagram
audit_logs ||--o{ methods : "method_id"
audit_logs ||--o{ admins : "admin_id"
methods {
id INT PK
title VARCHAR
status VARCHAR
}
admins {
id INT PK
username VARCHAR
role VARCHAR
}
audit_logs {
id INT PK
method_id INT FK
admin_id INT FK
action VARCHAR
status_before VARCHAR
status_after VARCHAR
comment TEXT
created_at TIMESTAMP
}
```

**Diagram sources **
- [init.sql](file://database/init.sql#L112-L113)

当关联的心理自助方法或管理员被删除时，ON DELETE SET NULL策略确保审核日志记录不会被级联删除。这种设计保证了即使原始数据被移除，审核历史仍然完整保留，这对于长期审计和合规性要求至关重要。例如，即使某个管理员账号被注销，其过去执行的所有审核操作仍可在审计日志中追溯。

**Section sources**
- [init.sql](file://database/init.sql#L112-L113)

## 状态变更轨迹重构
通过action和status字段的组合，可以精确重构内容的状态变更轨迹。

```mermaid
stateDiagram-v2
[*] --> draft
draft --> pending : submit
pending --> published : approve
pending --> draft : reject
published --> [*]
note right of submit
method_id, admin_id,
action='submit',
status_before='draft',
status_after='pending'
end note
note right of approve
method_id, admin_id,
action='approve',
status_before='pending',
status_after='published',
comment='内容质量优秀'
end note
note left of reject
method_id, admin_id,
action='reject',
status_before='pending',
status_after='draft',
comment='需要补充实践步骤'
end note
```

**Diagram sources **
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L286-L288)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L330-L332)
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L377-L379)

action字段记录操作类型（submit/approve/reject），而status_before和status_after字段记录操作前后的状态变化。这种设计使得系统能够重建任何心理自助方法的完整审核历史。例如，通过查询特定method_id的所有审核记录，可以清晰地看到该方法从草稿（draft）到待审核（pending）再到发布（published）的完整流程。

**Section sources**
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L285-L387)

## 索引优化与查询效率
idx_audit_logs_created_at索引显著提升了审核日志的查询效率。

```mermaid
flowchart TD
A["查询审核日志\nGET /api/admin/audit-logs\n?start_date=2024-01-01\n&end_date=2024-01-31"] --> B["使用idx_audit_logs_created_at索引"]
B --> C["快速定位时间范围内的记录"]
C --> D["返回审核日志列表"]
E["查询特定方法的审核历史\nGET /api/admin/methods/123/audit-logs"] --> F["使用idx_audit_logs_method_id索引"]
F --> G["快速定位特定方法的记录"]
G --> H["返回方法审核历史"]
I["查询特定管理员的操作记录\nGET /api/admin/admins/456/audit-logs"] --> J["使用idx_audit_logs_admin_id索引"]
J --> K["快速定位特定管理员的记录"]
K --> L["返回管理员操作记录"]
```

**Diagram sources **
- [init.sql](file://database/init.sql#L123)
- [init.sql](file://database/init.sql#L121)
- [init.sql](file://database/init.sql#L122)

该表创建了三个关键索引：idx_audit_logs_method_id、idx_audit_logs_admin_id和idx_audit_logs_created_at。其中，按创建时间的索引对于按时间范围查询审核日志特别重要。在进行月度审核报告或特定时间段的合规性审查时，该索引能够大幅减少查询时间，确保系统在处理大量审核记录时仍能保持良好的响应性能。

**Section sources**
- [init.sql](file://database/init.sql#L121-L123)

## 合规性审查与操作回溯价值
审核记录表在合规性审查和操作回溯中具有关键价值。

```mermaid
graph TD
A[内容审核流程] --> B[提交审核]
B --> C[审核通过]
C --> D[内容发布]
A --> E[审核拒绝]
E --> F[修改完善]
F --> B
B --> G[记录submit操作]
C --> H[记录approve操作]
E --> I[记录reject操作]
G --> J[审核日志存储]
H --> J
I --> J
J --> K[合规性审查]
J --> L[操作回溯]
J --> M[责任认定]
J --> N[流程优化]
K --> O[满足监管要求]
L --> P[问题根源分析]
M --> Q[明确操作责任]
N --> R[改进审核流程]
```

**Diagram sources **
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L285-L387)
- [admin.routes.ts](file://backend/src/routes/admin.routes.ts#L42-L45)

该表为系统提供了完整的操作审计能力。在合规性审查中，可以提供所有内容变更的完整记录，证明内容发布流程的规范性和可追溯性。在操作回溯方面，当出现内容争议或质量问题时，可以通过审核日志追溯到具体的审核决策过程，包括决策人、决策时间和决策依据（comment字段）。这种透明的审计追踪机制不仅增强了系统的可信度，也为持续改进内容审核流程提供了数据支持。

**Section sources**
- [admin.controller.ts](file://backend/src/controllers/admin.controller.ts#L266-L387)
- [admin.routes.ts](file://backend/src/routes/admin.routes.ts#L42-L45)