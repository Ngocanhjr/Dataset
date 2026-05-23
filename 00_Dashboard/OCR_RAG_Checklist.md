---
title: "Dashboard - OCR và trạng thái xử lý tài liệu"
document_type: "dashboard"
domain: "dataset_tracking"
department: "NLCS"
audience:
  - "team_member"
  - "admin"
  - "developer"
version: "1.0"
status: "active"
created_at: "2026-05-24"
updated_at: "2026-05-24"
tags:
  - dashboard
  - ocr
  - rag
  - dataset
  - checklist
  - nlcs
---

# Dashboard - OCR và trạng thái xử lý tài liệu

File này dùng để team theo dõi:

- Tài liệu nào đã OCR.
- Tài liệu nào chưa OCR.
- Tài liệu nào cần review.
- Tài liệu nào đã approved nhưng chưa publish vào RAG.
- Tài liệu nào chưa kiểm tra hiệu lực.
- Tài liệu nào bị thay thế nhưng chưa deactivate.
- Ai đang phụ trách phần nào.

> Yêu cầu: bật plugin **Dataview** trong Obsidian.

---

## 0. Metadata cần có trong mỗi file `01_Dataset`

Mỗi file Markdown chính trong `01_Dataset` nên có các field sau:

```yaml
---
document_id: ""
version_id: ""
title: ""

department: ""
domain: ""
document_type: ""

ocr_status: "not_started"
review_status: "not_reviewed"
validity_status: "unchecked"
rag_status: "not_indexed"
confidentiality: "public"

is_latest: false
source_file: ""
source_url: ""

assignee:
next_action:
due_date:
blocker:
updated_at:
---
```

Các field bắt buộc để dashboard hoạt động tốt:

```text
document_id
version_id
title
ocr_status
review_status
validity_status
rag_status
updated_at
```

Các field nên thêm để team dễ phối hợp:

```text
assignee
next_action
due_date
blocker
```

---

# 1. Tổng quan trạng thái tài liệu

## 1.1. Tổng số tài liệu theo OCR status

```dataview
TABLE WITHOUT ID ocr_status AS "OCR Status", length(rows) AS "Số lượng"
FROM "01_Dataset"
GROUP BY ocr_status
SORT ocr_status ASC
```

## 1.2. Tổng số tài liệu theo Review status

```dataview
TABLE WITHOUT ID review_status AS "Review Status", length(rows) AS "Số lượng"
FROM "01_Dataset"
GROUP BY review_status
SORT review_status ASC
```

## 1.3. Tổng số tài liệu theo RAG status

```dataview
TABLE WITHOUT ID rag_status AS "RAG Status", length(rows) AS "Số lượng"
FROM "01_Dataset"
GROUP BY rag_status
SORT rag_status ASC
```

## 1.4. Tổng số tài liệu theo hiệu lực

```dataview
TABLE WITHOUT ID validity_status AS "Validity Status", length(rows) AS "Số lượng"
FROM "01_Dataset"
GROUP BY validity_status
SORT validity_status ASC
```

---

# 2. Workboard cho team

## 2.1. Tài liệu cần làm ngay

Các tài liệu trong bảng này là những file còn thiếu bước xử lý quan trọng.

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  department AS "Đơn vị",
  ocr_status AS "OCR",
  review_status AS "Review",
  validity_status AS "Hiệu lực",
  rag_status AS "RAG",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm",
  due_date AS "Deadline",
  blocker AS "Vướng mắc"
FROM "01_Dataset"
WHERE
  ocr_status != "done"
  OR review_status != "approved"
  OR validity_status = "unchecked"
  OR validity_status = "unknown"
  OR rag_status = "not_indexed"
  OR rag_status = "failed"
SORT due_date ASC, updated_at DESC
```

---

## 2.2. Tài liệu chưa OCR

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  department AS "Đơn vị",
  source_file AS "File gốc",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm",
  due_date AS "Deadline"
FROM "01_Dataset"
WHERE ocr_status = "not_started"
SORT due_date ASC, updated_at DESC
```

Gợi ý `next_action`:

```text
OCR PDF sang Markdown và lưu bản tạm vào 06_Processing/OCR_Output.
```

---

## 2.3. Tài liệu đang OCR hoặc OCR lỗi

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  department AS "Đơn vị",
  ocr_status AS "OCR Status",
  review_status AS "Review",
  assignee AS "Người phụ trách",
  blocker AS "Vướng mắc",
  updated_at AS "Cập nhật"
FROM "01_Dataset"
WHERE ocr_status = "processing"
   OR ocr_status = "failed"
   OR ocr_status = "need_review"
SORT ocr_status ASC, updated_at DESC
```

Gợi ý xử lý:

```text
failed       → kiểm tra lại file gốc hoặc đổi OCR engine
need_review  → kiểm tra lỗi mất dấu, lỗi bảng, thiếu trang
processing   → cập nhật khi OCR xong
```

---

## 2.4. Tài liệu đã OCR nhưng chưa review

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  department AS "Đơn vị",
  ocr_status AS "OCR",
  review_status AS "Review",
  validity_status AS "Hiệu lực",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm",
  updated_at AS "Cập nhật"
FROM "01_Dataset"
WHERE ocr_status = "done"
  AND review_status != "approved"
SORT updated_at DESC
```

Gợi ý `next_action`:

```text
Review Markdown: kiểm tra heading, bảng, page marker, nội dung OCR, metadata.
```

---

# 3. Checklist chất lượng sau OCR

## 3.1. Tài liệu OCR xong nhưng cần kiểm tra bảng/heading

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  document_type AS "Loại",
  department AS "Đơn vị",
  review_status AS "Review",
  assignee AS "Người phụ trách",
  notes AS "Ghi chú"
FROM "01_Dataset"
WHERE ocr_status = "done"
  AND (review_status = "reviewing" OR review_status = "need_fix" OR review_status = "not_reviewed")
SORT updated_at DESC
```

Checklist review thủ công:

- [ ] Không mất dấu tiếng Việt.
- [ ] Không lỗi font.
- [ ] Không thiếu trang.
- [ ] Không mất bảng.
- [ ] Bảng đúng cột/dòng.
- [ ] Heading đúng cấp.
- [ ] Không còn header/footer lặp lại.
- [ ] Có `<!-- page: n -->`.
- [ ] Nội dung không bị diễn giải sai.
- [ ] YAML metadata đầy đủ.

---

## 3.2. Tài liệu thiếu page marker

Dataview không kiểm tra trực tiếp nội dung `<!-- page: n -->` nếu không có field riêng.  
Nếu muốn theo dõi, thêm field vào YAML:

```yaml
page_marker_status: "missing"
```

Sau đó dùng view này:

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  page_marker_status AS "Page Marker",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm"
FROM "01_Dataset"
WHERE page_marker_status = "missing"
   OR page_marker_status = "need_review"
SORT updated_at DESC
```

Giá trị gợi ý:

```text
missing
need_review
done
```

---

# 4. Theo dõi hiệu lực tài liệu

## 4.1. Tài liệu chưa kiểm tra hiệu lực

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  code AS "Số hiệu",
  issued_date AS "Ngày ban hành",
  validity_status AS "Hiệu lực",
  is_latest AS "Mới nhất",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm"
FROM "01_Dataset"
WHERE validity_status = "unchecked"
   OR validity_status = "unknown"
SORT issued_date DESC, updated_at DESC
```

Gợi ý `next_action`:

```text
Kiểm tra có văn bản mới thay thế không, cập nhật validity_status và is_latest.
```

---

## 4.2. Tài liệu bị thay thế nhưng chưa deactivate

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  validity_status AS "Hiệu lực",
  rag_status AS "RAG",
  replaced_by AS "Bị thay thế bởi",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm"
FROM "01_Dataset"
WHERE validity_status = "replaced"
  AND rag_status != "deactivated"
SORT updated_at DESC
```

Cần sửa thành:

```yaml
validity_status: "replaced"
rag_status: "deactivated"
is_latest: false
```

---

## 4.3. Tài liệu đã valid nhưng chưa xác định bản mới nhất

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  validity_status AS "Hiệu lực",
  is_latest AS "Mới nhất",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm"
FROM "01_Dataset"
WHERE validity_status = "valid"
  AND is_latest = false
SORT updated_at DESC
```

Lưu ý:

```text
Nếu muốn retriever chỉ dùng bản mới nhất, cần xác định is_latest trước khi publish.
```

---

# 5. Theo dõi publish vào RAG

## 5.1. Tài liệu đủ điều kiện publish nhưng chưa published

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  ocr_status AS "OCR",
  review_status AS "Review",
  validity_status AS "Hiệu lực",
  rag_status AS "RAG",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm"
FROM "01_Dataset"
WHERE ocr_status = "done"
  AND review_status = "approved"
  AND validity_status = "valid"
  AND confidentiality = "public"
  AND rag_status != "published"
SORT updated_at DESC
```

Gợi ý `next_action`:

```text
Copy sang 04_RAG/Published hoặc đổi rag_status thành published để backend ingest.
```

---

## 5.2. Tài liệu đã published

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  department AS "Đơn vị",
  domain AS "Lĩnh vực",
  is_latest AS "Mới nhất",
  validity_status AS "Hiệu lực",
  rag_status AS "RAG",
  source_file AS "File gốc"
FROM "01_Dataset"
WHERE rag_status = "published"
SORT updated_at DESC
```

---

## 5.3. Tài liệu không hợp lệ nhưng đang published

Đây là view rất quan trọng để tránh chatbot dùng sai nguồn.

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  validity_status AS "Hiệu lực",
  review_status AS "Review",
  ocr_status AS "OCR",
  rag_status AS "RAG",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm"
FROM "01_Dataset"
WHERE rag_status = "published"
  AND (
    validity_status = "unchecked"
    OR validity_status = "unknown"
    OR validity_status = "expired"
    OR validity_status = "replaced"
    OR review_status != "approved"
    OR ocr_status != "done"
  )
SORT updated_at DESC
```

Nếu có kết quả, cần xử lý ngay:

```yaml
rag_status: "deactivated"
```

hoặc sửa metadata cho đúng.

---

# 6. Theo dõi theo người phụ trách

## 6.1. Công việc theo assignee

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  ocr_status AS "OCR",
  review_status AS "Review",
  validity_status AS "Hiệu lực",
  rag_status AS "RAG",
  next_action AS "Việc cần làm",
  due_date AS "Deadline",
  blocker AS "Vướng mắc"
FROM "01_Dataset"
WHERE assignee
SORT assignee ASC, due_date ASC
```

---

## 6.2. Việc quá hạn

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm",
  due_date AS "Deadline",
  blocker AS "Vướng mắc"
FROM "01_Dataset"
WHERE due_date < date(today)
  AND rag_status != "published"
SORT due_date ASC
```

---

## 6.3. Việc đang bị blocker

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tên tài liệu",
  assignee AS "Người phụ trách",
  blocker AS "Vướng mắc",
  next_action AS "Việc cần làm"
FROM "01_Dataset"
WHERE blocker
SORT updated_at DESC
```

---

# 7. View theo từng đơn vị / lĩnh vực

## 7.1. Theo đơn vị

```dataview
TABLE WITHOUT ID department AS "Đơn vị", length(rows) AS "Số tài liệu"
FROM "01_Dataset"
GROUP BY department
SORT length(rows) DESC
```

## 7.2. Theo lĩnh vực

```dataview
TABLE WITHOUT ID domain AS "Lĩnh vực", length(rows) AS "Số tài liệu"
FROM "01_Dataset"
GROUP BY domain
SORT length(rows) DESC
```

## 7.3. Theo loại tài liệu

```dataview
TABLE WITHOUT ID document_type AS "Loại tài liệu", length(rows) AS "Số tài liệu"
FROM "01_Dataset"
GROUP BY document_type
SORT length(rows) DESC
```

---

# 8. Checklist thao tác cho team member

## Khi nhận một tài liệu mới

- [ ] Kiểm tra file gốc trong `02_Attachments`.
- [ ] Tạo hoặc cập nhật file Markdown trong `01_Dataset`.
- [ ] Điền `document_id`.
- [ ] Điền `version_id`.
- [ ] Điền `source_file` hoặc `source_url`.
- [ ] Đặt `ocr_status: "not_started"` nếu chưa OCR.
- [ ] Gán `assignee`.
- [ ] Ghi `next_action`.

## Khi OCR xong

- [ ] Đặt `ocr_status: "done"`.
- [ ] Kiểm tra tiếng Việt.
- [ ] Kiểm tra bảng.
- [ ] Kiểm tra heading.
- [ ] Kiểm tra page marker.
- [ ] Đặt `review_status: "reviewing"` hoặc `"not_reviewed"`.
- [ ] Ghi `next_action: "Review nội dung OCR"`.

## Khi review xong

- [ ] Đặt `review_status: "approved"` nếu đạt.
- [ ] Nếu lỗi, đặt `review_status: "need_fix"`.
- [ ] Kiểm tra `validity_status`.
- [ ] Nếu chưa rõ hiệu lực, giữ `validity_status: "unchecked"`.

## Khi xác minh hiệu lực

- [ ] Nếu còn hiệu lực: `validity_status: "valid"`.
- [ ] Nếu hết hạn: `validity_status: "expired"`.
- [ ] Nếu bị thay thế: `validity_status: "replaced"`.
- [ ] Nếu bị thay thế thì đặt `rag_status: "deactivated"`.
- [ ] Cập nhật `is_latest`.

## Khi publish

Chỉ publish nếu:

```yaml
ocr_status: "done"
review_status: "approved"
validity_status: "valid"
confidentiality: "public"
```

Sau đó:

```yaml
rag_status: "published"
```

---

# 9. Công thức nhớ nhanh

```text
Chưa OCR → team OCR.
OCR xong → team review.
Review approved → kiểm tra hiệu lực.
Valid + Public → publish.
Unchecked thì không publish.
Replaced thì deactivated.
Published nhưng không valid là lỗi nghiêm trọng.
```
