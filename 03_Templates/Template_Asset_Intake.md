---
asset_id: ""
title: ""
asset_type: "downloadable_file"

# File / link / video
file_name: ""
file_path: ""
file_type: "url"
is_downloadable: true
download_url: ""
source_url: ""
accessed_date: ""

# Liên kết
source_document_id: ""
source_version_id: ""
related_procedure_ids: []
relation_type: "downloadable_file"
required: false
required_when: ""

# Trạng thái
collection_status: "link_collected"
validity_status: "unchecked"
review_status: "not_reviewed"
rag_status: "not_indexed"

next_action: "Kiểm tra link/file và lưu vào 02_Attachments nếu cần"
notes: ""

created_at: ""
updated_at: ""

tags:
  - ctu
  - asset
  - attachment-intake
---

# {{title}}

## Ghi chú thu thập

- Phát hiện asset/link/file/video liên quan trong tài liệu gốc.
- Chưa dùng file này làm nguồn RAG chính.
- Nếu là file cần tải về, lưu file thật vào `02_Attachments/`.
- Nếu là biểu mẫu cần mô tả nghiệp vụ, tạo file riêng bằng `Template_BieuMau.md`.

## Link tải


## File local


## Link video / tài nguyên ngoài


## Liên kết với tài liệu/thủ tục

| Tài liệu/thủ tục | Quan hệ | Ghi chú |
|---|---|---|
|  |  |  |

## Checklist

- [ ] Kiểm tra link tải còn hoạt động.
- [ ] Tải file về `02_Attachments/` nếu cần.
- [ ] Cập nhật `file_path` sau khi tải file.
- [ ] Kiểm tra file mở được.
- [ ] Liên kết asset này trong tracking note bằng `related_assets`.
- [ ] Khi chuẩn hóa chính thức, chuyển thông tin cần thiết sang `01_Dataset/`.
