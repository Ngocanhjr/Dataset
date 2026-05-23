Mục đích:

- Mỗi PDF trong `02_Attachments` có một tracking note.
- Team xem dashboard để biết file nào mới chỉ thêm attachment, file nào đã vào processing, file nào cần OCR/review.
- Các tracking note có thể được cập nhật `assignee`, `next_action`, `due_date`, `blocker`.

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
```

Sau khi OCR xong, lưu file OCR vào:

```text
06_Processing/01_OCR_Output
```

Sau đó formatter/cleaning/review sẽ xử lý tiếp trước khi tạo file chính trong `01_Dataset`.
