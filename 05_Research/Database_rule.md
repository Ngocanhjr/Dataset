---
title: "Theo dõi CSDL PostgreSQL và Qdrant cho NLCS RAG"
document_type: "tracking_guide"
domain: "database_vector_tracking"
department: "NLCS"
audience:
  - "developer"
  - "admin"
  - "researcher"
version: "1.0"
status: "draft"
created_at: "2026-05-24"
updated_at: "2026-05-24"
tags:
  - nlcs
  - postgresql
  - qdrant
  - vector-db
  - database
  - rag
  - monitoring
  - ingestion
---

# Theo dõi CSDL PostgreSQL và Qdrant cho NLCS RAG

File này dùng để theo dõi cách tổ chức, kiểm tra và đồng bộ dữ liệu giữa:

```text
PostgreSQL = CSDL có cấu trúc, metadata, version, trạng thái xử lý
Qdrant = VectorDB lưu embedding chunks phục vụ semantic retrieval
```

---

## 1. Mục tiêu

Mục tiêu của việc theo dõi CSDL và Qdrant:

- Biết tài liệu nào đã được lưu metadata trong PostgreSQL.
- Biết tài liệu nào đã được chunk.
- Biết chunk nào đã được embedding.
- Biết chunk nào đã được index vào Qdrant.
- Phát hiện tài liệu đã `published` nhưng chưa có vector.
- Phát hiện vector cũ chưa bị `deactivated`.
- Kiểm tra đồng bộ giữa PostgreSQL và Qdrant.
- Hỗ trợ debug khi chatbot truy xuất sai tài liệu.
- Theo dõi version tài liệu: bản mới, bản cũ, bản bị thay thế.

---

## 2. Vai trò của PostgreSQL và Qdrant

| Thành phần | Vai trò |
|---|---|
| PostgreSQL | Lưu dữ liệu có cấu trúc, metadata, trạng thái, version, thủ tục, biểu mẫu |
| Qdrant | Lưu vector embedding của từng chunk |
| Obsidian | Nơi quản lý Markdown canonical trước khi ingest |
| Backend | Đọc Markdown, validate metadata, chunking, embedding, upsert Qdrant |

---

## 3. Nguyên tắc đồng bộ

```text
01_Dataset/*.md
  ↓
Backend đọc YAML + Markdown
  ↓
PostgreSQL lưu document/version/chunk metadata
  ↓
Embedding service tạo vector
  ↓
Qdrant lưu vector + payload
```

Quy tắc:

```text
PostgreSQL là nguồn kiểm soát trạng thái.
Qdrant là nguồn phục vụ tìm kiếm semantic.
Không dùng Qdrant để thay thế PostgreSQL.
Mỗi point trong Qdrant phải map được về một chunk trong PostgreSQL.
```

---

## 4. Điều kiện tài liệu được index vào Qdrant

Chỉ index tài liệu nếu metadata đạt:

```yaml
ocr_status: "done"
review_status: "approved"
validity_status: "valid"
rag_status: "published"
confidentiality: "public"
```

Nếu dùng rule nghiêm ngặt:

```yaml
is_latest: true
```

Không index nếu:

```text
validity_status = unchecked
validity_status = unknown
validity_status = expired
validity_status = replaced
rag_status = deactivated
review_status != approved
ocr_status != done
confidentiality != public
```

---

# 5. PostgreSQL - Các bảng cần theo dõi

## 5.1. `documents`

Lưu thông tin chung của nhóm tài liệu.

```sql
CREATE TABLE documents (
    id UUID PRIMARY KEY,
    document_id TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    document_type TEXT NOT NULL,
    domain TEXT,
    department TEXT,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);
```

Ví dụ:

```text
document_id: ctu-quy-dinh-hoc-vu
title: Quy định công tác học vụ
document_type: regulation
domain: hoc_tap
department: Phòng Đào tạo
```

---

## 5.2. `document_versions`

Lưu từng version cụ thể của tài liệu.

```sql
CREATE TABLE document_versions (
    id UUID PRIMARY KEY,
    document_id TEXT NOT NULL,
    version_id TEXT UNIQUE NOT NULL,
    version TEXT,
    code TEXT,
    issued_date DATE,
    effective_date DATE,
    expiry_date DATE,
    is_latest BOOLEAN DEFAULT false,
    validity_status TEXT NOT NULL,
    collection_status TEXT,
    ocr_status TEXT,
    review_status TEXT,
    rag_status TEXT,
    source_url TEXT,
    source_file TEXT,
    markdown_path TEXT,
    checksum TEXT,
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);
```

Trạng thái quan trọng:

```text
validity_status: unchecked | valid | expired | replaced | unknown
rag_status: not_indexed | chunked | embedded | indexed | published | deactivated | failed
review_status: not_reviewed | reviewing | approved | rejected | need_fix
ocr_status: not_started | processing | done | failed | need_review
```

---

## 5.3. `document_chunks`

Lưu metadata và nội dung chunk.

```sql
CREATE TABLE document_chunks (
    id UUID PRIMARY KEY,
    chunk_id TEXT UNIQUE NOT NULL,
    document_id TEXT NOT NULL,
    version_id TEXT NOT NULL,
    chunk_index INT NOT NULL,
    heading_path TEXT,
    content TEXT NOT NULL,
    page_start INT,
    page_end INT,
    token_count INT,
    checksum TEXT,
    embedding_status TEXT DEFAULT 'pending',
    qdrant_status TEXT DEFAULT 'not_indexed',
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);
```

Trạng thái gợi ý:

```text
embedding_status: pending | embedded | failed | skipped
qdrant_status: not_indexed | indexed | deactivated | failed
```

---

## 5.4. `ingestion_jobs`

Theo dõi job xử lý tài liệu.

```sql
CREATE TABLE ingestion_jobs (
    id UUID PRIMARY KEY,
    document_id TEXT NOT NULL,
    version_id TEXT NOT NULL,
    job_type TEXT NOT NULL,
    status TEXT NOT NULL,
    current_step TEXT,
    total_chunks INT DEFAULT 0,
    embedded_chunks INT DEFAULT 0,
    indexed_chunks INT DEFAULT 0,
    error_message TEXT,
    started_at TIMESTAMP,
    finished_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT now()
);
```

`job_type`:

```text
ocr
metadata_validation
chunking
embedding
qdrant_indexing
reindex
deactivate
```

`status`:

```text
pending
running
success
failed
partial_success
cancelled
```

---

## 5.5. `retrieval_logs`

Theo dõi retrieval khi chatbot trả lời.

```sql
CREATE TABLE retrieval_logs (
    id UUID PRIMARY KEY,
    user_query TEXT NOT NULL,
    intent TEXT,
    retrieved_chunk_ids TEXT[],
    selected_chunk_ids TEXT[],
    answer_has_citation BOOLEAN,
    latency_ms INT,
    created_at TIMESTAMP DEFAULT now()
);
```

Dùng để debug:

- Query nào lấy sai chunk?
- Chunk nào được dùng nhiều?
- Có câu trả lời nào không citation?
- Retrieval có lấy tài liệu `replaced` không?

---

# 6. Qdrant - Collection và payload

## 6.1. Collection đề xuất

```text
ctu_knowledge_chunks
```

Vector size phụ thuộc embedding model.

Ví dụ nếu dùng `BAAI/bge-m3`, cần kiểm tra dimension thực tế khi triển khai.

---

## 6.2. Point payload chuẩn

Mỗi point trong Qdrant tương ứng với một chunk.

```json
{
  "chunk_id": "ctu-qd1813-2021_chunk_001",
  "document_id": "ctu-quy-dinh-hoc-vu",
  "version_id": "ctu-qd1813-2021",
  "title": "Ban hành Quy định công tác học vụ dành cho sinh viên trình độ đại học hệ chính quy",
  "document_type": "regulation",
  "domain": "hoc_tap",
  "department": "Phòng Đào tạo",
  "audience": ["student"],
  "code": "1813/QĐ-ĐHCT",
  "version": "2021",
  "is_latest": false,
  "validity_status": "valid",
  "rag_status": "published",
  "confidentiality": "public",
  "page_start": 1,
  "page_end": 2,
  "heading_path": "Chương I > Điều 1",
  "source_url": "https://...",
  "source_file": "QD1813_QD_ban_hanh_Quy_dinh_cong_tac_hoc_vu_2021.pdf",
  "created_at": "2026-05-24"
}
```

---

## 6.3. Payload index cần tạo

Nên tạo index cho các field hay filter:

```text
document_id
version_id
document_type
domain
department
audience
is_latest
validity_status
rag_status
confidentiality
effective_date
expiry_date
```

Mục tiêu:

```text
Tăng tốc metadata filter.
Đảm bảo retriever chỉ lấy tài liệu hợp lệ.
```

---

# 7. Rule truy xuất mặc định

Retriever mặc định chỉ lấy:

```text
rag_status = published
validity_status = valid
confidentiality = public
```

Nếu hệ thống yêu cầu chỉ dùng bản mới nhất:

```text
is_latest = true
```

Nếu có hiệu lực theo ngày:

```text
effective_date <= today
expiry_date is null OR expiry_date >= today
```

Không lấy:

```text
rag_status = deactivated
validity_status = unchecked
validity_status = unknown
validity_status = expired
validity_status = replaced
confidentiality = restricted
```

---

# 8. Checklist đồng bộ PostgreSQL ↔ Qdrant

## 8.1. Sau khi chunking

- [ ] `document_versions.rag_status` được cập nhật thành `chunked`.
- [ ] Có record trong `document_chunks`.
- [ ] Mỗi chunk có `chunk_id`.
- [ ] Mỗi chunk có `document_id`.
- [ ] Mỗi chunk có `version_id`.
- [ ] Có `page_start`, `page_end` nếu dùng citation theo trang.
- [ ] Có `heading_path`.

## 8.2. Sau khi embedding

- [ ] `embedding_status = embedded`.
- [ ] Không có chunk `embedding_status = failed`.
- [ ] Số chunk embedded = tổng số chunk cần index.
- [ ] Log embedding model.
- [ ] Nếu đổi embedding model, đánh dấu cần reindex.

## 8.3. Sau khi Qdrant indexing

- [ ] `qdrant_status = indexed`.
- [ ] Mỗi point Qdrant có `chunk_id`.
- [ ] Payload Qdrant có `document_id`, `version_id`.
- [ ] Payload Qdrant có `rag_status`, `validity_status`, `confidentiality`.
- [ ] Số point Qdrant = số chunk indexed trong PostgreSQL.
- [ ] Search thử ra đúng chunk.
- [ ] Citation trả đúng page/source.

---

# 9. SQL kiểm tra nhanh PostgreSQL

## 9.1. Tài liệu đã publish nhưng chưa có chunk

```sql
SELECT dv.document_id, dv.version_id, dv.title
FROM document_versions dv
LEFT JOIN document_chunks dc ON dv.version_id = dc.version_id
WHERE dv.rag_status = 'published'
  AND dv.validity_status = 'valid'
  AND dc.id IS NULL;
```

---

## 9.2. Chunk đã tạo nhưng chưa embedding

```sql
SELECT chunk_id, document_id, version_id, heading_path
FROM document_chunks
WHERE embedding_status != 'embedded';
```

---

## 9.3. Chunk đã embedding nhưng chưa index Qdrant

```sql
SELECT chunk_id, document_id, version_id, heading_path
FROM document_chunks
WHERE embedding_status = 'embedded'
  AND qdrant_status != 'indexed';
```

---

## 9.4. Tài liệu bị thay thế nhưng vẫn published

```sql
SELECT document_id, version_id, title, validity_status, rag_status
FROM document_versions
WHERE validity_status = 'replaced'
  AND rag_status = 'published';
```

Kết quả này là lỗi. Cần sửa thành:

```text
rag_status = deactivated
```

---

## 9.5. Tài liệu chưa kiểm tra hiệu lực nhưng đã published

```sql
SELECT document_id, version_id, title, validity_status, rag_status
FROM document_versions
WHERE validity_status IN ('unchecked', 'unknown')
  AND rag_status = 'published';
```

Kết quả này là lỗi. Cần sửa thành:

```text
rag_status = not_indexed
```

hoặc:

```text
rag_status = deactivated
```

---

## 9.6. Có nhiều bản `is_latest = true` cùng document_id

```sql
SELECT document_id, COUNT(*) AS latest_count
FROM document_versions
WHERE is_latest = true
GROUP BY document_id
HAVING COUNT(*) > 1;
```

Kết quả này là lỗi versioning.

---

## 9.7. Tài liệu đủ điều kiện index

```sql
SELECT document_id, version_id, title
FROM document_versions
WHERE ocr_status = 'done'
  AND review_status = 'approved'
  AND validity_status = 'valid'
  AND rag_status = 'published';
```

---

## 9.8. Thống kê trạng thái tài liệu

```sql
SELECT validity_status, rag_status, COUNT(*) AS total
FROM document_versions
GROUP BY validity_status, rag_status
ORDER BY validity_status, rag_status;
```

---

# 10. Kiểm tra Qdrant bằng API/script

## 10.1. Count toàn bộ points

```python
from qdrant_client import QdrantClient

client = QdrantClient(url="http://localhost:6333")

count = client.count(
    collection_name="ctu_knowledge_chunks",
    exact=True
)

print(count.count)
```

---

## 10.2. Count theo tài liệu

```python
from qdrant_client import QdrantClient
from qdrant_client.models import Filter, FieldCondition, MatchValue

client = QdrantClient(url="http://localhost:6333")

result = client.count(
    collection_name="ctu_knowledge_chunks",
    count_filter=Filter(
        must=[
            FieldCondition(
                key="version_id",
                match=MatchValue(value="ctu-qd1813-2021")
            )
        ]
    ),
    exact=True
)

print(result.count)
```

---

## 10.3. Kiểm tra vector active

```python
result = client.count(
    collection_name="ctu_knowledge_chunks",
    count_filter=Filter(
        must=[
            FieldCondition(key="rag_status", match=MatchValue(value="published")),
            FieldCondition(key="validity_status", match=MatchValue(value="valid")),
            FieldCondition(key="confidentiality", match=MatchValue(value="public")),
        ]
    ),
    exact=True
)

print(result.count)
```

---

## 10.4. Tìm vector đáng lẽ không được active

```python
result = client.count(
    collection_name="ctu_knowledge_chunks",
    count_filter=Filter(
        must=[
            FieldCondition(key="rag_status", match=MatchValue(value="published")),
        ],
        should=[
            FieldCondition(key="validity_status", match=MatchValue(value="unchecked")),
            FieldCondition(key="validity_status", match=MatchValue(value="unknown")),
            FieldCondition(key="validity_status", match=MatchValue(value="expired")),
            FieldCondition(key="validity_status", match=MatchValue(value="replaced")),
        ]
    ),
    exact=True
)

print(result.count)
```

Nếu kết quả > 0 thì có lỗi governance.

---

# 11. Khi tài liệu bị thay thế

## 11.1. PostgreSQL

Cập nhật bản cũ:

```sql
UPDATE document_versions
SET validity_status = 'replaced',
    rag_status = 'deactivated',
    is_latest = false,
    updated_at = now()
WHERE version_id = 'ctu-qd1813-2021';
```

Cập nhật bản mới:

```sql
UPDATE document_versions
SET validity_status = 'valid',
    rag_status = 'published',
    is_latest = true,
    updated_at = now()
WHERE version_id = 'ctu-qdxxxx-2024';
```

---

## 11.2. Qdrant

Không cần xóa ngay vector cũ. Cập nhật payload:

```json
{
  "rag_status": "deactivated",
  "validity_status": "replaced",
  "is_latest": false,
  "replaced_by": "ctu-qdxxxx-2024"
}
```

Retriever sẽ không lấy vector cũ vì filter:

```text
rag_status = published
validity_status = valid
```

---

# 12. Dashboard theo dõi trong Obsidian

Có thể tạo file:

```text
00_Dashboard/Database_Qdrant_Status.md
```

## 12.1. Tài liệu đã publish

```dataview
TABLE document_id, version_id, title, validity_status, rag_status, is_latest
FROM "01_Dataset"
WHERE rag_status = "published"
SORT updated_at DESC
```

## 12.2. Tài liệu cần index

```dataview
TABLE document_id, version_id, title, review_status, ocr_status, validity_status, rag_status
FROM "01_Dataset"
WHERE review_status = "approved"
AND ocr_status = "done"
AND validity_status = "valid"
AND rag_status != "published"
SORT updated_at DESC
```

## 12.3. Tài liệu không được publish nhưng đang published

```dataview
TABLE document_id, version_id, title, validity_status, rag_status
FROM "01_Dataset"
WHERE rag_status = "published"
AND (validity_status = "unchecked" OR validity_status = "unknown" OR validity_status = "expired" OR validity_status = "replaced")
SORT updated_at DESC
```

## 12.4. Tài liệu bị thay thế nhưng chưa deactivated

```dataview
TABLE document_id, version_id, title, replaced_by, validity_status, rag_status
FROM "01_Dataset"
WHERE validity_status = "replaced" AND rag_status != "deactivated"
SORT updated_at DESC
```

---

# 13. Trạng thái cần theo dõi hằng ngày

| Nhóm | Cần xem |
|---|---|
| Metadata | Có file thiếu `document_id`, `version_id` không? |
| OCR | Có tài liệu `ocr_status = failed` không? |
| Review | Có tài liệu `need_fix` lâu ngày không? |
| Validity | Có tài liệu `unchecked` không? |
| RAG | Có tài liệu `approved + valid` nhưng chưa published không? |
| Qdrant | Số point có khớp số chunk indexed không? |
| Version | Có nhiều bản `is_latest = true` cùng `document_id` không? |
| Governance | Có vector published nhưng validity không valid không? |

---

# 14. Bảng quyết định nhanh

| Tình huống | PostgreSQL | Qdrant |
|---|---|---|
| Tài liệu mới thu thập | Tạo document/version | Chưa có vector |
| Đã chunk | Tạo `document_chunks` | Chưa có vector |
| Đã embedding | `embedding_status = embedded` | Có thể chưa index |
| Đã index | `qdrant_status = indexed` | Có point |
| Đã publish | `rag_status = published` | Vector active |
| Bị thay thế | `rag_status = deactivated` | Update payload deactivated |
| Hết hiệu lực | `validity_status = expired` | Không active |
| Chưa kiểm tra hiệu lực | `validity_status = unchecked` | Không active |

---

# 15. Quy trình debug khi chatbot trả lời sai

```text
1. Xem câu hỏi user.
2. Kiểm tra retrieval_logs.
3. Xem retrieved_chunk_ids.
4. Kiểm tra chunk trong PostgreSQL.
5. Kiểm tra payload Qdrant.
6. Xem document/version có valid/published/public không.
7. Kiểm tra Markdown nguồn trong 01_Dataset.
8. Kiểm tra page marker/citation.
9. Nếu OCR sai → sửa Markdown.
10. Nếu chunk sai → chunk lại.
11. Nếu vector sai/cũ → re-embed + re-index.
12. Nếu tài liệu hết hiệu lực → deactivate.
```

---

# 16. Checklist trước khi báo hệ thống ổn

- [ ] Không có tài liệu `unchecked` nhưng `published`.
- [ ] Không có tài liệu `replaced` nhưng `published`.
- [ ] Không có nhiều bản `is_latest = true` cho cùng `document_id`.
- [ ] Tất cả tài liệu `published` đều có chunk.
- [ ] Tất cả chunk `published` đều có vector Qdrant.
- [ ] Qdrant payload có đủ `document_id`, `version_id`, `rag_status`, `validity_status`.
- [ ] Retriever filter đúng.
- [ ] Test search trả về đúng nguồn.
- [ ] Câu trả lời có citation.
- [ ] Vector cũ đã deactivated khi tài liệu bị thay thế.

---

# 17. Công thức nhớ nhanh

```text
PostgreSQL quản trạng thái.
Qdrant quản vector.
Obsidian quản Markdown nguồn.
Chunk nào vào Qdrant cũng phải có version_id.
Tài liệu unchecked không được published.
Tài liệu replaced phải deactivated.
Retriever chỉ lấy published + valid + public.
```

---

# 18. Việc cần làm tiếp theo

- [ ] Tạo bảng `documents`.
- [ ] Tạo bảng `document_versions`.
- [ ] Tạo bảng `document_chunks`.
- [ ] Tạo bảng `ingestion_jobs`.
- [ ] Tạo bảng `retrieval_logs`.
- [ ] Tạo collection `ctu_knowledge_chunks` trong Qdrant.
- [ ] Tạo payload index trong Qdrant.
- [ ] Viết script sync Markdown từ `01_Dataset`.
- [ ] Viết script validate PostgreSQL ↔ Qdrant.
- [ ] Viết API xem trạng thái indexing.
- [ ] Viết dashboard admin theo dõi ingestion.
