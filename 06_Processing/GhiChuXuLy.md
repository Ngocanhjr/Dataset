# Ghi chú xử lý tài liệu

File này dùng để ghi lại lỗi OCR, lỗi Markdown, lỗi metadata và quyết định xử lý.

## Log xử lý

| Ngày | File | Vấn đề | Cách xử lý | Trạng thái |
|---|---|---|---|---|
|  |  |  |  |  |

## Lỗi thường gặp

- Mất dấu tiếng Việt.
- Sai thứ tự cột trong bảng.
- Header/footer lặp lại.
- Mất số trang.
- Sai tên phòng ban.
- Sai ngày hiệu lực.
- Văn bản có version mới hơn nhưng chưa cập nhật metadata.

## Quy tắc quyết định

- OCR lỗi nhẹ: sửa Markdown trong `01_Dataset`.
- OCR lỗi nặng: đưa vào `06_Processing/Need_Review`.
- Không xác định được hiệu lực: `validity_status: "unchecked"`.
- Bị thay thế: `validity_status: "replaced"`, `rag_status: "deactivated"`.
- Chỉ publish khi đã có `review_status: "approved"` và `validity_status: "valid"`.
