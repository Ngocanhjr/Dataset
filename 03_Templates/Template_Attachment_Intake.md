---
title: ""
source_file: ""
source_path: ""
file_type: "pdf"
checksum: ""

document_id: ""
version_id: ""

# Tracking OCR file gốc
ocr_status: "not_started"
processing_stage: "attachment_only"
ocr_output_file: ""
canonical_markdown_path: ""

# Chỉ link tới asset note, không ghi object YAML dài ở đây
# Ví dụ:
# related_assets:
#   - "[[asset-mau-don-cap-bang-diem]]"
related_assets: []

assignee: ""
next_action: "OCR file gốc sang Markdown"
due_date: ""
blocker: ""

created_at: ""
updated_at: ""

tags:
  - attachment-intake
  - ocr
---

# OCR Tracking

## File gốc

| Mục | Nội dung |
|---|---|
| Tên file |  |
| Đường dẫn |  |
| Loại file |  |
| Checksum |  |

## Trạng thái xử lý

```yaml
ocr_status: "not_started"
processing_stage: "attachment_only"
```

## Asset / biểu mẫu liên quan

Nếu trong file gốc có link biểu mẫu hoặc file liên quan, tạo asset note trong:

```text
06_Processing/00_Attachment_Intake/Assets/
```

Sau đó link tại metadata:

```yaml
related_assets:
  - "[[asset-ten-bieu-mau]]"
```

Không ghi chi tiết asset trực tiếp trong tracking note.

## Checklist OCR

- [ ] OCR file gốc sang Markdown.
- [ ] Lưu kết quả OCR vào `06_Processing/01_OCR_Output/`.
- [ ] Kiểm tra lỗi OCR: mất dấu, sai bảng, thiếu trang.
- [ ] Cập nhật `ocr_status`.
- [ ] Cập nhật `ocr_output_file` nếu đã có file OCR.
- [ ] Chuyển bản cần làm sạch sang `06_Processing/03_Markdown_Cleaning/`.
- [ ] Chuyển bản cần review sang `06_Processing/04_Need_Review/`.
- [ ] Khi đã chuẩn hóa xong, tạo/cập nhật file chính trong `01_Dataset/`.

## Ghi chú

- Chưa đưa vào RAG.
- Chưa kiểm tra hiệu lực.
- Chưa có bản Markdown canonical trong `01_Dataset/`.
