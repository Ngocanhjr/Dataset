# NLCS Vault - CTU Student Service RAG

Vault này dùng để xây dựng nguồn tri thức cho đề tài:

> CTU Student Service: Chatbot hỗ trợ sinh viên hoàn thành thủ tục hành chính dựa trên RAG.

Mục tiêu của vault là quản lý tài liệu gốc, tracking OCR, chuẩn hóa Markdown, quản lý biểu mẫu/file liên quan và chuẩn bị dữ liệu để đưa vào RAG.

---

## 1. Luồng xử lý tổng quát

```text
Thu thập tài liệu gốc
→ tạo tracking note
→ nếu thấy biểu mẫu/link liên quan thì tạo asset note
→ OCR file gốc
→ làm sạch Markdown
→ review nội dung
→ tạo file canonical trong 01_Dataset
→ chunk/index vào RAG
```

Ở giai đoạn hiện tại, ưu tiên làm đúng 3 việc:

1. Lưu file gốc đúng chỗ.
2. Tạo tracking note để biết trạng thái xử lý.
3. Ghi nhận biểu mẫu/link/file liên quan bằng asset note riêng.

---

## 2. Cấu trúc thư mục chính

```text
NLCS/
├── 00_Dashboard/                  # Theo dõi tiến độ tổng quan
├── 01_Dataset/                    # Markdown canonical cho RAG
├── 02_Attachments/                # File gốc: PDF, DOCX, Forms, Images
├── 03_Templates/                  # Template Markdown/YAML
├── 04_RAG/                        # Chunk, indexing log, published data
├── 05_Research/                   # Ghi chú nghiên cứu, kiến trúc, DB, OCR
├── 06_Processing/                 # Tracking, OCR output, cleaning, review
└── 99_Archive/                    # Tài liệu cũ/hết hiệu lực/bị thay thế
```

---

## 3. Vai trò từng vùng

| Thư mục | Dùng để làm gì |
|---|---|
| `00_Dashboard/` | Theo dõi danh sách tài liệu, trạng thái OCR/RAG, file cần xử lý |
| `01_Dataset/` | Lưu bản Markdown chính thức sau khi OCR, làm sạch và review |
| `02_Attachments/` | Lưu file vật lý: PDF gốc, DOCX, biểu mẫu, ảnh scan |
| `03_Templates/` | Chứa các mẫu file `.md` để tạo tracking/dataset |
| `04_RAG/` | Lưu output phục vụ RAG: chunk preview, log embedding, log index |
| `05_Research/` | Lưu tài liệu thiết kế hệ thống, database, OCR pipeline, đánh giá chatbot |
| `06_Processing/` | Lưu tracking note, OCR output, file cần làm sạch, file cần review |
| `99_Archive/` | Lưu bản cũ, bản thay thế, tài liệu không còn dùng |

---

## 4. Quy trình thêm tài liệu mới

### Bước 1: Lưu file gốc

PDF gốc lưu vào:

```text
02_Attachments/PDFs/<PhongBan>/
```

Biểu mẫu/file tải về lưu vào:

```text
02_Attachments/Forms/<PhongBan>/
```

DOCX khác lưu vào:

```text
02_Attachments/DOCX/<PhongBan>/
```

---

### Bước 2: Tạo tracking note

Tạo file tracking trong:

```text
06_Processing/00_Attachment_Intake/
```

Dùng template:

```text
03_Templates/Template_Attachment_Intake.md
```

Tracking note chỉ dùng để theo dõi file gốc và trạng thái OCR. Không cần nhét toàn bộ metadata RAG vào đây.

---

### Bước 3: Nếu phát hiện biểu mẫu/link liên quan

Tạo asset note riêng trong:

```text
06_Processing/00_Attachment_Intake/Assets/
```

Dùng template:

```text
03_Templates/Template_Asset_Intake.md
```

Trong tracking note chỉ link ngắn tới asset:

```yaml
related_assets:
  - "[[asset-mau-don-cap-bang-diem]]"
```

Không nên ghi object YAML dài trong `related_assets`, vì Obsidian Properties sẽ hiển thị rối.

---

### Bước 4: OCR và làm sạch Markdown

OCR output lưu vào:

```text
06_Processing/01_OCR_Output/
```

File đang làm sạch lưu vào:

```text
06_Processing/03_Markdown_Cleaning/
```

File cần review lưu vào:

```text
06_Processing/04_Need_Review/
```

---

### Bước 5: Tạo bản canonical cho RAG

Khi tài liệu đã sạch và đã review, tạo file chính trong:

```text
01_Dataset/<Domain hoặc PhongBan>/
```

Ví dụ:

```text
01_Dataset/HocVu/quy-dinh-cong-tac-hoc-vu-2021.md
01_Dataset/QuyTrinh/quy-trinh-cap-bang-diem.md
01_Dataset/MauDon/mau-don-cap-bang-diem.md
```

---

## 5. Chọn template nào?

| Tình huống | Template |
|---|---|
| Tracking file PDF/DOCX mới thu thập | `Template_Attachment_Intake.md` |
| Tracking biểu mẫu/link/file liên quan mới phát hiện | `Template_Asset_Intake.md` |
| Văn bản/quy định/quyết định chính thức | `Template_VanBan.md` |
| Quy trình/thủ tục hành chính | `Template_QuyTrinh.md` |
| Biểu mẫu đã chuẩn hóa cho dataset/RAG | `Template_BieuMau.md` |
| FAQ | `Template_FAQ.md` |

---

## 6. Metadata tối thiểu nên dùng

### Tracking file gốc

```yaml
title: ""
source_file: ""
source_path: ""
file_type: "pdf"
ocr_status: "not_started"
processing_stage: "attachment_only"
canonical_markdown_path: ""
related_assets: []
next_action: "OCR file gốc sang Markdown"
```

### Asset intake

```yaml
asset_id: ""
title: ""
asset_type: "form"
download_url: ""
file_path: ""
collection_status: "link_collected"
source_document: ""
relation_type: "required_form"
next_action: ""
```

### Dataset canonical

```yaml
document_id: ""
version_id: ""
title: ""
document_type: ""
source_file: ""
validity_status: "valid"
is_latest: true
review_status: "approved"
rag_status: "not_indexed"
```

---

## 7. Quy ước trạng thái

### OCR

```text
not_started  = chưa OCR
processing   = đang OCR
done         = OCR xong
failed       = OCR lỗi
need_review  = cần kiểm tra lại
```

### Review

```text
not_reviewed = chưa duyệt
needs_fix    = cần sửa
approved     = đã duyệt
rejected     = loại bỏ
```

### Hiệu lực

```text
unchecked = chưa kiểm tra
valid     = còn hiệu lực
expired   = hết hiệu lực
replaced  = đã bị thay thế
unknown   = chưa rõ
```

### RAG

```text
not_indexed = chưa đưa vào RAG
chunked     = đã chia chunk
embedded    = đã embedding
indexed     = đã index
published   = đang dùng cho chatbot
deactivated = ngưng dùng
```

---

## 8. Nguyên tắc quan trọng

- Không dùng trực tiếp PDF/raw OCR làm nguồn chính cho RAG.
- Nguồn chính cho RAG là Markdown canonical trong `01_Dataset/`.
- File gốc trong `02_Attachments/` dùng để đối chiếu/audit.
- Tracking note trong `06_Processing/` chỉ dùng để theo dõi quá trình xử lý.
- Nếu gặp biểu mẫu/link liên quan, tạo asset note riêng thay vì nhét dữ liệu dài vào YAML.
- Không xóa bản cũ nếu tài liệu bị thay thế; chuyển sang `99_Archive/` hoặc đánh dấu `validity_status: "replaced"`.
- Chỉ tài liệu `review_status: "approved"` và `validity_status: "valid"` mới nên được publish cho RAG.

---

## 9. Trạng thái hiện tại của vault

Vault đang ở giai đoạn xây dựng cấu trúc và thu thập tài liệu. Vì vậy:

- `02_Attachments/` là nơi quan trọng nhất ở bước đầu.
- `06_Processing/00_Attachment_Intake/` dùng để tracking từng file.
- `01_Dataset/` có thể còn trống cho đến khi OCR và review xong.
- `04_RAG/` chỉ dùng sau khi đã có Markdown canonical.

Quy trình nên bắt đầu từ một vài PDF mẫu để kiểm tra end-to-end trước khi xử lý hàng loạt.
