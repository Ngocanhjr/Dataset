# README - NLCS Obsidian Knowledge Base cho RAG

Tài liệu này dùng để theo dõi cách tổ chức Obsidian Vault `NLCS`, quy trình OCR tài liệu thành Markdown, chuẩn hóa metadata, quản lý phiên bản tài liệu, duyệt nội dung và đưa tài liệu vào hệ thống RAG.

---

## 1. Mục tiêu

Vault `NLCS` được dùng làm nơi quản lý tài liệu tri thức cho hệ thống:

> CTU Student Service: Chatbot hỗ trợ sinh viên hoàn thành thủ tục hành chính dựa trên RAG

Mục tiêu chính:

- Quản lý tài liệu gốc: PDF, DOCX, biểu mẫu, hình ảnh.
- Chuyển tài liệu sang Markdown chuẩn để dễ review và chunking.
- Lưu metadata rõ ràng để backend validate.
- Quản lý version tài liệu để biết bản nào mới nhất, bản nào đã bị thay thế.
- Chỉ đưa tài liệu đã duyệt, còn hiệu lực vào RAG.
- Hỗ trợ citation theo trang, tài liệu, phiên bản và nguồn.

---

## 2. Nguyên tắc tổng quát

```text
Obsidian = nơi quản lý, chỉnh sửa, duyệt Markdown chuẩn
PostgreSQL = nơi quản lý metadata, document version, trạng thái xử lý
Qdrant = nơi lưu vector chunks để truy xuất RAG
```

Không dùng trực tiếp PDF hoặc raw OCR text làm nguồn chính cho RAG.

Nguồn chính để chunk và embedding là:

```text
Canonical Markdown đã được review
```

Quy tắc quan trọng:

```text
File gốc dùng để đối chiếu/audit
File Markdown dùng để xử lý RAG
PostgreSQL dùng để quản lý version/trạng thái
Qdrant chỉ lưu chunks từ phiên bản được publish
```

---

## 3. Cấu trúc thư mục đề xuất

```text
NLCS/
├── 00_Dashboard/
│   ├── Dashboard.md
│   ├── Dataset_List.md
│   ├── Version_Tracking.md
│   └── RAG_Status.md
│
├── 01_Dataset/
│   ├── CTSV/
│   ├── PDT/
│   ├── HocVu/
│   ├── TaiChinh/
│   ├── KyTucXa/
│   └── ThuVien/
│
├── 02_Attachments/
│   ├── PDFs/
│   │   ├── CTSV/
│   │   └── PDT/
│   ├── DOCX/
│   ├── Forms/
│   └── Images/
│
├── 03_Templates/
│   ├── Document Template.md
│   ├── Template_VanBan.md
│   ├── Template_QuyTrinh.md
│   ├── Template_BieuMau.md
│   └── Template_FAQ.md
│
├── 04_RAG/
│   ├── Approved/
│   ├── Published/
│   ├── Chunks/
│   ├── Embeddings_Log/
│   └── Indexing_Log/
│
├── 05_Research/
│
├── 06_Processing/
│   ├── OCR_Output/
│   ├── OCR_Failed/
│   ├── Markdown_Cleaning/
│   ├── Need_Review/
│   ├── Chunk_Preview/
│   └── Logs/
│
└── 99_Archive/
```

---

## 4. Vai trò từng thư mục

| Thư mục | Vai trò |
|---|---|
| `00_Dashboard` | Theo dõi tổng quan dataset, số lượng tài liệu, trạng thái OCR/RAG, version mới nhất |
| `01_Dataset` | Chứa file Markdown chính đã được quản lý theo đơn vị/lĩnh vực |
| `02_Attachments` | Chứa file gốc như PDF, DOCX, biểu mẫu, ảnh scan |
| `03_Templates` | Chứa template YAML và nội dung Markdown mẫu |
| `04_RAG` | Chứa tài liệu đã duyệt hoặc đã publish cho pipeline RAG |
| `05_Research` | Ghi chú nghiên cứu, kiến trúc, thử nghiệm, tài liệu tham khảo |
| `06_Processing` | Chứa file OCR output, file cần làm sạch, log xử lý |
| `99_Archive` | Lưu tài liệu cũ, hết hiệu lực hoặc không còn dùng |

---

## 5. Quy tắc đặt file

### 5.1. File gốc

File gốc luôn đặt trong `02_Attachments`.

Ví dụ:

```text
02_Attachments/PDFs/CTSV/QD1813_QD_ban_hanh_Quy_dinh_cong_tac_hoc_vu_2021.pdf
```

### 5.2. File Markdown chính

File Markdown chính đặt trong `01_Dataset`.

Ví dụ:

```text
01_Dataset/PDT/QD1813_QuyDinhCongTacHocVu_2021.md
```

File này là bản OCR/parse từ tài liệu gốc ra Markdown, gồm heading, bảng, danh sách, điều khoản và page marker để citation.

### 5.3. File OCR trung gian

File OCR output chưa duyệt đặt trong `06_Processing/OCR_Output`.

Ví dụ:

```text
06_Processing/OCR_Output/QD1813_ocr.md
```

### 5.4. Quy tắc đặt tên khi có nhiều version

Mỗi version chính thức của một văn bản nên là **một file Markdown riêng**.

Ví dụ:

```text
01_Dataset/PDT/QD1813_QuyDinhHocVu_2021.md
01_Dataset/PDT/QDxxxx_QuyDinhHocVu_2024.md
```

Không nên ghi đè file cũ, vì cần theo dõi:

- Bản nào đang có hiệu lực.
- Bản nào đã bị thay thế.
- Bản nào từng được đưa vào RAG.
- Chunk/vector nào thuộc version nào.

---

## 6. Khái niệm version cần phân biệt

Có 2 loại version khác nhau:

### 6.1. Version nghiệp vụ của văn bản

Đây là version theo tài liệu thật của trường.

Ví dụ:

```text
Quy định học vụ 2021
Quy định học vụ 2024
```

Loại version này dùng để xác định tài liệu nào mới nhất, tài liệu nào còn hiệu lực.

### 6.2. Version xử lý Markdown/RAG

Đây là version kỹ thuật trong quá trình xử lý.

Ví dụ:

```text
OCR lần 1
Markdown cleaning lần 2
Đã review
Đã index vào Qdrant
Re-index do đổi embedding model
```

Loại version này dùng để debug pipeline.

---

## 7. Quy tắc `document_id` và `version_id`

### 7.1. `document_id`

`document_id` là ID chung cho một nhóm tài liệu cùng chủ đề/nghiệp vụ.

Ví dụ:

```yaml
document_id: "ctu-quy-dinh-hoc-vu"
```

Tất cả phiên bản của quy định học vụ nên dùng chung `document_id`.

### 7.2. `version_id`

`version_id` là ID riêng cho từng phiên bản cụ thể.

Ví dụ:

```yaml
version_id: "ctu-qd1813-2021"
```

Nếu sau này có bản mới:

```yaml
version_id: "ctu-qdxxxx-2024"
```

### 7.3. Ví dụ quan hệ version

Bản cũ:

```yaml
document_id: "ctu-quy-dinh-hoc-vu"
version_id: "ctu-qd1813-2021"
version: "2021"
is_latest: false
validity_status: "replaced"
replaced_by: "ctu-qdxxxx-2024"
rag_status: "deactivated"
```

Bản mới:

```yaml
document_id: "ctu-quy-dinh-hoc-vu"
version_id: "ctu-qdxxxx-2024"
version: "2024"
is_latest: true
validity_status: "valid"
replaces: "ctu-qd1813-2021"
rag_status: "published"
```

---

## 8. Quy trình xử lý tài liệu

```text
1. Thu thập tài liệu gốc
   ↓
2. Lưu PDF/DOCX/Image vào 02_Attachments
   ↓
3. OCR hoặc parse tài liệu thành Markdown
   ↓
4. Lưu bản OCR Markdown vào 06_Processing/OCR_Output
   ↓
5. Làm sạch Markdown và đưa vào 01_Dataset
   ↓
6. Bổ sung YAML frontmatter
   ↓
7. Kiểm tra version: document_id, version_id, replaces, replaced_by
   ↓
8. Review nội dung, bảng, heading, số trang, metadata
   ↓
9. Kiểm tra hiệu lực tài liệu
   ↓
10. Đổi review_status = approved
   ↓
11. Đổi rag_status = published khi được phép ingest
   ↓
12. Backend đọc Markdown, validate metadata
   ↓
13. Chunking từ Markdown
   ↓
14. Embedding
   ↓
15. Qdrant indexing
   ↓
16. Active Knowledge Base
```

---

## 9. Pipeline RAG tổng quát

```text
Raw Document / PDF / DOCX / Image
  ↓
OCR / Parser to Markdown
  ↓
Canonical Markdown trong Obsidian
  ↓
Metadata + Version Validation
  ↓
Admin Review
  ↓
Chunking from Markdown
  ↓
Embedding
  ↓
Qdrant Indexing
  ↓
Active Knowledge Base
```

---

## 10. Template YAML chuẩn

Dùng template này cho các file Markdown trong `01_Dataset`.

```yaml
---
# Định danh tài liệu
document_id: "ctu-quy-dinh-hoc-vu"
version_id: "ctu-qd1813-2021"
title: "Ban hành Quy định công tác học vụ dành cho sinh viên trình độ đại học hệ chính quy"

# Phân loại tài liệu
document_type: "regulation"
domain: "hoc_tap"
department: "Phòng Đào tạo"
audience:
  - "student"

# Thông tin văn bản
code: "1813/QĐ-ĐHCT"
issued_date: "2021-06-18"
effective_date:
expiry_date:
version: "2021"

# Quản lý version nghiệp vụ
is_latest: false
validity_status: "unchecked"
replaces:
replaced_by:
supersession_note:

# Trạng thái xử lý
collection_status: "collected"
ocr_status: "not_started"
review_status: "not_reviewed"
rag_status: "not_indexed"

# Nguồn
source_url: "https://dsa.ctu.edu.vn/noi-quy-quy-che/quy-che-hoc-vu.html"
source_file: "[[QD1813_QD_ban_hanh_Quy_dinh_cong_tac_hoc_vu_2021.pdf]]"
file_type: "pdf"
accessed_date: "2026-05-23"

# RAG metadata
language: "vi"
confidentiality: "public"
priority: "high"
citation_type: "page"
chunking_strategy: "heading_based"

# Kiểm soát xử lý kỹ thuật
created_at: "2026-05-23"
updated_at: "2026-05-23"
checksum:
parser:
parser_version:
ocr_engine:
ocr_confidence:
embedding_model:
last_indexed_at:
notes:

tags:
  - ctu
  - hoc-vu
  - quy-dinh
  - sinh-vien
---
```

---

## 11. Enum metadata cần thống nhất

### 11.1. `document_type`

```text
procedure       # thủ tục
regulation      # quy định/quy chế
decision        # quyết định
announcement    # thông báo
form            # biểu mẫu
faq             # câu hỏi thường gặp
guide           # hướng dẫn
policy          # chính sách
```

### 11.2. `domain`

```text
hoc_tap
hoc_phi
cong_tac_sinh_vien
ky_tuc_xa
bieu_mau
tot_nghiep
bao_luu
hoc_bong
thu_vien
```

### 11.3. `collection_status`

```text
collected
missing_source
duplicate
archived
```

### 11.4. `ocr_status`

```text
not_started
processing
done
failed
need_review
```

### 11.5. `review_status`

```text
not_reviewed
reviewing
approved
rejected
need_fix
```

### 11.6. `rag_status`

```text
not_indexed
chunked
embedded
indexed
published
deactivated
failed
```

### 11.7. `validity_status`

```text
unchecked    # chưa kiểm tra hiệu lực
valid        # còn hiệu lực
expired      # hết hiệu lực theo ngày
replaced     # đã bị văn bản khác thay thế
unknown      # không xác định được
```

### 11.8. `confidentiality`

```text
public
internal
restricted
```

### 11.9. `is_latest`

```text
true         # là bản mới nhất đã xác định
false        # không phải bản mới nhất hoặc chưa xác nhận
```

---

## 12. Template nội dung Markdown

Sau YAML frontmatter, nội dung nên có cấu trúc sau:

```markdown
# Tóm tắt

# Thông tin văn bản

# Phạm vi áp dụng

# Đối tượng áp dụng

# Nội dung chính

# Quy định quan trọng

# Điều kiện / yêu cầu

# Quy trình / thủ tục liên quan

# Hồ sơ / giấy tờ liên quan

# Biểu mẫu liên quan

# Thời hạn / mốc thời gian quan trọng

# Đơn vị phụ trách

# Quan hệ phiên bản

# Câu hỏi có thể trả lời

# Nội dung OCR / Markdown chuẩn hóa

<!-- page: 1 -->

# Ghi chú kiểm tra
```

---

## 13. Quy tắc đánh dấu trang cho citation

Để chatbot trích dẫn chính xác, nên giữ marker theo trang trong Markdown.

Ví dụ:

```markdown
<!-- page: 1 -->

# Quy định công tác học vụ

## Chương I. Những quy định chung

Nội dung trang 1...

<!-- page: 2 -->

## Điều 3. Chương trình đào tạo

Nội dung trang 2...
```

Khi chunking, backend sẽ suy ra:

```json
{
  "page_start": 1,
  "page_end": 2,
  "heading_path": "Quy định công tác học vụ > Chương I > Điều 3"
}
```

---

## 14. Quy tắc quản lý phiên bản tài liệu

### 14.1. Không overwrite tài liệu cũ

Không nên sửa trực tiếp một file cũ thành nội dung văn bản mới.

Sai:

```text
QD1813_QuyDinhHocVu_2021.md
```

rồi đổi nội dung thành quy định năm 2024.

Đúng:

```text
QD1813_QuyDinhHocVu_2021.md
QDxxxx_QuyDinhHocVu_2024.md
```

### 14.2. Một version chính thức = một file Markdown

Mỗi văn bản chính thức nên có một `version_id` riêng.

```text
document_id = nhóm tài liệu
version_id = bản cụ thể
```

### 14.3. Khi có tài liệu mới thay thế tài liệu cũ

Thực hiện:

```text
1. Tạo file Markdown mới trong 01_Dataset
2. Giữ document_id giống tài liệu cũ
3. Tạo version_id mới
4. Cập nhật file cũ:
   - is_latest: false
   - validity_status: replaced
   - replaced_by: version_id mới
   - rag_status: deactivated
5. Cập nhật file mới:
   - is_latest: true
   - validity_status: valid
   - replaces: version_id cũ
   - rag_status: published nếu đã được duyệt
6. Backend deactivate vector cũ trong Qdrant
7. Backend index vector mới
```

### 14.4. Khi chưa chắc tài liệu mới nhất

Nếu chưa kiểm tra hiệu lực, dùng:

```yaml
is_latest: false
validity_status: "unchecked"
rag_status: "not_indexed"
```

Không publish vào RAG cho đến khi xác minh.

---

## 15. Điều kiện để được đưa vào RAG

Một file chỉ được ingest vào RAG khi thỏa điều kiện:

```text
review_status = approved
ocr_status = done
rag_status = published
validity_status = valid
confidentiality = public
```

Nếu hệ thống yêu cầu chỉ dùng văn bản mới nhất, thêm:

```text
is_latest = true
```

Rule backend khuyến nghị:

```text
IF review_status = approved
AND ocr_status = done
AND rag_status = published
AND validity_status = valid
AND confidentiality = public
AND effective_date <= today
AND (expiry_date is empty OR expiry_date >= today)
THEN ingest
ELSE skip
```

Rule nghiêm ngặt hơn:

```text
IF review_status = approved
AND ocr_status = done
AND rag_status = published
AND validity_status = valid
AND confidentiality = public
AND is_latest = true
AND effective_date <= today
AND (expiry_date is empty OR expiry_date >= today)
THEN ingest
ELSE skip
```

---

## 16. Checklist trước khi publish tài liệu

Trước khi đổi `rag_status` thành `published`, kiểm tra:

- [ ] File PDF/DOCX gốc đã nằm trong `02_Attachments`.
- [ ] File Markdown chính đã nằm trong `01_Dataset`.
- [ ] YAML frontmatter đầy đủ.
- [ ] `document_id` đại diện đúng cho nhóm tài liệu.
- [ ] `version_id` là duy nhất cho phiên bản này.
- [ ] `title` đúng với tài liệu.
- [ ] `document_type` đúng enum.
- [ ] `domain` đúng enum.
- [ ] `department` không rỗng.
- [ ] `source_url` hoặc `source_file` có tồn tại.
- [ ] `issued_date`, `effective_date`, `expiry_date` đã kiểm tra nếu có.
- [ ] Đã xác định `is_latest`.
- [ ] Đã cập nhật `replaces` hoặc `replaced_by` nếu có.
- [ ] OCR đã hoàn tất.
- [ ] Không mất dấu tiếng Việt.
- [ ] Bảng biểu không bị vỡ.
- [ ] Heading rõ ràng.
- [ ] Có marker `<!-- page: n -->` nếu cần citation theo trang.
- [ ] Đã kiểm tra hiệu lực văn bản.
- [ ] Không có thông tin nhạy cảm ngoài phạm vi công khai.
- [ ] `review_status: "approved"`.
- [ ] `rag_status: "published"`.
- [ ] `validity_status: "valid"`.

---

## 17. Trạng thái tài liệu mẫu

### 17.1. Mới thu thập

```yaml
collection_status: "collected"
ocr_status: "not_started"
review_status: "not_reviewed"
rag_status: "not_indexed"
validity_status: "unchecked"
is_latest: false
```

### 17.2. Đã OCR, đang cần kiểm tra

```yaml
collection_status: "collected"
ocr_status: "done"
review_status: "reviewing"
rag_status: "not_indexed"
validity_status: "unchecked"
is_latest: false
```

### 17.3. Đã duyệt nhưng chưa đưa vào RAG

```yaml
collection_status: "collected"
ocr_status: "done"
review_status: "approved"
rag_status: "not_indexed"
validity_status: "valid"
is_latest: true
```

### 17.4. Đã publish vào RAG

```yaml
collection_status: "collected"
ocr_status: "done"
review_status: "approved"
rag_status: "published"
validity_status: "valid"
is_latest: true
```

### 17.5. Tài liệu hết hiệu lực

```yaml
review_status: "approved"
rag_status: "deactivated"
validity_status: "expired"
is_latest: false
```

### 17.6. Tài liệu đã bị thay thế

```yaml
review_status: "approved"
rag_status: "deactivated"
validity_status: "replaced"
is_latest: false
replaced_by: "ctu-qdxxxx-2024"
```

---

## 18. Cách dùng `04_RAG`

Có 2 cách vận hành.

### Cách 1: Backend đọc thẳng từ `01_Dataset`

Backend chỉ ingest file có đủ trạng thái hợp lệ:

```yaml
review_status: "approved"
ocr_status: "done"
rag_status: "published"
validity_status: "valid"
```

Ưu điểm:

- Ít duplicate file.
- Dễ đồng bộ.
- Phù hợp khi backend đã có validator tốt.

### Cách 2: Copy file đã duyệt sang `04_RAG/Published`

Chỉ tài liệu đã được phép đưa vào RAG mới nằm trong:

```text
04_RAG/Published/
```

Ưu điểm:

- Dễ kiểm soát cho MVP.
- Dễ trình bày trong đồ án.
- Dễ debug khi ingest.

Khuyến nghị hiện tại: dùng Cách 2 cho giai đoạn đầu.

---

## 19. Ví dụ file hoàn chỉnh

```markdown
---
document_id: "ctu-quy-dinh-hoc-vu"
version_id: "ctu-qd1813-2021"
title: "Ban hành Quy định công tác học vụ dành cho sinh viên trình độ đại học hệ chính quy"
document_type: "regulation"
domain: "hoc_tap"
department: "Phòng Đào tạo"
audience:
  - "student"
code: "1813/QĐ-ĐHCT"
issued_date: "2021-06-18"
effective_date:
expiry_date:
version: "2021"
is_latest: false
validity_status: "unchecked"
replaces:
replaced_by:
supersession_note:
collection_status: "collected"
ocr_status: "not_started"
review_status: "not_reviewed"
rag_status: "not_indexed"
source_url: "https://dsa.ctu.edu.vn/noi-quy-quy-che/quy-che-hoc-vu.html"
source_file: "[[QD1813_QD_ban_hanh_Quy_dinh_cong_tac_hoc_vu_2021.pdf]]"
file_type: "pdf"
accessed_date: "2026-05-23"
language: "vi"
confidentiality: "public"
priority: "high"
citation_type: "page"
chunking_strategy: "heading_based"
tags:
  - ctu
  - hoc-vu
  - quy-dinh
  - sinh-vien
---

# Tóm tắt

Chưa xử lý.

# Thông tin văn bản

- Số hiệu: 1813/QĐ-ĐHCT
- Ngày ban hành: 2021-06-18
- Đơn vị phụ trách: Phòng Đào tạo
- Lĩnh vực: Học tập
- Đối tượng: Sinh viên trình độ đại học hệ chính quy

# Quan hệ phiên bản

- Phiên bản hiện tại: 2021
- Là bản mới nhất: Chưa xác định
- Thay thế văn bản: Chưa xác định
- Bị thay thế bởi: Chưa xác định

# Phạm vi áp dụng

Chưa OCR.

# Đối tượng áp dụng

Chưa OCR.

# Nội dung chính

Chưa OCR.

# Quy định quan trọng

Chưa OCR.

# Thủ tục liên quan

Chưa OCR.

# Biểu mẫu liên quan

Chưa OCR.

# Câu hỏi có thể trả lời

- Sinh viên bị cảnh báo học vụ trong trường hợp nào?
- Điều kiện xét tốt nghiệp là gì?
- Quy định về học phần, tín chỉ, điểm số như thế nào?
- Sinh viên được tạm dừng học trong trường hợp nào?

# Nội dung OCR / Markdown chuẩn hóa

<!-- page: 1 -->

Chưa OCR.

# Ghi chú kiểm tra

- Cần kiểm tra hiệu lực văn bản.
- Cần xác định có văn bản mới thay thế QĐ1813 hay không.
```

---

## 20. Gợi ý Dataview cho Dashboard

Nếu dùng plugin Dataview trong Obsidian, có thể tạo bảng theo dõi.

### 20.1. Danh sách tài liệu chưa OCR

```dataview
TABLE document_id, version_id, title, department, ocr_status, review_status, rag_status
FROM "01_Dataset"
WHERE ocr_status = "not_started"
SORT updated_at DESC
```

### 20.2. Danh sách tài liệu cần review

```dataview
TABLE document_id, version_id, title, department, ocr_status, review_status, validity_status
FROM "01_Dataset"
WHERE review_status = "reviewing" OR review_status = "need_fix"
SORT updated_at DESC
```

### 20.3. Danh sách tài liệu đã sẵn sàng đưa vào RAG

```dataview
TABLE document_id, version_id, title, department, domain, rag_status, validity_status, is_latest
FROM "01_Dataset"
WHERE review_status = "approved"
AND ocr_status = "done"
AND validity_status = "valid"
SORT updated_at DESC
```

### 20.4. Danh sách tài liệu đã publish

```dataview
TABLE document_id, version_id, title, department, domain, rag_status, is_latest, source_file
FROM "01_Dataset"
WHERE rag_status = "published"
SORT updated_at DESC
```

### 20.5. Danh sách tài liệu chưa kiểm tra hiệu lực

```dataview
TABLE document_id, version_id, title, code, issued_date, validity_status, source_url
FROM "01_Dataset"
WHERE validity_status = "unchecked" OR validity_status = "unknown"
SORT issued_date DESC
```

### 20.6. Danh sách tài liệu đã bị thay thế

```dataview
TABLE document_id, version_id, title, version, replaced_by, rag_status
FROM "01_Dataset"
WHERE validity_status = "replaced"
SORT updated_at DESC
```

### 20.7. Danh sách version theo cùng document_id

```dataview
TABLE version_id, title, version, code, issued_date, validity_status, is_latest, rag_status
FROM "01_Dataset"
WHERE document_id = "ctu-quy-dinh-hoc-vu"
SORT issued_date DESC
```

---

## 21. Quy tắc chunking từ Markdown

Chunking nên dựa trên heading, không cắt ngẫu nhiên theo ký tự.

Ưu tiên chunk theo:

```text
# Tài liệu
## Chương
### Điều
#### Khoản
```

Mỗi chunk nên có metadata:

```json
{
  "document_id": "ctu-quy-dinh-hoc-vu",
  "version_id": "ctu-qd1813-2021",
  "title": "Ban hành Quy định công tác học vụ...",
  "heading_path": "Chương II > Điều 5",
  "page_start": 3,
  "page_end": 4,
  "document_type": "regulation",
  "department": "Phòng Đào tạo",
  "domain": "hoc_tap",
  "version": "2021",
  "is_latest": false,
  "validity_status": "replaced",
  "source_file": "QD1813_QD_ban_hanh_Quy_dinh_cong_tac_hoc_vu_2021.pdf"
}
```

---

## 22. Qdrant payload cần có

Khi index vào Qdrant, mỗi vector point nên có payload:

```json
{
  "chunk_id": "ctu-qd1813-2021_chunk_001",
  "document_id": "ctu-quy-dinh-hoc-vu",
  "version_id": "ctu-qd1813-2021",
  "title": "Ban hành Quy định công tác học vụ dành cho sinh viên trình độ đại học hệ chính quy",
  "document_type": "regulation",
  "domain": "hoc_tap",
  "department": "Phòng Đào tạo",
  "audience": ["student"],
  "code": "1813/QĐ-ĐHCT",
  "version": "2021",
  "is_latest": false,
  "replaces": null,
  "replaced_by": null,
  "effective_date": null,
  "expiry_date": null,
  "validity_status": "valid",
  "rag_status": "published",
  "confidentiality": "public",
  "page_start": 1,
  "page_end": 2,
  "source_url": "https://dsa.ctu.edu.vn/noi-quy-quy-che/quy-che-hoc-vu.html",
  "source_file": "QD1813_QD_ban_hanh_Quy_dinh_cong_tac_hoc_vu_2021.pdf"
}
```

Qdrant nên có payload index cho các field hay filter:

```text
document_id
version_id
document_type
domain
department
audience
is_latest
validity_status
rag_status
confidentiality
effective_date
expiry_date
```

---

## 23. Quy tắc deactivate vector cũ trong Qdrant

Khi một tài liệu bị thay thế, không cần xóa ngay vector cũ. Nên cập nhật payload:

```json
{
  "rag_status": "deactivated",
  "validity_status": "replaced",
  "is_latest": false,
  "replaced_by": "ctu-qdxxxx-2024"
}
```

Retriever mặc định chỉ lấy:

```text
rag_status = published
validity_status = valid
confidentiality = public
```

Nếu cần tra cứu lịch sử, admin có thể bật chế độ tìm cả tài liệu cũ.

---

## 24. Công thức vận hành ngắn gọn

```text
PDF gốc giữ trong 02_Attachments
Markdown chuẩn giữ trong 01_Dataset
Mỗi version chính thức = một file Markdown riêng
document_id dùng chung cho cùng nhóm tài liệu
version_id riêng cho từng phiên bản cụ thể
File lỗi/chưa sạch giữ trong 06_Processing
File đã publish cho RAG nằm trong 04_RAG/Published hoặc có rag_status = published
Backend chỉ ingest Markdown đã approved/published/valid
Qdrant chỉ lưu chunks từ Markdown đã duyệt và còn hiệu lực
```

---

## 25. Việc cần làm tiếp theo

- [ ] Chuẩn hóa lại template trong `03_Templates` theo YAML mới.
- [ ] Bổ sung `document_id` và `version_id` cho tất cả file trong `01_Dataset`.
- [ ] Bổ sung `is_latest`, `replaces`, `replaced_by`, `validity_status` cho các tài liệu có nhiều phiên bản.
- [ ] Di chuyển file Markdown chính vào `01_Dataset/<Đơn vị hoặc Lĩnh vực>/`.
- [ ] Giữ PDF gốc trong `02_Attachments/PDFs/`.
- [ ] Bổ sung dashboard Dataview để theo dõi OCR/RAG/version.
- [ ] Chuẩn hóa enum trạng thái.
- [ ] Tạo script backend đọc YAML frontmatter.
- [ ] Tạo validator metadata và version.
- [ ] Tạo chunker đọc Markdown theo heading và page marker.
- [ ] Tạo ingestion job để embedding và upsert Qdrant.
- [ ] Tạo job deactivate vector cũ khi tài liệu bị thay thế.
- [ ] Tạo filter retrieval chỉ lấy tài liệu `published`, `valid`, `public`.

---

## 26. Kết luận

Vault Obsidian `NLCS` nên được xem là hệ thống quản lý tri thức trước khi đưa vào RAG.

Luồng đúng:

```text
Obsidian Markdown đã duyệt
  ↓
Backend metadata + version validation
  ↓
Chunking
  ↓
Embedding
  ↓
Qdrant
  ↓
Chatbot trả lời có citation
```

Không đưa tài liệu chưa OCR, chưa review, chưa kiểm tra hiệu lực hoặc đã bị thay thế vào Active Knowledge Base.

Quy tắc cuối cùng:

```text
Obsidian lưu tất cả version để quản lý.
Backend chỉ index version còn hiệu lực.
Qdrant lưu version_id trong từng chunk.
Chatbot chỉ trả lời từ tài liệu valid/published.
```
