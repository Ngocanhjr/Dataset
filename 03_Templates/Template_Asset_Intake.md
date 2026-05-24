---
asset_id: ""
title: ""
asset_type: "form"

# File / link
file_name: ""
file_path: ""
file_type: "docx"
is_downloadable: true
download_url: ""
source_url: ""
accessed_date: ""

# Liên kết
source_document: ""
related_procedure_ids: []
relation_type: "required_form"
required: false

# Trạng thái
collection_status: "link_collected"
validity_status: "unchecked"
review_status: "not_reviewed"
rag_status: "not_indexed"

next_action: "Tải file về 02_Attachments/Forms/ nếu link còn dùng được"
notes: ""

created_at: ""
updated_at: ""

tags:
  - ctu
  - asset
  - form
  - attachment-intake
---

# {{title}}

## Ghi chú thu thập

- Phát hiện asset/link/file liên quan trong tài liệu gốc.
- Chưa dùng file này làm nguồn RAG chính.
- Nếu là biểu mẫu cần tải về, lưu file thật vào `02_Attachments/Forms/`.

## Link tải


## File local


## Liên kết với tài liệu/thủ tục

| Tài liệu/thủ tục | Quan hệ | Ghi chú |
|---|---|---|
|  |  |  |

## Checklist

- [ ] Kiểm tra link tải còn hoạt động.
- [ ] Tải file về `02_Attachments/Forms/` nếu cần.
- [ ] Cập nhật `file_path` sau khi tải file.
- [ ] Kiểm tra file mở được.
- [ ] Liên kết asset này trong tracking note bằng `related_assets`.
- [ ] Khi chuẩn hóa chính thức, chuyển thông tin cần thiết sang `01_Dataset/`.
