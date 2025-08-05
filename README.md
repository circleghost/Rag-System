# RAG System with Nginx, Neo4j, and Graphiti

一個完整的 RAG (Retrieval-Augmented Generation) 系統，結合 Nginx 反向代理、Neo4j 圖形資料庫和 Graphiti RAG 引擎，支持本地開發和 Zeabur 雲端部署。

## 🏗️ 系統架構

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Nginx    │────│   Graphiti  │────│    Neo4j    │
│ (Port 80)   │    │ (Port 8000) │    │ (Port 7474) │
│             │    │             │    │ (Port 7687) │
└─────────────┘    └─────────────┘    └─────────────┘
      │                     │                   │
   HTTP/HTTPS          FastAPI REST       Graph Database
  Load Balancer         RAG Engine         Knowledge Store
```

### 核心組件

- **🔀 Nginx**: 反向代理和 Web 服務器，處理 HTTP/HTTPS 流量分發
- **🧠 Graphiti**: AI 驅動的 RAG 引擎，提供智能問答功能
- **📊 Neo4j**: 圖形資料庫，存儲和管理知識圖譜

## 🚀 快速開始

### 前置需求

- Docker 24.0.0+
- Docker Compose v2.26.1+
- 至少 4GB 可用內存
- 以下任一 API 金鑰：
  - OpenAI API Key
  - Anthropic API Key

### 1. 克隆專案

```bash
git clone <your-repo-url>
cd RAG
```

### 2. 配置環境變數

```bash
# 複製環境變數範例
cp .env.example .env

# 編輯 .env 文件，設置你的 API 金鑰
nano .env
```

**必須設置的變數：**
```env
OPENAI_API_KEY=your_openai_api_key_here
# 或者
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# 建議修改 Neo4j 密碼
NEO4J_PASSWORD=your_secure_password
```

### 3. 啟動系統

```bash
# 使用便捷腳本啟動
./scripts/start.sh

# 或手動啟動
docker-compose up -d
```

### 4. 驗證部署

系統啟動後，可通過以下端點訪問：

- 🌐 **主應用**: http://localhost
- 🔗 **Graphiti API**: http://localhost/api
- 💾 **Neo4j Browser**: http://localhost/browser
- 📊 **健康檢查**: http://localhost/health

## 📋 API 使用範例

### 健康檢查

```bash
curl http://localhost/health
```

### 查詢 RAG 系統

```bash
# 發送問題到 Graphiti
curl -X POST http://localhost/api/query \\
  -H "Content-Type: application/json" \\
  -d '{
    "query": "What is artificial intelligence?",
    "context": "general"
  }'
```

### Neo4j 圖資料庫查詢

```bash
# 通過 Neo4j HTTP API 查詢
curl -X POST http://localhost/db/data/transaction/commit \\
  -H "Content-Type: application/json" \\
  -H "Authorization: Basic bmVvNGo6Y2hhbmdlbWUxMjM=" \\
  -d '{
    "statements": [{
      "statement": "MATCH (n) RETURN count(n) as total_nodes"
    }]
  }'
```

## 🛠️ 開發和調試

### 查看服務狀態

```bash
docker-compose ps
```

### 查看日誌

```bash
# 查看所有服務日誌
docker-compose logs -f

# 查看特定服務日誌
docker-compose logs -f graphiti
docker-compose logs -f neo4j
docker-compose logs -f nginx
```

### 進入容器調試

```bash
# 進入 Graphiti 容器
docker-compose exec graphiti /bin/bash

# 進入 Neo4j 容器
docker-compose exec neo4j /bin/bash

# 進入 Nginx 容器
docker-compose exec nginx /bin/sh
```

### 重新啟動服務

```bash
# 重啟特定服務
docker-compose restart graphiti

# 重新構建並啟動
docker-compose up -d --build
```

## 🔧 配置選項

### Neo4j 配置

編輯 `docker-compose.yml` 中的 Neo4j 環境變數：

```yaml
environment:
  - NEO4J_server_memory_heap_initial__size=1G
  - NEO4J_server_memory_heap_max__size=4G
  - NEO4J_server_memory_pagecache_size=2G
```

### Nginx 配置

修改 `nginx/nginx.conf` 和 `nginx/default.conf` 來調整：

- 上游服務配置
- SSL 證書設置
- 緩存策略
- 安全標頭

### Graphiti 配置

在 `graphiti/config/` 目錄下添加配置文件來自定義：

- 模型參數
- 知識圖譜設置
- API 端點配置

## 🌐 Zeabur 雲端部署

### 自動部署

```bash
# 運行 Zeabur 部署腳本
./scripts/deploy-zeabur.sh
```

### 手動部署

1. **準備代碼庫**
   ```bash
   git add .
   git commit -m "Prepare for Zeabur deployment"
   git push origin main
   ```

2. **創建 Zeabur 專案**
   - 前往 [dash.zeabur.com](https://dash.zeabur.com)
   - 創建新專案並連接 Git 倉庫

3. **按順序部署服務**
   - Neo4j (圖資料庫)
   - Graphiti (RAG 引擎)
   - Nginx (反向代理)

4. **配置環境變數**
   在 Zeabur 控制面板中設置：
   - `OPENAI_API_KEY` 或 `ANTHROPIC_API_KEY`
   - `NEO4J_PASSWORD`
   - `DOMAIN` (可選)

5. **驗證部署**
   - 檢查所有服務狀態
   - 測試 API 端點
   - 驗證 Neo4j 連接

詳細部署指南請參考 [DEPLOY.md](DEPLOY.md)

## 📊 監控和維護

### 性能監控

- **CPU 使用率**: 監控 Graphiti 和 Neo4j 的 CPU 消耗
- **內存使用**: Neo4j 建議至少 4GB 內存
- **磁碟空間**: 定期清理 Neo4j 日誌和數據
- **網路流量**: 監控 API 請求頻率和響應時間

### 日誌管理

日誌文件位置：
- Nginx: `logs/nginx/`
- Graphiti: `logs/graphiti/`
- Neo4j: Docker 卷 `neo4j-logs`

### 備份策略

```bash
# 備份 Neo4j 數據
docker-compose exec neo4j neo4j-admin dump --database=neo4j --to=/backups/neo4j-backup.dump

# 備份配置文件
tar -czf config-backup.tar.gz nginx/ graphiti/config/ .env
```

## 🔒 安全考慮

### 生產環境設置

1. **修改默認密碼**
   ```env
   NEO4J_PASSWORD=your_very_secure_password_here
   ```

2. **啟用 HTTPS**
   - 配置 SSL 證書
   - 更新 Nginx 配置
   - 重定向 HTTP 到 HTTPS

3. **API 安全**
   - 實施 API 金鑰驗證
   - 設置請求速率限制
   - 配置 CORS 政策

4. **網路安全**
   - 使用防火牆限制端口訪問
   - 配置 VPN 或私有網路
   - 定期更新容器映像

## 🛠️ 故障排除

### 常見問題

**問題**: 服務無法啟動
```bash
# 檢查日誌
docker-compose logs service_name

# 檢查環境變數
docker-compose config
```

**問題**: Neo4j 連接失敗
```bash
# 驗證 Neo4j 健康狀態
docker-compose exec neo4j cypher-shell -u neo4j -p your_password "RETURN 1"

# 檢查網路連接
docker-compose exec graphiti ping neo4j
```

**問題**: API 金鑰錯誤
```bash
# 驗證環境變數
docker-compose exec graphiti env | grep API_KEY
```

### 性能調優

**Neo4j 優化**:
- 增加堆內存大小
- 調整頁面緩存
- 優化查詢語句

**Nginx 優化**:
- 啟用 gzip 壓縮
- 配置緩存策略
- 調整工作進程數

**Graphiti 優化**:
- 調整 API 超時時間
- 優化模型參數
- 實施請求緩存

## 📝 更新日誌

- **v1.0.0**: 初始版本，支持 Nginx + Neo4j + Graphiti
- **v1.1.0**: 添加 Zeabur 部署支持
- **v1.2.0**: 增強安全配置和監控功能

## 🤝 貢獻指南

1. Fork 專案
2. 創建功能分支 (`git checkout -b feature/new-feature`)
3. 提交更改 (`git commit -am 'Add new feature'`)
4. 推送分支 (`git push origin feature/new-feature`)
5. 創建 Pull Request

## 📄 許可證

本專案基於 MIT 許可證 - 詳見 [LICENSE](LICENSE) 文件

## 🆘 支持和聯繫

- 📚 **文檔**: [完整文檔連結]
- 🐛 **問題回報**: [GitHub Issues]
- 💬 **討論**: [GitHub Discussions]
- 📧 **聯繫**: [your-email@example.com]

---

**⭐ 如果這個專案對你有幫助，請給個星星！**