---
asset_id: ""
title: ""
asset_type: "form"

# Phân loại nghiệp vụ
domain: ""
department: ""
audience:
  - "student"

# File / link tải
file_name: ""
file_path: ""
file_type: "docx"
download_url: ""
source_url: ""
is_downloadable: true

# Quan hệ với tài liệu / thủ tục
related_document_ids: []
related_procedure_ids: []
relation_type: "required_form"
required: true
required_when: ""

# Hiệu lực / version
version: "1.0"
is_latest: true
validity_status: "valid"
effective_date: ""
expiry_date: ""
replaces: []
replaced_by: []

# RAG
rag_include: true
rag_status: "ready_to_index"
retrieval_keywords: []

# Kiểm soát
review_status: "reviewed"
created_at: ""
updated_at: ""
notes: ""

tags:
  - ctu
  - asset
  - form
  - rag
---

# {{title}}

## Mô tả ngắn cho chatbot

Biểu mẫu này dùng để:  

## Khi nào sinh viên cần dùng biểu mẫu này?

- 

## Thủ tục liên quan

| Mã thủ tục | Tên thủ tục | Quan hệ | Ghi chú |
|---|---|---|---|
|  |  | required_form |  |

## Văn bản / tài liệu liên quan

| Mã tài liệu | Tên tài liệu | Ghi chú |
|---|---|---|
|  |  |

## Hướng dẫn tải / sử dụng

- File trong vault:  
- Link tải ngoài:  
- Định dạng file:  
- Sinh viên có thể tải: Có / Không  

## Điều kiện áp dụng

- 

## Trạng thái hiệu lực

- Tình trạng:  
- Phiên bản:  
- Là bản mới nhất:  

## Ghi chú cho RAG

- Chỉ trả biểu mẫu này khi câu hỏi liên quan đúng thủ tục.
- Nếu `validity_status` không phải `valid`, chatbot không nên khuyến nghị sử dụng.
- Nếu `is_latest: false`, chatbot phải ưu tiên bản được ghi trong `replaced_by`.