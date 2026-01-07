# 心理自助应用 - 管理后台

基于 React + Ant Design + TypeScript + Vite 构建的现代化管理后台。

## 功能特性

- 🔐 管理员登录认证
- 📊 数据统计概览
- 📝 心理方法管理（CRUD）
- ✅ 内容审核流程
- 🔍 搜索和筛选
- 📱 响应式设计

## 技术栈

- React 18
- TypeScript
- Ant Design 5
- React Router 6
- Axios
- Vite

## 开发环境

### 安装依赖

```bash
npm install
```

### 启动开发服务器

```bash
npm run dev
```

访问 http://localhost:3001

### 构建生产版本

```bash
npm run build
```

## Docker 部署

### 构建镜像

```bash
docker build -t mental-app-admin .
```

### 运行容器

```bash
docker run -d -p 3001:80 mental-app-admin
```

## 项目结构

```
admin-web/
├── public/              # 静态资源
├── src/
│   ├── pages/          # 页面组件
│   │   ├── Login.tsx        # 登录页
│   │   ├── Dashboard.tsx    # 数据概览
│   │   ├── MethodList.tsx   # 方法列表
│   │   ├── MethodEdit.tsx   # 方法编辑
│   │   └── MethodApproval.tsx # 内容审核
│   ├── services/       # API 服务
│   │   └── api.ts
│   ├── utils/          # 工具函数
│   │   └── request.ts  # Axios 封装
│   ├── App.tsx         # 根组件
│   ├── App.css         # 全局样式
│   ├── main.tsx        # 入口文件
│   └── index.css       # 基础样式
├── index.html          # HTML 模板
├── vite.config.ts      # Vite 配置
├── tsconfig.json       # TypeScript 配置
├── package.json        # 项目依赖
├── Dockerfile          # Docker 配置
└── nginx.conf          # Nginx 配置
```

## 环境变量

开发环境下，API 代理已在 `vite.config.ts` 中配置：

```typescript
proxy: {
  '/api': {
    target: 'http://localhost:3000',
    changeOrigin: true,
  },
}
```

生产环境下，Nginx 会将 `/api` 请求代理到后端服务。

## API 接口

### 认证接口

- `POST /api/admin/login` - 管理员登录

### 统计接口

- `GET /api/admin/stats` - 获取统计数据

### 方法管理接口

- `GET /api/admin/methods` - 获取方法列表
- `GET /api/admin/methods/:id` - 获取方法详情
- `POST /api/admin/methods` - 创建方法
- `PUT /api/admin/methods/:id` - 更新方法
- `DELETE /api/admin/methods/:id` - 删除方法

### 审核接口

- `GET /api/admin/methods/pending` - 获取待审核方法
- `POST /api/admin/methods/:id/approve` - 审核通过
- `POST /api/admin/methods/:id/reject` - 审核拒绝

## 默认管理员账号

```
用户名: admin
密码: admin123
```

## 浏览器支持

- Chrome (最新版本)
- Firefox (最新版本)
- Safari (最新版本)
- Edge (最新版本)

## 许可证

MIT
