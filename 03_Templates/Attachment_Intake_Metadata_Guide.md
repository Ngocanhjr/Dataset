---
title: "Giải thích metadata tracking trước OCR"
document_type: "huong_dan_metadata"
domain: "attachment_intake"
department: "NLCS"
status: "active"
created_at: "2026-05-27"
updated_at: "2026-05-27"
tags:
  - attachment-intake
  - ocr
  - metadata
  - guide
---
	
# Giải thích metadata tracking trước OCR

File này giải thích ý nghĩa các trường metadata dùng trong tracking note trước OCR, thường tạo từ:

```text
03_Templates/Template_Attachment_Intake.md
```

Tracking note trước OCR dùng để theo dõi một file gốc trong `02_Attachments`, không phải là nguồn nội dung chính cho RAG. Nguồn chính cho RAG vẫn là Markdown canonical sau khi đã OCR, làm sạch và review trong `01_Dataset`.

---

## 1. Mục đích chung

Metadata tracking trước OCR trả lời các câu hỏi:

- File gốc là file nào?
- File gốc đang nằm ở đâu?
- File đã OCR chưa?
- Kết quả OCR sẽ lưu ở đâu?
- Sau khi clean/review, file canonical nằm ở đâu?
- File này có liên quan đến biểu mẫu hoặc asset nào không?
- Ai đang xử lý và bước tiếp theo là gì?

Tracking note giúp không bị mất dấu tài liệu trong quy trình:

```text
02_Attachments
  -> 06_Processing/00_Attachment_Intake
  -> 06_Processing/01_OCR_Output
  -> 06_Processing/03_Markdown_Cleaning
  -> 06_Processing/04_Need_Review
  -> 01_Dataset
  -> 04_RAG
```

---

## 2. Nhóm nhận diện file gốc

### `title`

Tên dễ đọc của tài liệu đang tracking.

Mục đích:

- Hiển thị trên dashboard.
- Giúp người xử lý nhận biết nhanh nội dung tài liệu.
- Không bắt buộc phải giống hệt tên file vật lý.

Ví dụ:

```yaml
title: "Quy trình xét miễn học phần"
```

Gợi ý:

- Nên viết tiếng Việt có dấu nếu đã biết rõ tên tài liệu.
- Nếu chưa biết tên chính thức, có thể dùng tên file tạm rồi sửa sau.

---

### `source_file`

Tên file gốc, thường dùng dạng wikilink trong Obsidian.

Mục đích:

- Liên kết tracking note với file PDF/DOCX/Image gốc.
- Giúp mở nhanh file gốc để đối chiếu OCR.

Ví dụ:

```yaml
source_file: "[[qt_xet_mien_HP.pdf]]"
```

Gợi ý:

- Chỉ ghi tên file hoặc wikilink.
- Đường dẫn đầy đủ nên đặt ở `source_path`.

---

### `source_path`

Đường dẫn tương đối đến file gốc trong vault.

Mục đích:

- Dùng để audit file gốc.
- Dùng cho script hoặc người xử lý tìm đúng file.
- Giúp phát hiện tracking note trỏ sai thư mục.

Ví dụ:

```yaml
source_path: "02_Attachments/PDFs/PDT/qt_xet_mien_HP.pdf"
```

Gợi ý:

- Nên dùng đường dẫn tương đối từ gốc vault.
- Cần khớp đúng tên thư mục và tên file thật.
- Đây là field quan trọng nhất để nối tracking note với attachment.

---

### `file_type`

Loại file gốc.

Mục đích:

- Cho biết cần dùng parser/OCR nào.
- Hỗ trợ phân luồng xử lý: PDF text, scan PDF, DOCX, image.

Ví dụ:

```yaml
file_type: "pdf"
```

Giá trị thường dùng:

```text
pdf
docx
image
html
```

Gợi ý:

- Với PDF scan vẫn để `pdf`; chi tiết OCR engine/parser có thể ghi ở file canonical hoặc log xử lý.

---

### `checksum`

Mã kiểm tra nội dung file, thường là SHA256.

Mục đích:

- Phát hiện file gốc có bị thay đổi không.
- Phân biệt hai file trùng tên hoặc hai bản khác nhau.
- Hỗ trợ phát hiện file duplicate.

Ví dụ:

```yaml
checksum: "sha256:..."
```

Gợi ý:

- Có thể để trống ở giai đoạn đầu.
- Nên điền khi xử lý hàng loạt hoặc khi cần kiểm soát version nghiêm ngặt.

---

## 3. Nhóm định danh tài liệu

### `document_id`

ID chung cho một nhóm tài liệu hoặc một loại thủ tục/văn bản.

Mục đích:

- Gom các version khác nhau của cùng một tài liệu.
- Dùng để nối với file canonical trong `01_Dataset`.
- Sau này có thể đồng bộ sang PostgreSQL.

Ví dụ:

```yaml
document_id: "ctu-quy-trinh-xet-mien-hoc-phan"
```

Gợi ý:

- Có thể để trống nếu chưa xác định rõ.
- Nên dùng chữ thường, không dấu, nối bằng dấu gạch ngang.
- Không nên tạo `document_id` quá phụ thuộc vào tên file nếu tài liệu có thể có nhiều version.

---

### `version_id`

ID cho một phiên bản cụ thể của tài liệu.

Mục đích:

- Phân biệt bản năm 2021, 2024, bản v1, v2 hoặc bản sửa đổi.
- Tránh ghi đè version cũ.
- Là khóa quan trọng khi chunk/index vào RAG.

Ví dụ:

```yaml
version_id: "ctu-quy-trinh-xet-mien-hoc-phan-2024-v1"
```

Gợi ý:

- Có thể để trống trước OCR nếu chưa biết số hiệu/ngày ban hành.
- Khi tạo canonical Markdown nên điền chắc chắn.

---

## 4. Nhóm trạng thái OCR và xử lý

### `ocr_status`

Trạng thái OCR của file gốc.

Mục đích:

- Cho biết tài liệu đã OCR chưa.
- Giúp dashboard lọc file chưa xử lý, đang xử lý hoặc bị lỗi.

Ví dụ ban đầu:

```yaml
ocr_status: "not_started"
```

Giá trị khuyến nghị:

```text
not_started  = chưa OCR
processing   = đang OCR
done         = OCR xong
failed       = OCR lỗi
need_review  = OCR xong nhưng cần kiểm tra kỹ
```

Gợi ý:

- Khi mới tạo tracking note, dùng `not_started`.
- Khi OCR lỗi nặng, dùng `failed` và ghi lý do vào `blocker` hoặc phần ghi chú.

---

### `processing_stage`

Giai đoạn hiện tại của file trong pipeline xử lý.

Mục đích:

- Theo dõi file đang nằm ở bước nào.
- Bổ sung ngữ cảnh cho `ocr_status`.
- Giúp dashboard phân biệt file mới thu thập, file đã OCR, file đang clean, file đã vào dataset.

Ví dụ ban đầu:

```yaml
processing_stage: "attachment_only"
```

Giá trị khuyến nghị:

```text
attachment_only    = mới có file gốc, chưa OCR
ocr_processing     = đang OCR
ocr_output         = đã có output OCR
ocr_failed         = OCR lỗi
markdown_cleaning  = đang làm sạch Markdown
need_review        = cần review nội dung
dataset_ready      = đã tạo/cập nhật file canonical trong 01_Dataset
rag_published      = đã publish vào RAG
blocked            = đang bị chặn
```

Gợi ý:

- Nên thống nhất một bộ giá trị duy nhất cho toàn vault.
- Không nên dùng lẫn `cleaning` và `markdown_cleaning`, hoặc `canonical_done` và `dataset_ready`.

---

### `ocr_output_file`

Đường dẫn đến file Markdown OCR tạm.

Mục đích:

- Ghi lại output đầu tiên sau OCR/parser.
- Giúp đối chiếu giữa file gốc và bản OCR thô.
- Cho biết đã có artifact OCR để tiếp tục cleaning.

Ví dụ:

```yaml
ocr_output_file: "06_Processing/01_OCR_Output/qt_xet_mien_HP_ocr.md"
```

Gợi ý:

- Để trống khi chưa OCR.
- Sau khi OCR xong, cập nhật field này ngay.
- File OCR output chưa nên dùng làm nguồn RAG chính.

---

### `canonical_markdown_path`

Đường dẫn đến file Markdown chính thức trong `01_Dataset`.

Mục đích:

- Nối tracking note với file canonical đã clean/review.
- Giúp biết file gốc này cuối cùng đã trở thành tài liệu RAG nào.
- Hỗ trợ audit từ RAG answer quay ngược về file gốc.

Ví dụ:

```yaml
canonical_markdown_path: "01_Dataset/PDT/ctu-quy-trinh-xet-mien-hoc-phan.md"
```

Gợi ý:

- Để trống trước OCR.
- Chỉ điền khi đã có file canonical thật.
- Đây là cầu nối quan trọng giữa tracking trước OCR và quy trình RAG.

---

## 5. Nhóm asset và biểu mẫu liên quan

### `related_assets`

Danh sách asset note liên quan đến file gốc, ví dụ biểu mẫu, link tải, phụ lục, file DOCX.

Mục đích:

- Tách thông tin biểu mẫu/file liên quan khỏi tracking note chính.
- Giữ metadata tracking gọn.
- Cho phép quản lý biểu mẫu như một đối tượng riêng.

Ví dụ:

```yaml
related_assets:
  - "[[asset-mau-don-xet-mien-hoc-phan]]"
```

Gợi ý:

- Chỉ dùng wikilink ngắn.
- Không ghi object YAML dài trong `related_assets`.
- Chi tiết asset nên nằm trong `06_Processing/00_Attachment_Intake/Assets/`.

---

## 6. Nhóm phân công và điều phối

### `assignee`

Người phụ trách xử lý file này.

Mục đích:

- Tránh nhiều người xử lý trùng một tài liệu.
- Giúp dashboard lọc công việc theo người.

Ví dụ:

```yaml
assignee: "Bao"
```

Gợi ý:

- Có thể để trống nếu làm một mình.
- Nên điền nếu làm nhóm.

---

### `next_action`

Việc tiếp theo cần làm.

Mục đích:

- Cho biết bước xử lý kế tiếp.
- Giúp mở dashboard là biết cần làm gì ngay.

Ví dụ ban đầu:

```yaml
next_action: "OCR file gốc sang Markdown"
```

Ví dụ sau OCR:

```yaml
next_action: "Làm sạch Markdown và kiểm tra page marker"
```

Gợi ý:

- Nên viết ngắn, rõ, bắt đầu bằng động từ.
- Cập nhật field này mỗi khi chuyển stage.

---

### `due_date`

Hạn xử lý dự kiến.

Mục đích:

- Theo dõi deadline.
- Cho phép dashboard lọc việc quá hạn.

Ví dụ:

```yaml
due_date: "2026-05-30"
```

Gợi ý:

- Dùng định dạng `YYYY-MM-DD`.
- Có thể để trống nếu không quản lý deadline.

---

### `blocker`

Vướng mắc đang chặn việc xử lý.

Mục đích:

- Ghi lý do chưa thể OCR/clean/review.
- Giúp dashboard hiển thị việc đang bị chặn.

Ví dụ:

```yaml
blocker: "PDF scan mờ, cần OCR lại bằng engine khác"
```

Gợi ý:

- Để trống nếu không có vướng mắc.
- Nếu `processing_stage: "blocked"` thì nên có `blocker`.

---

## 7. Nhóm thời gian và audit

### `created_at`

Ngày tạo tracking note.

Mục đích:

- Biết tài liệu được đưa vào vault khi nào.
- Hỗ trợ audit lịch sử xử lý.

Ví dụ:

```yaml
created_at: "2026-05-27"
```

Gợi ý:

- Dùng định dạng `YYYY-MM-DD`.

---

### `updated_at`

Ngày cập nhật tracking note gần nhất.

Mục đích:

- Dashboard có thể sort theo lần cập nhật.
- Biết file nào lâu chưa được xử lý.

Ví dụ:

```yaml
updated_at: "2026-05-27"
```

Gợi ý:

- Cập nhật khi đổi `ocr_status`, `processing_stage`, `next_action`, `ocr_output_file` hoặc `canonical_markdown_path`.

---

## 8. Nhóm phân loại Obsidian

### `tags`

Tag dùng để phân loại note trong Obsidian.

Mục đích:

- Tìm kiếm nhanh.
- Lọc tracking note.
- Phân biệt tracking note với canonical dataset.

Ví dụ:

```yaml
tags:
  - attachment-intake
  - ocr
```

Gợi ý:

- Tracking trước OCR nên luôn có `attachment-intake` và `ocr`.
- Không cần gắn quá nhiều tag nếu dashboard đã dựa vào folder và metadata.

---

## 9. Field nào bắt buộc, field nào có thể để trống?

### Nên điền ngay khi tạo tracking note

```yaml
title: ""
source_file: ""
source_path: ""
file_type: "pdf"
ocr_status: "not_started"
processing_stage: "attachment_only"
next_action: "OCR file gốc sang Markdown"
created_at: ""
updated_at: ""
tags:
  - attachment-intake
  - ocr
```

### Có thể để trống lúc mới tạo

```yaml
checksum: ""
document_id: ""
version_id: ""
ocr_output_file: ""
canonical_markdown_path: ""
related_assets: []
assignee: ""
due_date: ""
blocker: ""
```

### Nên cập nhật sau OCR

```yaml
ocr_status: "done"
processing_stage: "ocr_output"
ocr_output_file: "06_Processing/01_OCR_Output/<file>_ocr.md"
next_action: "Làm sạch Markdown và chuyển sang review"
updated_at: ""
```

### Nên cập nhật sau khi có canonical Markdown

```yaml
processing_stage: "dataset_ready"
canonical_markdown_path: "01_Dataset/<folder>/<file>.md"
next_action: "Theo dõi review và publish trong file canonical"
updated_at: ""
```

---

## 10. Ví dụ hoàn chỉnh

```yaml
---
title: "Quy trình xét miễn học phần"
source_file: "[[qt_xet_mien_HP.pdf]]"
source_path: "02_Attachments/PDFs/PDT/qt_xet_mien_HP.pdf"
file_type: "pdf"
checksum: ""

document_id: "ctu-quy-trinh-xet-mien-hoc-phan"
version_id: "ctu-quy-trinh-xet-mien-hoc-phan-v1"

ocr_status: "not_started"
processing_stage: "attachment_only"
ocr_output_file: ""
canonical_markdown_path: ""

related_assets: []

assignee: ""
next_action: "OCR file gốc sang Markdown"
due_date: ""
blocker: ""

created_at: "2026-05-27"
updated_at: "2026-05-27"

tags:
  - attachment-intake
  - ocr
---
```

---

## 11. Nguyên tắc sử dụng

- Tracking note chỉ theo dõi quá trình xử lý file gốc.
- Không dùng tracking note làm nguồn nội dung cho RAG.
- Không đưa raw OCR vào RAG nếu chưa clean/review.
- File gốc luôn nằm trong `02_Attachments`.
- OCR output tạm nằm trong `06_Processing/01_OCR_Output`.
- Canonical Markdown nằm trong `01_Dataset`.
- Chỉ canonical Markdown đã review, valid và published mới nên đi vào RAG.
