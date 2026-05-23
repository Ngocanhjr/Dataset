---
title: ""
source_file: ""
source_path: ""

document_id: ""
version_id: ""

ocr_status: "not_started"
processing_stage: "attachment_only"
ocr_output_file:

assignee:
next_action: "OCR file gốc sang Markdown"
due_date:
blocker:

created_at:
updated_at:

tags:
  - attachment-intake
  - ocr
---

# OCR Tracking

## File gốc

- File: 
- Đường dẫn: 

## Trạng thái

```yaml
ocr_status: "not_started"
processing_stage: "attachment_only"
```

## Checklist OCR

- [ ] OCR file gốc sang Markdown.
- [ ] Lưu kết quả OCR vào `06_Processing/01_OCR_Output`.
- [ ] Kiểm tra lỗi OCR: mất dấu, sai bảng, thiếu trang.
- [ ] Cập nhật `ocr_status`.
- [ ] Cập nhật `ocr_output_file` nếu đã có file OCR.
- [ ] Chuyển bản cần làm sạch sang `06_Processing/03_Markdown_Cleaning`.
- [ ] Chuyển bản cần review sang `06_Processing/04_Need_Review`.
- [ ] Khi đã chuẩn hóa xong, tạo/cập nhật file chính trong `01_Dataset`.

## Ghi chú

- Chưa đưa vào RAG.
- Chưa kiểm tra hiệu lực.
- Chưa có bản Markdown canonical trong `01_Dataset`.
