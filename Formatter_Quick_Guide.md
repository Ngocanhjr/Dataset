---
title: "Formatter & Chuẩn hóa nhanh cho NLCS RAG"
document_type: "huong_dan"
domain: "rag"
department: "NLCS"
audience:
  - "formatter"
  - "admin"
  - "developer"
version: "1.0"
created_at: "2026-05-23"
updated_at: "2026-05-23"
status: "active"
tags:
  - nlcs
  - formatter
  - chuan-hoa
  - metadata
  - rag
  - obsidian
---

# Formatter & Chuẩn hóa nhanh cho NLCS RAG

File này dùng để xem nhanh trong quá trình **OCR, formatter, chuẩn hóa Markdown, kiểm tra metadata, kiểm tra hiệu lực và quyết định có đưa tài liệu vào RAG hay không**.

---

## 1. Nguyên tắc vàng

```text
Không chắc hiệu lực  → không publish
Bị thay thế          → deactivated
Chưa review          → không publish
Không có metadata    → không ingest
Không có Markdown sạch → không chunk
```

Quy tắc quan trọng nhất:

```yaml
# Không xác định được hiệu lực
validity_status: "unchecked"
rag_status: "not_indexed"
```

```yaml
# Bị thay thế bởi văn bản khác
validity_status: "replaced"
rag_status: "deactivated"
is_latest: false
```

```yaml
# Chỉ publish khi đã duyệt và còn hiệu lực
review_status: "approved"
validity_status: "valid"
rag_status: "published"
```

---

## 2. Khi nào được publish vào RAG?

Một tài liệu chỉ được đưa vào RAG khi thỏa **tất cả điều kiện** sau:

```yaml
ocr_status: "done"
review_status: "approved"
validity_status: "valid"
rag_status: "published"
confidentiality: "public"
```

Nếu hệ thống chỉ dùng bản mới nhất, cần thêm:

```yaml
is_latest: true
```

Backend nên hiểu rule như sau:

```text
IF ocr_status = done
AND review_status = approved
AND validity_status = valid
AND rag_status = published
AND confidentiality = public
THEN ingest
ELSE skip
```

Rule nghiêm ngặt hơn:

```text
IF ocr_status = done
AND review_status = approved
AND validity_status = valid
AND rag_status = published
AND confidentiality = public
AND is_latest = true
AND effective_date <= today
AND (expiry_date is empty OR expiry_date >= today)
THEN ingest
ELSE skip
```

---

## 3. Bảng quyết định nhanh

| Tình huống | Metadata cần đặt | Có được đưa vào RAG không? |
|---|---|---|
| Mới thu thập, chưa OCR | `ocr_status: "not_started"` | Không |
| OCR xong nhưng chưa kiểm tra | `ocr_status: "done"`, `review_status: "reviewing"` | Không |
| Chưa xác định hiệu lực | `validity_status: "unchecked"` | Không |
| Không rõ tài liệu còn hiệu lực hay không | `validity_status: "unknown"` | Không |
| Đã duyệt nhưng chưa kiểm tra hiệu lực | `review_status: "approved"`, `validity_status: "unchecked"` | Không |
| Đã duyệt và còn hiệu lực | `review_status: "approved"`, `validity_status: "valid"` | Có thể publish |
| Đã publish | `rag_status: "published"` | Có |
| Hết hiệu lực | `validity_status: "expired"`, `rag_status: "deactivated"` | Không |
| Bị văn bản khác thay thế | `validity_status: "replaced"`, `rag_status: "deactivated"` | Không |
| Tài liệu nội bộ | `confidentiality: "internal"` | Không dùng cho chatbot public |
| Tài liệu hạn chế | `confidentiality: "restricted"` | Không dùng cho chatbot public |

---

## 4. Các trạng thái chuẩn cần dùng

### 4.1. OCR status

```text
not_started   # chưa OCR
processing    # đang OCR
need_review   # OCR xong nhưng cần kiểm tra
failed         # OCR lỗi
done           # OCR xong và có Markdown
```

### 4.2. Review status

```text
not_reviewed  # chưa review
reviewing     # đang review
need_fix      # cần sửa
approved      # đã duyệt
rejected      # không dùng
```

### 4.3. Validity status

```text
unchecked     # chưa kiểm tra hiệu lực
unknown       # không xác định được hiệu lực
valid         # còn hiệu lực
expired       # hết hiệu lực theo ngày
replaced      # bị văn bản khác thay thế
```

### 4.4. RAG status

```text
not_indexed   # chưa đưa vào RAG
chunked       # đã chunk
embedded      # đã embedding
indexed       # đã index vào Qdrant
published     # đang dùng trong chatbot
deactivated   # đã tắt khỏi retrieval
failed         # xử lý lỗi
```

---

## 5. YAML mẫu theo từng trường hợp

### 5.1. Chưa xác định được hiệu lực

Dùng khi chưa biết văn bản còn hiệu lực, đã bị thay thế hay chưa.

```yaml
validity_status: "unchecked"
is_latest: false
rag_status: "not_indexed"
review_status: "not_reviewed"
supersession_note: "Chưa kiểm tra văn bản thay thế / hiệu lực."
```

Không được publish khi còn trạng thái này.

---

### 5.2. Không xác định được hiệu lực sau khi đã kiểm tra

Dùng khi đã tìm nhưng vẫn chưa có bằng chứng rõ ràng.

```yaml
validity_status: "unknown"
is_latest: false
rag_status: "not_indexed"
supersession_note: "Đã kiểm tra nhưng chưa xác định được hiệu lực. Cần xác minh thủ công."
```

Không được publish vào RAG public.

---

### 5.3. Tài liệu đã bị thay thế

```yaml
validity_status: "replaced"
is_latest: false
replaced_by: "<version_id_tai_lieu_moi>"
rag_status: "deactivated"
supersession_note: "Tài liệu này đã bị thay thế bởi phiên bản mới hơn."
```

Nếu trước đó đã index vào Qdrant, backend phải update payload vector cũ:

```json
{
  "validity_status": "replaced",
  "rag_status": "deactivated",
  "is_latest": false,
  "replaced_by": "<version_id_tai_lieu_moi>"
}
```

---

### 5.4. Tài liệu hết hiệu lực theo ngày

```yaml
validity_status: "expired"
is_latest: false
expiry_date: "YYYY-MM-DD"
rag_status: "deactivated"
supersession_note: "Tài liệu đã hết hiệu lực theo expiry_date."
```

---

### 5.5. Tài liệu đã duyệt nhưng chưa publish

```yaml
ocr_status: "done"
review_status: "approved"
validity_status: "valid"
is_latest: true
rag_status: "not_indexed"
```

Có thể chuyển sang publish sau khi đã sẵn sàng ingest.

---

### 5.6. Tài liệu đã publish vào RAG

```yaml
ocr_status: "done"
review_status: "approved"
validity_status: "valid"
is_latest: true
rag_status: "published"
confidentiality: "public"
```

Đây là trạng thái cho phép chatbot retrieval.

---

## 6. Checklist formatter trước khi đổi trạng thái

### 6.1. Trước khi đổi `ocr_status: "done"`

- [ ] Nội dung đã OCR/parse sang Markdown.
- [ ] Không mất dấu tiếng Việt nghiêm trọng.
- [ ] Heading rõ ràng.
- [ ] Bảng không bị vỡ.
- [ ] Danh sách, điều, khoản, điểm được giữ đúng.
- [ ] Có `<!-- page: n -->` nếu cần citation theo trang.
- [ ] Không tự thêm nội dung không có trong tài liệu gốc.
- [ ] File gốc đã link trong `source_file`.

---

### 6.2. Trước khi đổi `review_status: "approved"`

- [ ] Đã kiểm tra tiêu đề tài liệu.
- [ ] Đã kiểm tra `document_id`.
- [ ] Đã kiểm tra `version_id`.
- [ ] Đã kiểm tra `document_type`.
- [ ] Đã kiểm tra `domain`.
- [ ] Đã kiểm tra `department`.
- [ ] Đã kiểm tra `audience`.
- [ ] Đã kiểm tra `source_url` hoặc `source_file`.
- [ ] Đã đối chiếu các mục quan trọng với PDF/DOCX gốc.
- [ ] Đã ghi chú các điểm chưa chắc vào `notes` hoặc `supersession_note`.

---

### 6.3. Trước khi đổi `validity_status: "valid"`

- [ ] Đã kiểm tra ngày ban hành `issued_date`.
- [ ] Đã kiểm tra ngày hiệu lực `effective_date` nếu có.
- [ ] Đã kiểm tra ngày hết hiệu lực `expiry_date` nếu có.
- [ ] Đã kiểm tra có văn bản thay thế hay không.
- [ ] Nếu là bản mới nhất, đặt `is_latest: true`.
- [ ] Nếu thay thế bản cũ, cập nhật `replaces`.
- [ ] Nếu bị thay thế, không đặt `valid`; phải đặt `replaced`.

---

### 6.4. Trước khi đổi `rag_status: "published"`

- [ ] `ocr_status: "done"`.
- [ ] `review_status: "approved"`.
- [ ] `validity_status: "valid"`.
- [ ] `confidentiality: "public"`.
- [ ] Không có dữ liệu nhạy cảm ngoài phạm vi public.
- [ ] Có page marker nếu cần citation.
- [ ] Có metadata đủ cho Qdrant payload.
- [ ] Đã xác định version mới nhất nếu cần.

---

## 7. Quy tắc version nhanh

```text
document_id = nhóm tài liệu / nghiệp vụ
version_id  = một phiên bản cụ thể của văn bản
```

Ví dụ nhiều version cùng một nhóm tài liệu:

```yaml
document_id: "ctu-quy-dinh-hoc-vu"
version_id: "ctu-qd1813-2021"
version: "2021"
```

```yaml
document_id: "ctu-quy-dinh-hoc-vu"
version_id: "ctu-qdxxxx-2024"
version: "2024"
```

Khi có bản mới thay thế bản cũ:

Bản cũ:

```yaml
is_latest: false
validity_status: "replaced"
replaced_by: "ctu-qdxxxx-2024"
rag_status: "deactivated"
```

Bản mới:

```yaml
is_latest: true
validity_status: "valid"
replaces: "ctu-qd1813-2021"
rag_status: "published"
```

---

## 8. Lỗi thường gặp khi formatter

| Lỗi | Cách sửa |
|---|---|
| Dùng `status` chung chung | Tách thành `collection_status`, `ocr_status`, `review_status`, `rag_status`, `validity_status` |
| Không chắc hiệu lực nhưng vẫn publish | Đặt `validity_status: "unchecked"` và `rag_status: "not_indexed"` |
| Tài liệu cũ bị thay thế nhưng vẫn để published | Đổi `validity_status: "replaced"`, `rag_status: "deactivated"` |
| Ghi đè file cũ bằng nội dung mới | Tạo file Markdown mới với `version_id` mới |
| Thiếu page marker | Thêm `<!-- page: n -->` theo trang gốc |
| OCR làm vỡ bảng | Sửa lại bằng Markdown table |
| Tự tóm tắt thay cho nội dung gốc | Giữ nội dung chuẩn hóa trung thực từ tài liệu gốc |
| Thiếu `source_file` | Link lại PDF/DOCX gốc trong `02_Attachments` |

---

## 9. Dataview xem nhanh

### 9.1. Tài liệu chưa kiểm tra hiệu lực

```dataview
TABLE document_id, version_id, title, code, issued_date, validity_status, rag_status
FROM "01_Dataset"
WHERE validity_status = "unchecked" OR validity_status = "unknown"
SORT issued_date DESC
```

### 9.2. Tài liệu đã bị thay thế

```dataview
TABLE document_id, version_id, title, version, replaced_by, rag_status
FROM "01_Dataset"
WHERE validity_status = "replaced"
SORT updated_at DESC
```

### 9.3. Tài liệu đủ điều kiện publish

```dataview
TABLE document_id, version_id, title, department, domain, review_status, validity_status, rag_status
FROM "01_Dataset"
WHERE ocr_status = "done"
AND review_status = "approved"
AND validity_status = "valid"
AND confidentiality = "public"
SORT updated_at DESC
```

### 9.4. Tài liệu đang published

```dataview
TABLE document_id, version_id, title, department, domain, is_latest, rag_status
FROM "01_Dataset"
WHERE rag_status = "published"
AND validity_status = "valid"
SORT updated_at DESC
```

### 9.5. Tài liệu sai logic: published nhưng chưa valid

```dataview
TABLE document_id, version_id, title, review_status, validity_status, rag_status
FROM "01_Dataset"
WHERE rag_status = "published"
AND validity_status != "valid"
SORT updated_at DESC
```

### 9.6. Tài liệu sai logic: valid nhưng chưa approved

```dataview
TABLE document_id, version_id, title, review_status, validity_status, rag_status
FROM "01_Dataset"
WHERE validity_status = "valid"
AND review_status != "approved"
SORT updated_at DESC
```

---

## 10. Công thức nhớ nhanh

```text
unchecked  = chưa chắc → không publish
unknown    = không xác minh được → không publish
valid      = còn hiệu lực → có thể publish nếu approved
expired    = hết hiệu lực → deactivated
replaced   = bị thay thế → deactivated
```

```text
approved + valid + done + public + published = được vào RAG
```

```text
replaced hoặc expired = không retrieval mặc định
```

---

## 11. Gợi ý vị trí đặt file này

Nên đặt file này tại một trong các vị trí sau:

```text
03_Templates/Formatter_ChuanHoa_Quick_Guide.md
```

hoặc:

```text
06_Processing/Formatter_ChuanHoa_Quick_Guide.md
```

Nếu dùng thường xuyên khi chuẩn hóa, nên đặt ở `06_Processing`. Nếu muốn xem như quy chuẩn chung cho template, nên đặt ở `03_Templates`.
