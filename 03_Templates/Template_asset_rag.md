---
asset_id: ""
title: ""
asset_type: "downloadable_file"

# Phân loại
domain: ""
department: ""
audience:
  - "student"

# File / link / video
file_name: ""
file_path: ""
file_type: "url"
download_url: ""
source_url: ""
accessed_date: ""
is_downloadable: true

# Quan hệ với tài liệu / thủ tục / biểu mẫu
source_document_id: ""
source_version_id: ""
related_document_ids: []
related_version_ids: []
related_procedure_ids: []
related_form_ids: []
relation_type: "downloadable_file"
required: false
required_when: ""

# Hiệu lực / version
version: ""
is_latest: false
validity_status: "unchecked"
effective_date: ""
expiry_date: ""
replaces: []
replaced_by: []

# RAG
rag_status: "not_indexed"

# Kiểm soát
collection_status: "collected"
review_status: "not_reviewed"
created_at: ""
updated_at: ""
notes: ""

tags:
  - ctu
  - asset
  - rag
---

# {{title}}

## Mô tả ngắn cho chatbot

Tài nguyên này dùng để:  

## Loại tài nguyên

- 

## Link / file

- File trong vault:  
- Link tải/link xem:  
- Định dạng:  
- Có thể cung cấp cho sinh viên: Có / Không  

## Tài liệu gốc / nguồn phát hiện

| Document ID | Version ID | Quan hệ | Ghi chú |
|---|---|---|---|
|  |  | source_document |  |

## Thủ tục / biểu mẫu liên quan

| ID | Loại | Quan hệ | Ghi chú |
|---|---|---|---|
|  | procedure/form | downloadable_file |  |

## Hướng dẫn sử dụng

- 

## Điều kiện áp dụng

- 

## Từ khóa truy xuất

- 
- 
- 

## Trạng thái hiệu lực

- Tình trạng:  
- Phiên bản:  
- Là bản mới nhất:  

## Ghi chú cho RAG

- Chỉ trả tài nguyên này khi câu hỏi liên quan đúng tài liệu/thủ tục/biểu mẫu.
- Nếu tài nguyên là biểu mẫu, phần hướng dẫn nghiệp vụ phải nằm trong `Template_BieuMau.md`; file này chỉ lưu link/file asset.
- Nếu `validity_status` không phải `valid`, chatbot không nên khuyến nghị sử dụng hoặc cung cấp link tải.
- Nếu `is_latest: false`, chatbot phải ưu tiên bản được ghi trong `replaced_by`.
