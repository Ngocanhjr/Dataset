---
title: "Template metadata field guide"
document_type: "metadata_guide"
domain: "template_governance"
department: "NLCS"
status: "active"
created_at: "2026-05-27"
updated_at: "2026-05-27"
tags:
  - ctu
  - metadata
  - template
  - enum
---

# Template metadata field guide

File này mô tả mục đích các trường metadata trong `03_Templates` và quy ước enum dùng chung. Khi tạo hoặc sửa template, ưu tiên dùng đúng tên field và đúng enum trong file này.

---

## 1. Vai trò từng template

| Template | Vai trò chính | Không dùng để |
|---|---|---|
| `Template_Attachment_Intake.md` | Tracking file gốc trước/sau OCR | Làm nguồn RAG chính |
| `Template_Asset_Intake.md` | Tracking asset/link/file/video mới phát hiện | Mô tả đầy đủ nội dung biểu mẫu cho chatbot |
| `Template_asset_rag.md` | Metadata cho asset/link/file/video đã chuẩn hóa | Thay thế nội dung nghiệp vụ của `Template_BieuMau.md` |
| `Template_VanBan.md` | Canonical Markdown cho văn bản/quy định/quyết định | Tracking OCR tạm |
| `Template_QuyTrinh.md` | Canonical Markdown cho thủ tục/quy trình | Lưu file tải vật lý |
| `Template_BieuMau.md` | Canonical Markdown mô tả cách dùng biểu mẫu | Lưu metadata file tải chi tiết thay cho asset |
| `Template_FAQ.md` | Câu hỏi/câu trả lời chuẩn có căn cứ nguồn | Thay thế văn bản nguồn |

Nguyên tắc tách vai trò:

- `Attachment_Intake` theo dõi file gốc.
- `Asset_Intake` theo dõi asset/link mới phát hiện.
- `asset_rag` mô tả link tải, file tải, link YouTube/video hoặc tài nguyên ngoài đã chuẩn hóa.
- `BieuMau` mô tả nghiệp vụ của biểu mẫu: dùng khi nào, điền ra sao, liên quan thủ tục nào.
- Nếu asset là file biểu mẫu, dùng `Template_asset_rag.md` cho file/link tải và dùng `Template_BieuMau.md` cho hướng dẫn nghiệp vụ; nối hai bên bằng `related_asset_ids`.
- `VanBan`, `QuyTrinh`, `BieuMau`, `FAQ` là nhóm canonical phục vụ RAG sau review.

---

## 2. Enum chuẩn

### `collection_status`

```text
link_collected = mới ghi nhận link, chưa tải file
collected      = đã thu thập nguồn/file
downloaded     = đã tải file về vault
missing        = chưa có file/link cần thiết
failed         = thu thập thất bại
```

Quy ước:

- `Template_Asset_Intake.md` có thể bắt đầu bằng `link_collected`.
- Các canonical template thường bắt đầu bằng `collected`.

---

### `ocr_status`

```text
not_started  = chưa OCR/parser
processing   = đang OCR/parser
done         = OCR/parser xong
failed       = OCR/parser lỗi
need_review  = OCR/parser xong nhưng cần kiểm tra kỹ
not_required = không cần OCR, ví dụ FAQ viết thủ công
```

Quy ước:

- File canonical sinh từ PDF/DOCX nên dùng `not_started`, `processing`, `done`, `failed`, `need_review`.
- FAQ viết thủ công có thể không dùng `ocr_status`; nếu cần dùng thì đặt `not_required`.

---

### `processing_stage`

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

Quy ước:

- Không dùng `cleaning`; dùng `markdown_cleaning`.
- Không dùng `canonical_done`; dùng `dataset_ready`.

---

### `review_status`

```text
not_reviewed = chưa review
reviewing    = đang review
need_fix     = cần sửa
approved     = đã duyệt
rejected     = loại bỏ
```

Quy ước:

- Không dùng `reviewed`; dùng `approved`.
- Không dùng `needs_fix`; dùng `need_fix`.

---

### `validity_status`

```text
unchecked = chưa kiểm tra hiệu lực
valid     = còn hiệu lực
expired   = hết hiệu lực
replaced  = đã bị thay thế
unknown   = chưa xác định được
```

Quy ước:

- Template mới nên mặc định `unchecked`, trừ khi file được tạo sau bước xác minh.
- Không publish RAG nếu `validity_status` không phải `valid`.

---

### `rag_status`

```text
not_indexed = chưa đưa vào RAG
chunked     = đã chia chunk
embedded    = đã tạo embedding
indexed     = đã index vào vector DB
published   = đang được chatbot sử dụng
deactivated = đã ngưng dùng
failed      = lỗi trong pipeline RAG
```

Quy ước:

- Không dùng `ready_to_index`; dùng `not_indexed` cho file chưa index.
- Không cần field `rag_include`; dùng `rag_status` để quyết định pipeline.

---

### `document_type`

```text
regulation = văn bản/quy định/quyết định
procedure  = thủ tục/quy trình
form       = biểu mẫu
faq        = câu hỏi/câu trả lời chuẩn
```

---

### `asset_type`

```text
downloadable_file = file có thể tải về
link              = link ngoài
video             = video/YouTube
appendix          = phụ lục
reference         = tài liệu tham chiếu
```

---

### `relation_type`

```text
required_form     = biểu mẫu bắt buộc
optional_form     = biểu mẫu tùy trường hợp
downloadable_file = file tải về liên quan
video             = video/YouTube liên quan
source_document   = văn bản nguồn/căn cứ
related_document  = tài liệu liên quan
appendix          = phụ lục
```

---

### `file_type`

```text
pdf
docx
md
html
image
xlsx
csv
url
youtube
```

---

### `confidentiality`

```text
public     = công khai, có thể dùng cho chatbot sinh viên
internal   = nội bộ, không dùng cho chatbot public nếu chưa có quyền
restricted = hạn chế, cần kiểm soát quyền truy cập
```

---

### `priority`

```text
low
medium
high
```

---

### `citation_type`

```text
page    = citation theo trang
section = citation theo mục/heading
none    = không citation trực tiếp
```

---

### `chunking_strategy`

```text
heading_based = chunk theo heading
qa_based      = chunk theo cặp hỏi/đáp
asset_based   = chunk theo metadata asset
manual        = chia chunk thủ công
```

---

### `source_type`

```text
manual                = viết thủ công có review
derived_from_document = rút ra từ tài liệu canonical
imported              = nhập từ nguồn ngoài
```

---

## 3. Nhóm field định danh

### `document_id`

ID chung của một tài liệu hoặc nhóm nghiệp vụ. Dùng để gom nhiều version của cùng một tài liệu.

Ví dụ:

```yaml
document_id: "ctu-quy-dinh-hoc-vu"
```

---

### `version_id`

ID của một version cụ thể. Dùng để chunk, embedding, index và truy vết citation.

Ví dụ:

```yaml
version_id: "ctu-quy-dinh-hoc-vu-2021-v1"
```

---

### `asset_id`

ID của asset/file tải/link/biểu mẫu. Dùng trong `Template_Asset_Intake.md` và `Template_asset_rag.md`.

Ví dụ:

```yaml
asset_id: "ctu-asset-huong-dan-cap-bang-diem"
```

---

### `title`

Tên hiển thị của tài liệu, thủ tục, biểu mẫu, FAQ hoặc asset. Field này nên có ở mọi template.

---

## 4. Nhóm phân loại nghiệp vụ

### `domain`

Lĩnh vực nghiệp vụ như học vụ, học phí, học bổng, CTSV, ký túc xá.

### `department`

Đơn vị phụ trách hoặc ban hành, ví dụ Phòng Đào tạo, Phòng Công tác Sinh viên.

### `audience`

Đối tượng sử dụng. Với đề tài hiện tại thường là:

```yaml
audience:
  - "student"
```

### `document_type`

Loại tài liệu canonical. Dùng enum ở mục `document_type`.

### `asset_type`

Loại asset/link/file/video. Dùng enum ở mục `asset_type`.

---

## 5. Nhóm version và hiệu lực

### `code`

Số hiệu văn bản/quyết định hoặc mã tài liệu nguồn. Với thủ tục, `code` không thay thế `procedure_code`.

### `procedure_code`

Mã thủ tục/quy trình nếu có. Dùng trong `Template_QuyTrinh.md`.

### `form_code`

Mã biểu mẫu nếu có. Dùng trong `Template_BieuMau.md`.

### `issued_date`

Ngày ban hành tài liệu.

### `effective_date`

Ngày bắt đầu hiệu lực.

### `expiry_date`

Ngày hết hiệu lực nếu có.

### `version`

Nhãn version hiển thị, ví dụ `2021`, `v1.0`, `2024`.

### `is_latest`

Đánh dấu đây có phải version mới nhất không.

### `validity_status`

Trạng thái hiệu lực. Dùng enum ở mục `validity_status`.

### `replaces`

Danh sách version cũ bị tài liệu này thay thế.

### `replaced_by`

Danh sách version mới thay thế tài liệu này.

---

## 6. Nhóm source và file

### `source_file`

Tên file gốc hoặc wikilink đến file gốc.

### `source_path`

Đường dẫn tương đối đến file gốc trong vault. Dùng chủ yếu ở `Template_Attachment_Intake.md`.

### `source_url`

URL nguồn chính thức.

### `accessed_date`

Ngày truy cập/tải nguồn.

### `file_name`

Tên file tải hoặc asset.

### `file_path`

Đường dẫn local đến file tải hoặc asset.

### `file_type`

Loại file. Dùng enum ở mục `file_type`.

### `download_url`

Link tải, link xem hoặc URL tài nguyên ngoài nếu có.

### `is_downloadable`

Cho biết chatbot/admin có thể cung cấp file này cho sinh viên tải hay không.

### `checksum`

Mã kiểm tra nội dung file. Dùng để phát hiện duplicate hoặc file bị thay đổi.

---

## 7. Nhóm quan hệ

### `related_document_ids`

Danh sách `document_id` liên quan.

### `related_version_ids`

Danh sách `version_id` liên quan.

### `related_procedure_ids`

Danh sách mã thủ tục hoặc `document_id` của thủ tục liên quan.

### `related_asset_ids`

Danh sách `asset_id` liên quan. Dùng khi canonical form cần trỏ tới file tải.

### `related_form_ids`

Danh sách `document_id` của biểu mẫu canonical liên quan. Dùng khi asset cần trỏ ngược về `Template_BieuMau.md`.

### `source_document_id`

Tài liệu gốc/canonical nơi phát hiện hoặc căn cứ cho asset.

### `source_version_id`

Version gốc/canonical nơi phát hiện hoặc căn cứ cho asset.

### `relation_type`

Kiểu quan hệ giữa asset và tài liệu/thủ tục. Dùng enum ở mục `relation_type`.

### `required`

Asset hoặc biểu mẫu có bắt buộc không.

### `required_when`

Điều kiện bắt buộc, ví dụ chỉ bắt buộc khi sinh viên xin bản giấy.

### `required_form_ids`

Danh sách `asset_id` hoặc form id bắt buộc cho một thủ tục.

---

## 8. Nhóm trạng thái xử lý

### `collection_status`

Trạng thái thu thập nguồn/file. Dùng enum ở mục `collection_status`.

### `ocr_status`

Trạng thái OCR/parser. Dùng enum ở mục `ocr_status`.

### `processing_stage`

Giai đoạn pipeline trước khi thành canonical Markdown. Dùng enum ở mục `processing_stage`.

### `review_status`

Trạng thái review nội dung. Dùng enum ở mục `review_status`.

### `rag_status`

Trạng thái trong pipeline RAG. Dùng enum ở mục `rag_status`.

### `next_action`

Việc tiếp theo cần làm.

### `assignee`

Người phụ trách.

### `due_date`

Deadline xử lý theo định dạng `YYYY-MM-DD`.

### `blocker`

Vướng mắc đang chặn xử lý.

---

## 9. Nhóm RAG

### `language`

Ngôn ngữ nội dung. Với đề tài hiện tại thường là:

```yaml
language: "vi"
```

### `confidentiality`

Mức độ truy cập. Dùng enum ở mục `confidentiality`.

### `priority`

Độ ưu tiên xử lý/index. Dùng enum ở mục `priority`.

### `citation_type`

Cách citation. Dùng enum ở mục `citation_type`.

### `chunking_strategy`

Chiến lược chunking. Dùng enum ở mục `chunking_strategy`.

### `retrieval_keywords`

Không còn dùng trong frontmatter chuẩn. Nếu cần, ghi trong phần nội dung như mục "Từ khóa truy xuất" để tránh YAML quá dài.

---

## 10. Nhóm kiểm soát kỹ thuật

### `created_at`

Ngày tạo note.

### `updated_at`

Ngày cập nhật gần nhất.

### `parser`

Parser dùng để trích xuất nội dung, ví dụ `pymupdf`, `pdfplumber`, `python-docx`.

### `ocr_engine`

OCR engine dùng cho file scan/image, ví dụ `paddleocr`, `tesseract`.

### `notes`

Ghi chú xử lý ngắn.

### `tags`

Tag Obsidian để lọc và tìm kiếm.

---

## 11. Điều kiện publish khuyến nghị

Một file canonical chỉ nên vào RAG khi đạt:

```yaml
ocr_status: "done"
review_status: "approved"
validity_status: "valid"
rag_status: "published"
confidentiality: "public"
```

Với FAQ viết thủ công không cần OCR, có thể thay điều kiện OCR bằng quy tắc riêng:

```yaml
source_type: "manual"
review_status: "approved"
validity_status: "valid"
rag_status: "published"
confidentiality: "public"
```

Không publish nếu:

```text
review_status != approved
validity_status != valid
rag_status = deactivated
confidentiality = restricted
```
