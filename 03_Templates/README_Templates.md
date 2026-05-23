# README - Templates cho NLCS Obsidian RAG

Thư mục này chứa các template Markdown dùng để tạo tài liệu chuẩn cho vault `NLCS`.

## Cách dùng

1. Chọn đúng template theo loại tài liệu:
   - `Document Template.md`: mẫu tổng quát.
   - `Template_VanBan.md`: quyết định, quy định, quy chế, thông báo.
   - `Template_QuyTrinh.md`: quy trình, thủ tục hành chính.
   - `Template_BieuMau.md`: biểu mẫu, đơn, file DOCX/PDF cần tải.
   - `Template_FAQ.md`: câu hỏi thường gặp.
2. Tạo file mới trong `01_Dataset/<đơn vị hoặc lĩnh vực>/`.
3. Copy template vào file mới.
4. Điền YAML frontmatter.
5. Đưa nội dung OCR / Markdown chuẩn hóa vào mục `# Nội dung OCR / Markdown chuẩn hóa`.
6. Review, sau đó cập nhật:

```yaml
ocr_status: "done"
review_status: "approved"
validity_status: "valid"
rag_status: "published"
```

## Quy tắc quan trọng

- Không dùng field `status` chung chung.
- Luôn dùng các trạng thái riêng: `collection_status`, `ocr_status`, `review_status`, `rag_status`, `validity_status`.
- Mỗi tài liệu có `document_id`.
- Mỗi phiên bản có `version_id`.
- Tài liệu mới nhất nên có `is_latest: true`.
- Tài liệu cũ bị thay thế nên có `validity_status: "replaced"` và `rag_status: "deactivated"`.
