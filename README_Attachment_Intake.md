# README - Attachment Intake

Thư mục `06_Processing/00_Attachment_Intake/` dùng để tracking các file gốc vừa thu thập trước khi OCR và chuẩn hóa vào `01_Dataset/`.

## Khi thêm file mới

1. Lưu file gốc vào `02_Attachments/`.
2. Tạo tracking note trong `06_Processing/00_Attachment_Intake/`.
3. Dùng template `03_Templates/Template_Attachment_Intake.md`.
4. Cập nhật `ocr_status`, `processing_stage`, `next_action`.

## Khi thấy biểu mẫu/link/file liên quan

Không ghi chi tiết dài trong tracking note. Tạo asset note riêng tại:

```text
06_Processing/00_Attachment_Intake/Assets/
```

Dùng template:

```text
03_Templates/Template_Asset_Intake.md
```

Trong tracking note chính chỉ link:

```yaml
related_assets:
  - "[[asset-mau-don-cap-bang-diem]]"
```

## Trạng thái OCR

```text
not_started   = chưa OCR
processing    = đang OCR
done          = OCR xong
failed        = OCR lỗi
need_review   = OCR cần kiểm tra lại
```

## Giai đoạn xử lý

```text
attachment_only = mới có file gốc
ocr_processing  = đang OCR
ocr_output      = đã có output OCR
cleaning        = đang làm sạch Markdown
need_review     = cần review
canonical_done  = đã tạo file canonical trong 01_Dataset
```

## Sau khi OCR

- Lưu file OCR vào `06_Processing/01_OCR_Output/`.
- Chuyển file cần làm sạch sang `06_Processing/03_Markdown_Cleaning/`.
- Chuyển file cần review sang `06_Processing/04_Need_Review/`.
- Sau khi duyệt, tạo file chính trong `01_Dataset/`.
