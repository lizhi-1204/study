# API 文档（当前后端版本）

Base URL:
- 云托管：`https://<your-domain>`
- 本地：`http://localhost:8080`

统一前缀：
- `/api/v1`

## 1) 健康检查

### GET `/api/v1/health`
说明：服务存活探针

响应示例：
```json
{
  "ok": true
}
```

## 2) 认证接口

### POST `/api/v1/auth/parent/register`
说明：家长注册（并创建第一个孩子，注册成功自动返回家长 token）

请求体示例：
```json
{
  "username": "parent001",
  "password": "ParentPass123",
  "nickname": "小明妈妈",
  "avatarUrl": "https://example.com/parent.png",
  "securityQuestions": [
    { "order": 1, "question": "问题1", "answer": "答案1" },
    { "order": 2, "question": "问题2", "answer": "答案2" },
    { "order": 3, "question": "问题3", "answer": "答案3" }
  ],
  "firstChild": {
    "username": "child001",
    "password": "ChildPass123",
    "realName": "小明",
    "birthday": "2015-09-01",
    "nickname": "小明",
    "avatarUrl": "https://example.com/child.png"
  }
}
```

响应示例：
```json
{
  "token": "jwt-token",
  "parent": {
    "id": 1,
    "username": "parent001",
    "nickname": "小明妈妈",
    "avatarUrl": "https://example.com/parent.png"
  },
  "currentChild": {
    "id": 2,
    "username": "child001",
    "nickname": "小明",
    "avatarUrl": "https://example.com/child.png"
  },
  "children": [
    {
      "id": 2,
      "username": "child001",
      "nickname": "小明",
      "avatarUrl": "https://example.com/child.png"
    }
  ]
}
```

---

### POST `/api/v1/auth/parent/login`
说明：家长登录（当前服务层尚未实现，调用会返回未实现错误）

请求体示例：
```json
{
  "username": "parent001",
  "password": "ParentPass123"
}
```

---

### POST `/api/v1/auth/child/login`
说明：孩子登录（当前服务层尚未实现，调用会返回未实现错误）

请求体示例：
```json
{
  "username": "child001",
  "password": "ChildPass123"
}
```

---

### GET `/api/v1/auth/parent/password/security-questions?username=parent001`
说明：获取家长密保问题（当前服务层尚未实现）

---

### POST `/api/v1/auth/parent/password/verify-questions`
说明：验证密保答案并返回重置 token（当前服务层尚未实现）

请求体示例：
```json
{
  "username": "parent001",
  "answers": [
    { "order": 1, "answer": "答案1" },
    { "order": 2, "answer": "答案2" },
    { "order": 3, "answer": "答案3" }
  ]
}
```

响应示例：
```json
{
  "resetToken": "one-time-token",
  "expiresInSeconds": 600
}
```

---

### POST `/api/v1/auth/parent/password/reset`
说明：重置密码（当前服务层尚未实现）

请求体示例：
```json
{
  "username": "parent001",
  "resetToken": "one-time-token",
  "newPassword": "NewPass123"
}
```

响应示例：
```json
{
  "success": true
}
```

## 3) 说明

- 当前已完成真实逻辑的接口：`POST /api/v1/auth/parent/register`、`GET /api/v1/health`
- 其余认证接口路由已就绪，但服务层逻辑仍是占位实现（`UnsupportedOperationException`）
