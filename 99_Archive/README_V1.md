# README_V1 - Bản ghi chú cũ

Cập nhật: `2026-05-24`

File này được giữ lại để tham khảo lịch sử. README chính hiện tại là:

```text
README.md
```

Các thay đổi quan trọng đã được đưa vào tài liệu vận hành hiện tại:

- Bổ sung quản lý `asset_id` cho biểu mẫu/file liên quan.
- Bổ sung `related_assets`, `related_asset_ids`, `required_form_ids`.
- Phân biệt `source_file` với file tải về cho sinh viên.
- Bổ sung rule version cũ/mới bằng `replaces`, `replaced_by`, `is_latest`.
- Bổ sung PostgreSQL schema cho `document_assets`, `document_asset_links`, `document_relationships`.
- Bổ sung rule Qdrant chỉ lưu ID liên quan asset, backend join PostgreSQL để lấy link/file chính xác.

Không nên tiếp tục chỉnh `README_V1.md` cho vận hành mới. Hãy dùng:

```text
README.md
03_Templates/README_Templates.md
03_Templates/Template_Metadata_Field_Guide.md
05_Research/Asset_Form_Version_Governance.md
05_Research/Database_rule.md
```
