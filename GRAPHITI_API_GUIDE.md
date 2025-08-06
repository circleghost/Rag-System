# Graphiti RAG API 使用指南

本文檔基於實際的 OpenAPI 規格，提供完整的 Graphiti API 使用方法。

## 🔗 API 基本資訊

- **基礎 URL**: `http://localhost`
- **API 版本**: 0.1.0
- **文檔頁面**: `http://localhost/docs`
- **OpenAPI 規格**: `http://localhost/openapi.json`

## 📋 API 端點總覽

| 端點 | 方法 | 描述 |
|------|------|------|
| `/messages` | POST | 添加訊息到知識圖譜 |
| `/search` | POST | 搜尋知識圖譜 |
| `/get-memory` | POST | 獲取記憶內容 |
| `/episodes/{group_id}` | GET | 獲取特定群組的對話記錄 |
| `/entity-node` | POST | 添加實體節點 |
| `/entity-edge/{uuid}` | GET/DELETE | 獲取或刪除實體邊 |
| `/group/{group_id}` | DELETE | 刪除群組 |
| `/episode/{uuid}` | DELETE | 刪除特定對話記錄 |
| `/clear` | POST | 清除所有數據 |
| `/healthcheck` | GET | 健康檢查 |

---

## 📝 主要 API 使用方法

### 1. 📨 添加訊息 (`/messages`)

**用途**: 這是建立知識圖譜的主要方法，通過對話訊息來建立實體和關係。

**端點**: `POST /messages`

**請求格式**:
```json
{
  "group_id": "string",
  "messages": [
    {
      "content": "string",
      "uuid": "string (optional)",
      "name": "string (optional)",
      "role_type": "user|assistant|system",
      "role": "string (optional)",
      "timestamp": "2024-01-01T00:00:00Z",
      "source_description": "string (optional)"
    }
  ]
}
```

**CURL 範例**:
```bash
curl -X POST "http://localhost/messages" \
  -H "Content-Type: application/json" \
  -d '{
    "group_id": "ai_research_team",
    "messages": [
      {
        "content": "李教授在史丹佛大學成立了一個人工智慧研究團隊，招募了來自台灣的博士生王小明和來自印度的研究員 Raj Patel。",
        "role_type": "user",
        "role": "story_teller",
        "timestamp": "2024-01-01T00:00:00Z",
        "source_description": "研究團隊故事"
      }
    ]
  }'
```

---

### 2. 🔍 搜尋知識圖譜 (`/search`)

**用途**: 在已建立的知識圖譜中搜尋相關資訊。

**端點**: `POST /search`

**請求格式**:
```json
{
  "group_ids": ["string"] (optional),
  "query": "string",
  "max_facts": 10 (optional)
}
```

**CURL 範例**:
```bash
curl -X POST "http://localhost/search" \
  -H "Content-Type: application/json" \
  -d '{
    "group_ids": ["ai_research_team"],
    "query": "告訴我關於王小明的所有信息",
    "max_facts": 10
  }'
```

---

### 3. 🧠 獲取記憶內容 (`/get-memory`)

**用途**: 基於特定訊息和節點來獲取相關的記憶內容。

**端點**: `POST /get-memory`

**請求格式**:
```json
{
  "group_id": "string",
  "max_facts": 10 (optional),
  "center_node_uuid": "string or null",
  "messages": [
    {
      "content": "string",
      "role_type": "user|assistant|system",
      "role": "string",
      "timestamp": "2024-01-01T00:00:00Z"
    }
  ]
}
```

**CURL 範例**:
```bash
curl -X POST "http://localhost/get-memory" \
  -H "Content-Type: application/json" \
  -d '{
    "group_id": "ai_research_team",
    "center_node_uuid": null,
    "max_facts": 10,
    "messages": [
      {
        "content": "SmartVision 項目的進展如何？",
        "role_type": "user",
        "role": "inquirer",
        "timestamp": "2024-12-01T00:00:00Z"
      }
    ]
  }'
```

---

### 4. 📚 獲取對話記錄 (`/episodes/{group_id}`)

**用途**: 獲取特定群組的最近對話記錄。

**端點**: `GET /episodes/{group_id}`

**參數**:
- `group_id` (路徑參數): 群組 ID
- `last_n` (查詢參數): 要獲取的最近記錄數量

**CURL 範例**:
```bash
curl "http://localhost/episodes/ai_research_team?last_n=5"
```

---

### 5. ➕ 添加實體節點 (`/entity-node`)

**用途**: 手動添加實體節點到知識圖譜。

**端點**: `POST /entity-node`

**請求格式**:
```json
{
  "uuid": "string",
  "group_id": "string",
  "name": "string",
  "summary": "string (optional)"
}
```

**CURL 範例**:
```bash
curl -X POST "http://localhost/entity-node" \
  -H "Content-Type: application/json" \
  -d '{
    "uuid": "person-001",
    "group_id": "ai_research_team",
    "name": "張博士",
    "summary": "新加入的機器學習專家"
  }'
```

---

### 6. 🔗 實體邊操作 (`/entity-edge/{uuid}`)

**獲取實體邊**:
```bash
curl "http://localhost/entity-edge/{uuid}"
```

**刪除實體邊**:
```bash
curl -X DELETE "http://localhost/entity-edge/{uuid}"
```

---

### 7. 🗑️ 刪除操作

**刪除群組**:
```bash
curl -X DELETE "http://localhost/group/{group_id}"
```

**刪除特定對話記錄**:
```bash
curl -X DELETE "http://localhost/episode/{uuid}"
```

**清除所有數據**:
```bash
curl -X POST "http://localhost/clear"
```

---

### 8. ❤️ 健康檢查 (`/healthcheck`)

**用途**: 檢查 API 服務狀態。

```bash
curl "http://localhost/healthcheck"
```

---

## 🎯 完整的測試流程

### 第一步：建立連貫的故事記憶

```bash
# 1. 第一句：團隊組建
curl -X POST "http://localhost/messages" \
  -H "Content-Type: application/json" \
  -d '{
    "group_id": "ai_research_team",
    "messages": [
      {
        "content": "李教授在史丹佛大學成立了一個人工智慧研究團隊，招募了來自台灣的博士生王小明和來自印度的研究員 Raj Patel。",
        "role_type": "user",
        "role": "story_teller",
        "timestamp": "2024-01-01T00:00:00Z",
        "source_description": "研究團隊故事第一章"
      }
    ]
  }'

# 2. 第二句：項目啟動
curl -X POST "http://localhost/messages" \
  -H "Content-Type: application/json" \
  -d '{
    "group_id": "ai_research_team",
    "messages": [
      {
        "content": "這個團隊決定開發一個名為 SmartVision 的計算機視覺系統，獲得了 Google 提供的 50 萬美元研究資金。",
        "role_type": "user",
        "role": "story_teller",
        "timestamp": "2024-02-01T00:00:00Z",
        "source_description": "研究團隊故事第二章"
      }
    ]
  }'

# 3. 第三句：技術突破
curl -X POST "http://localhost/messages" \
  -H "Content-Type: application/json" \
  -d '{
    "group_id": "ai_research_team",
    "messages": [
      {
        "content": "經過六個月的努力，王小明成功開發出了新的神經網路架構，使得圖像識別準確率提升到 98.5%。",
        "role_type": "user",
        "role": "story_teller",
        "timestamp": "2024-08-01T00:00:00Z",
        "source_description": "研究團隊故事第三章"
      }
    ]
  }'

# 4. 第四句：合作發展
curl -X POST "http://localhost/messages" \
  -H "Content-Type: application/json" \
  -d '{
    "group_id": "ai_research_team",
    "messages": [
      {
        "content": "Raj Patel 負責與微軟的工程師團隊合作，將 SmartVision 系統整合到他們的雲端平台上。",
        "role_type": "user",
        "role": "story_teller",
        "timestamp": "2024-09-01T00:00:00Z",
        "source_description": "研究團隊故事第四章"
      }
    ]
  }'

# 5. 第五句：成果發表
curl -X POST "http://localhost/messages" \
  -H "Content-Type: application/json" \
  -d '{
    "group_id": "ai_research_team",
    "messages": [
      {
        "content": "最終這個研究成果在 2024 年的 NeurIPS 會議上發表，並獲得了最佳論文獎，李教授也因此被提名為 IEEE Fellow。",
        "role_type": "user",
        "role": "story_teller",
        "timestamp": "2024-12-01T00:00:00Z",
        "source_description": "研究團隊故事第五章"
      }
    ]
  }'
```

### 第二步：測試知識圖譜查詢

```bash
# 查詢特定人物
curl -X POST "http://localhost/search" \
  -H "Content-Type: application/json" \
  -d '{
    "group_ids": ["ai_research_team"],
    "query": "告訴我關於王小明的所有信息",
    "max_facts": 10
  }'

# 查詢項目信息
curl -X POST "http://localhost/search" \
  -H "Content-Type: application/json" \
  -d '{
    "group_ids": ["ai_research_team"],
    "query": "SmartVision 項目的詳細情況是什麼？",
    "max_facts": 10
  }'

# 查詢關係網絡
curl -X POST "http://localhost/search" \
  -H "Content-Type: application/json" \
  -d '{
    "group_ids": ["ai_research_team"],
    "query": "李教授的研究團隊都有誰？他們各自負責什麼？",
    "max_facts": 15
  }'
```

### 第三步：獲取記憶內容

```bash
curl -X POST "http://localhost/get-memory" \
  -H "Content-Type: application/json" \
  -d '{
    "group_id": "ai_research_team",
    "center_node_uuid": null,
    "max_facts": 10,
    "messages": [
      {
        "content": "這個 AI 研究團隊有什麼重要成就？",
        "role_type": "user",
        "role": "inquirer",
        "timestamp": "2024-12-15T00:00:00Z"
      }
    ]
  }'
```

---

## 💡 使用建議

1. **group_id**: 用於組織不同的知識領域，建議使用有意義的名稱
2. **timestamp**: 保持時間順序有助於建立正確的時間關係
3. **role_type**: 正確設置角色類型有助於系統理解對話結構
4. **搜尋策略**: 從具體問題開始，逐步擴展到更廣泛的查詢
5. **記憶獲取**: 使用 center_node_uuid 可以獲得更精確的相關記憶

---

## 🔧 Neo4j 圖譜查看

在成功添加訊息後，您可以在 Neo4j 瀏覽器 (http://localhost/browser) 中使用以下查詢來查看建立的知識圖譜：

```cypher
// 查看所有節點和關係
MATCH (n)-[r]->(m) RETURN n, r, m LIMIT 25

// 查看特定群組的數據
MATCH (n) WHERE n.group_id = "ai_research_team" RETURN n

// 查看實體節點
MATCH (n:Entity) RETURN n LIMIT 10

// 搜尋特定人物
MATCH (n) WHERE n.name CONTAINS "王小明" RETURN n
```

---

這份指南提供了完整的 Graphiti API 使用方法。建議先從簡單的訊息添加開始，然後逐步測試搜尋和記憶獲取功能。