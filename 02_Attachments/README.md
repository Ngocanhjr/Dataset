# README - 02_Attachments

Cập nhật: `2026-05-24`

`02_Attachments` là nơi lưu **file vật lý** dùng để đối chiếu, audit hoặc cung cấp tải về cho sinh viên.

---

## 1. Cấu trúc

```text
02_Attachments/
├── PDFs/     # PDF gốc từ website/phòng ban
├── DOCX/     # DOCX nguồn hoặc văn bản liên quan
├── Forms/    # Biểu mẫu sinh viên có thể tải về
└── Images/   # Ảnh scan/screenshot/minh chứng
```

---

## 2. Phân biệt file gốc và file tải về

| Field YAML | Ý nghĩa |
|---|---|
| `source_file` | File gốc để đối chiếu/audit |
| `source_path` | Đường dẫn file gốc trong vault |
| `file_path` | Đường dẫn file asset/biểu mẫu |
| `download_url` | Link tải ngoài nếu có |
| `downloadable_files` | Danh sách file chatbot có thể trả cho sinh viên |
| `required_forms` | Danh sách biểu mẫu bắt buộc trong thủ tục |

---

## 3. Quy tắc đặt file biểu mẫu

```text
02_Attachments/Forms/<DonVi>/<ten_bieu_mau>.<docx|pdf>
```

Ví dụ:

```text
02_Attachments/Forms/PDT/mau_don_xin_cap_bang_diem.docx
02_Attachments/Forms/CTSV/mau_xac_nhan_sinh_vien.pdf
```

---

## 4. Khi thêm một file mới

- [ ] Đặt đúng thư mục.
- [ ] Không đổi nội dung file gốc.
- [ ] Tạo tracking note trong `06_Processing/00_Attachment_Intake` nếu cần OCR.
- [ ] Tạo/cập nhật Markdown canonical trong `01_Dataset`.
- [ ] Nếu là biểu mẫu/file tải về, tạo `asset_id`.
- [ ] Cập nhật `source_path`, `file_path`, `download_url` trong YAML.
- [ ] Tính `checksum` nếu cần phát hiện file bị thay đổi.

---

## 5. Không làm

- Không chunk trực tiếp file trong `02_Attachments`.
- Không dùng file gốc thay thế Markdown canonical.
- Không xóa file cũ nếu file đó thuộc version đã từng dùng.
- Không trả link tải cho chatbot nếu chưa kiểm tra hiệu lực.
