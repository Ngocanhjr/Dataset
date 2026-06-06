---
title: "Asset, Form và Version Governance cho NLCS RAG"
document_type: "huong_dan_quan_tri"
domain: "rag_governance"
department: "NLCS"
audience:
  - "developer"
  - "admin"
  - "formatter"
version: "1.0"
created_at: "2026-05-24"
updated_at: "2026-05-24"
status: "active"
tags:
  - nlcs
  - rag
  - asset
  - form
  - versioning
  - governance
---

# Asset, Form và Version Governance cho NLCS RAG

Tài liệu này quy định cách quản lý **biểu mẫu, file liên quan, file tải về và version cũ/mới** để chatbot RAG trả lời chính xác, không dùng nhầm tài liệu hết hiệu lực.

---

## 1. Vấn đề cần giải quyết

Trong bài toán thủ tục hành chính sinh viên, câu trả lời không chỉ là văn bản mô tả. Chatbot còn phải biết:

- Thủ tục cần biểu mẫu nào.
- Biểu mẫu có bắt buộc không.
- File tải ở đâu.
- Văn bản/biểu mẫu còn hiệu lực không.
- Bản nào là mới nhất.
- Bản nào đã bị thay thế.
- Nếu người dùng hỏi lịch sử, bản cũ nằm ở đâu.

Do đó vault cần quản lý 4 lớp dữ liệu:

```text
Document  = nhóm tài liệu nghiệp vụ
Version   = một bản cụ thể của tài liệu
Asset     = file vật lý/link/biểu mẫu/phụ lục
Chunk     = đoạn nội dung đã index vào Qdrant
```

---

## 2. Quy tắc lưu trữ

| Loại dữ liệu | Vị trí |
|---|---|
| Markdown canonical | `01_Dataset` |
| PDF gốc | `02_Attachments/PDFs` |
| DOCX nguồn | `02_Attachments/DOCX` |
| Biểu mẫu tải về | `02_Attachments/Forms` |
| Ảnh scan/screenshot | `02_Attachments/Images` |
| Version cũ/hết hiệu lực | `99_Archive` hoặc giữ tại `01_Dataset` với `rag_status: deactivated` |
| OCR/log/tracking | `06_Processing` |

---

## 3. Metadata asset chuẩn

```yaml
asset_id: "ctu-form-xin-cap-bang-diem"
asset_type: "form"
title: "Mẫu đơn xin cấp bảng điểm"
file_path: "02_Attachments/Forms/PDT/mau_don_xin_cap_bang_diem.docx"
file_type: "docx"
mime_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
is_downloadable: true
download_url: ""
checksum: ""
validity_status: "valid"
is_latest: true
```

---

## 4. Quan hệ thủ tục - biểu mẫu

Trong file quy trình:

```yaml
required_forms:
  - form_id: "ctu-form-xin-cap-bang-diem"
    title: "Mẫu đơn xin cấp bảng điểm"
    file_path: "02_Attachments/Forms/PDT/mau_don_xin_cap_bang_diem.docx"
    download_url: ""
    required: true
    required_when: "Sinh viên xin cấp bảng điểm giấy"
```

Trong PostgreSQL:

```text
document_asset_links.relation_type = required_form
```

---

## 5. Quan hệ văn bản - version

Không dùng cùng một `version_id` cho nhiều bản khác nhau.

Bản cũ:

```yaml
version_id: "ctu-quy-dinh-hoc-vu-2021-v1"
is_latest: false
validity_status: "replaced"
rag_status: "deactivated"
replaced_by:
  - "ctu-quy-dinh-hoc-vu-2024-v1"
```

Bản mới:

```yaml
version_id: "ctu-quy-dinh-hoc-vu-2024-v1"
is_latest: true
validity_status: "valid"
rag_status: "published"
replaces:
  - "ctu-quy-dinh-hoc-vu-2021-v1"
```

---

## 6. Retrieval rule

Retriever mặc định chỉ lấy chunk thỏa:

```text
rag_status = published
validity_status = valid
confidentiality = public
```

Nếu bật strict latest mode:

```text
is_latest = true
```

Sau khi lấy chunk, backend phải join PostgreSQL để lấy asset/form:

```text
chunk.version_id
  → document_asset_links.version_id
  → document_assets.asset_id
```

Không nên nhồi toàn bộ metadata file vào Qdrant payload.

---

## 7. Trường hợp user hỏi biểu mẫu

Ví dụ user hỏi:

```text
Em muốn xin cấp bảng điểm thì cần mẫu đơn nào?
```

Luồng đúng:

```text
1. Intent = procedure/form lookup
2. Retrieve procedure chunks
3. Lấy version_id của procedure được chọn
4. Query required_forms/document_asset_links
5. Chỉ lấy asset valid + downloadable
6. Trả lời kèm citation văn bản và link/file biểu mẫu
```

---

## 8. Câu trả lời của chatbot nên có

```text
- Tên thủ tục
- Thành phần hồ sơ
- Biểu mẫu bắt buộc/tùy chọn
- File/link tải
- Nơi nộp
- Thời gian xử lý
- Căn cứ/citation
- Cảnh báo nếu tài liệu chưa kiểm tra hiệu lực
```

---

## 9. Không được làm

- Không trả biểu mẫu đã `replaced`, `expired`, `unchecked`.
- Không dùng tracking note làm nguồn RAG.
- Không xóa version cũ nếu đã từng index.
- Không overwrite file gốc.
- Không trả lời thủ tục từ tài liệu không có citation.
- Không dùng Qdrant làm nguồn kiểm soát hiệu lực.

---

## 10. Checklist governance

- [ ] Mỗi document có `document_id`.
- [ ] Mỗi version có `version_id`.
- [ ] Mỗi file/biểu mẫu quan trọng có `asset_id`.
- [ ] Có `source_path` tới file gốc.
- [ ] Có `file_path` hoặc `download_url` cho file tải.
- [ ] Có `replaces`/`replaced_by` nếu là version cũ/mới.
- [ ] Tài liệu cũ đã `deactivated`.
- [ ] Qdrant không retrieve tài liệu cũ ở chế độ mặc định.
- [ ] PostgreSQL có bảng `document_assets` và `document_asset_links`.
