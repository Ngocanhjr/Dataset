---
title: ""
source_file: ""
source_path: ""
file_type: "pdf"
checksum: ""

document_id: ""
version_id: ""
asset_id: ""

# OCR chỉ tracking file gốc, không thay thế metadata canonical trong 01_Dataset
ocr_status: "not_started"
processing_stage: "attachment_only"
ocr_output_file: ""

# Liên kết sau khi chuẩn hóa
canonical_markdown_path: ""

related_assets:
  - asset_type: "form"
    title: "Mẫu đơn cấp bảng điểm"
    download_url: "https://example.ctu.edu.vn/mau-don-cap-bang-diem.docx"
    file_path: ""
    collection_status: "link_collected"
    note: "Phát hiện link biểu mẫu trong PDF, chưa tải file"

related_forms:
  - form_id: "mau-don-cap-bang-diem"
    title: "Mẫu đơn cấp bảng điểm"
    download_url: "https://example.ctu.edu.vn/mau-don-cap-bang-diem.docx"
    file_path: ""
    required: true

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

- File:
- Đường dẫn:
- Loại file:
- Checksum:

## Trạng thái

```yaml
ocr_status: "not_started"
processing_stage: "attachment_only"
```

## Liên kết sau xử lý

| Loại                     | Đường dẫn / ID | Ghi chú                                     |
| ------------------------ | -------------- | ------------------------------------------- |
| Canonical Markdown       |                | File chính trong `01_Dataset`               |
| Asset/Biểu mẫu liên quan |                | Nếu file gốc có đính kèm hoặc link biểu mẫu |
| Version thay thế         |                | Nếu phát hiện đây là bản mới/cũ             |

## Checklist OCR

- [ ] OCR file gốc sang Markdown.
- [ ] Lưu kết quả OCR vào `06_Processing/01_OCR_Output`.
- [ ] Kiểm tra lỗi OCR: mất dấu, sai bảng, thiếu trang.
- [ ] Cập nhật `ocr_status`.
- [ ] Cập nhật `ocr_output_file` nếu đã có file OCR.
- [ ] Chuyển bản cần làm sạch sang `06_Processing/03_Markdown_Cleaning`.
- [ ] Chuyển bản cần review sang `06_Processing/04_Need_Review`.
- [ ] Khi đã chuẩn hóa xong, tạo/cập nhật file chính trong `01_Dataset`.
- [ ] Nếu có biểu mẫu/file tải về, tạo metadata bằng `Template_Asset.md` hoặc `Template_BieuMau.md`.
- [ ] Cập nhật `canonical_markdown_path` sau khi có file chính.

## Ghi chú

- File tracking này chỉ dùng cho OCR/intake.
- Không đưa tracking note vào RAG.
- Không dùng tracking note thay thế file Markdown canonical trong `01_Dataset`.
- Chưa kiểm tra hiệu lực thì giữ `validity_status: "unchecked"` ở file canonical.
