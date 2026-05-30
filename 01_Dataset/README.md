# README - 01_Dataset

Cập nhật: `2026-05-24`

`01_Dataset` là nơi lưu **Markdown canonical** đã chuẩn hóa. Đây là nguồn chính để backend đọc YAML, validate metadata, chunk, embedding và index vào Qdrant.

---

## 1. Không lưu file gốc ở đây

Không đặt PDF/DOCX/Image gốc trong `01_Dataset`.

File gốc đặt tại:

```text
02_Attachments/PDFs/
02_Attachments/DOCX/
02_Attachments/Forms/
02_Attachments/Images/
```

---

## 2. Mỗi tài liệu/version là một file Markdown riêng

Ví dụ:

```text
01_Dataset/HocVu/ctu-quy-dinh-cong-tac-hoc-vu-2021-v1.md
01_Dataset/HocVu/ctu-quy-dinh-cong-tac-hoc-vu-2024-v1.md
```

Bản cũ không xóa. Đánh dấu:

```yaml
is_latest: false
validity_status: "replaced"
rag_status: "deactivated"
```

---

## 3. Biểu mẫu và asset tải về

```text
01_Dataset/MauDon/<form>.md
```

Dùng để mô tả nghiệp vụ của biểu mẫu: mục đích, khi nào dùng, hướng dẫn điền, thủ tục liên quan.

```text
02_Attachments/Forms/<DonVi>/<form>.docx
```

Dùng làm file tải về thực tế. Metadata file tải nên nằm trong asset canonical hoặc asset intake, không nhồi trực tiếp vào mô tả biểu mẫu.

Trong file biểu mẫu canonical, trỏ đến asset/file tải bằng ID:

```yaml
related_asset_ids:
  - "ctu-form-xin-cap-bang-diem"
```

Trong file asset canonical, khai báo đường dẫn file tải:

```yaml
asset_id: "ctu-form-xin-cap-bang-diem"
file_path: "02_Attachments/Forms/PDT/mau_don_xin_cap_bang_diem.docx"
is_downloadable: true
```

---

## 4. Điều kiện được backend ingest

```yaml
ocr_status: "done"
review_status: "approved"
validity_status: "valid"
rag_status: "published"
confidentiality: "public"
```

Nếu chưa chắc hiệu lực:

```yaml
validity_status: "unchecked"
rag_status: "not_indexed"
```

---

## 5. Checklist trước khi đưa vào RAG

- [ ] Đã dùng đúng template.
- [ ] Có `document_id`, `version_id`.
- [ ] Có `source_file` hoặc `source_url`.
- [ ] Có page marker nếu cần citation.
- [ ] Có `related_asset_ids` hoặc `required_form_ids` nếu tài liệu có biểu mẫu.
- [ ] Đã kiểm tra version cũ/mới.
- [ ] Đã kiểm tra hiệu lực.
- [ ] Đã review nội dung.
- [ ] Đã cập nhật trạng thái publish.
