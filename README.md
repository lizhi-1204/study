# study-integral-system

## 本地启动（docker-compose）

1. 启动依赖：
   - `docker compose up -d --build`
2. 后端健康接口：
   - `curl http://localhost:8080/api/v1/health`

## 关键配置

后端使用以下环境变量覆盖配置：
- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`

时区统一使用 `Asia/Shanghai`，保证“北京时间”口径与业务一致。

