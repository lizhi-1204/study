# 微信云托管部署（后端 Docker 化）

本项目本机环境可能无法运行 `docker/java/mvn`，因此推荐直接把**后端 Dockerfile 构建**到微信云托管进行联调。

## 1. 准备上传的内容
建议上传（或打包成 zip 上传）以下目录/文件：
- `backend/`（包含 `Dockerfile`、`pom.xml`、`src/`）

不建议把根目录的 `.env` 一起上传（包含密码）。云托管请用环境变量填写。

## 2. 云托管创建服务
进入微信云托管控制台：
1. 新建服务（或环境）
2. 选择“容器服务 / Docker”
3. 选择“构建镜像”
4. Dockerfile 路径选择：`Dockerfile`（位于构建上下文的根目录）
5. 构建上下文（Build context）建议选择：`backend/`

> 若云托管只允许“固定上下文”，则需要把 `backend/Dockerfile` 复制/移动到该上下文根目录，或改用对应的构建方式。

## 3. 配置环境变量
在云托管容器配置里设置以下环境变量（按你的实际值填写）：
- `SPRING_DATASOURCE_URL`
  - 格式示例：`jdbc:mysql://sh-cynosdbmysql-grp-kmxoc9is.sql.tencentcdb.com:20982/study?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false`
- `SPRING_DATASOURCE_USERNAME`：`root`
- `SPRING_DATASOURCE_PASSWORD`：你的数据库密码
- `JWT_SECRET`：用于 JWT 签名的密钥
- `TZ`：`Asia/Shanghai`

## 4. 端口
- 容器暴露端口：`8080`
- 确保云托管对外暴露同一端口或提供了外部映射

## 5. 验证接口
部署完成后，云托管会给你一个公网域名/地址：
- `GET {你的域名}/api/v1/health`

返回：
`{"ok": true}`

## 6. 小程序配置
在微信开发者工具里：
1. 设置 `request 合法域名` 为云托管域名（带 https ）
2. 小程序后端域名的协议匹配 https

