# README - Templates cho NLCS Vault

Thư mục này chứa các template Markdown dùng để tạo tracking note và file dataset chuẩn cho RAG.

## Chọn template nào?

| Nhu cầu | Template | Nơi tạo file |
|---|---|---|
| Tracking file PDF/DOCX mới thu thập | `Template_Attachment_Intake.md` | `06_Processing/00_Attachment_Intake/` |
| Tracking biểu mẫu/link/file liên quan | `Template_Asset_Intake.md` | `06_Processing/00_Attachment_Intake/Assets/` |
| Văn bản/quy định/quyết định | `Template_VanBan.md` | `01_Dataset/<Domain>/` |
| Quy trình/thủ tục hành chính | `Template_QuyTrinh.md` | `01_Dataset/QuyTrinh/` |
| Biểu mẫu đã chuẩn hóa cho RAG | `Template_BieuMau.md` | `01_Dataset/MauDon/` |
| FAQ | `Template_FAQ.md` | `01_Dataset/FAQ/` |
| Mẫu tổng quát | `Document Template.md` | Tùy trường hợp |

## Quy tắc gọn cho giai đoạn thu thập

- Tracking note chỉ theo dõi file gốc và trạng thái OCR.
- Nếu phát hiện biểu mẫu/link liên quan, tạo asset note riêng.
- Trong tracking note chỉ dùng `related_assets` dạng wikilink:

```yaml
related_assets:
  - "[[asset-mau-don-cap-bang-diem]]"
```

Không ghi object YAML dài trong `related_assets` vì Obsidian Properties sẽ khó đọc.

## Quy tắc khi đưa vào RAG

- File gốc nằm ở `02_Attachments/`.
- File Markdown chính thức nằm ở `01_Dataset/`.
- Chỉ file đã review và còn hiệu lực mới nên index/publish.

Metadata tối thiểu khi tài liệu sẵn sàng cho RAG:

```yaml
review_status: "approved"
validity_status: "valid"
rag_status: "not_indexed"
```
