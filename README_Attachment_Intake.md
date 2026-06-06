# README - Attachment Intake

File này chỉ là trang điều hướng nhanh cho quy trình intake. Quy định chi tiết và enum chuẩn nằm ở các file sau:

```text
README.md
03_Templates/Template_Attachment_Intake.md
03_Templates/Template_Asset_Intake.md
03_Templates/Attachment_Intake_Metadata_Guide.md
03_Templates/Template_Metadata_Field_Guide.md
```

## Luồng ngắn

```text
02_Attachments
  -> 06_Processing/00_Attachment_Intake
  -> 06_Processing/01_OCR_Output
  -> 06_Processing/03_Markdown_Cleaning
  -> 06_Processing/04_Need_Review
  -> 01_Dataset
```

## Khi thêm file mới

1. Lưu file gốc vào `02_Attachments/`.
2. Tạo tracking note bằng `03_Templates/Template_Attachment_Intake.md`.
3. Nếu phát hiện biểu mẫu/link/file liên quan, tạo asset note bằng `03_Templates/Template_Asset_Intake.md`.
4. Chỉ dùng `related_assets` trong tracking note để link ngắn tới asset note.

## Enum dùng trong intake

```text
ocr_status:
not_started | processing | done | failed | need_review | not_required

processing_stage:
attachment_only | ocr_processing | ocr_output | ocr_failed | markdown_cleaning | need_review | dataset_ready | rag_published | blocked
```

Không dùng các giá trị cũ như `cleaning` hoặc `canonical_done`; dùng `markdown_cleaning` và `dataset_ready`.

## Enum canonical sau OCR

Khi tạo file trong `01_Dataset`, dùng `document_type` tiếng Việt:

```text
noi_quy | quy_trinh | bieu_mau | hoi_dap
```

Nếu tài liệu được chunk theo heading, dùng:

```yaml
chunking_strategy: "heading_aware_parent_child"
```
