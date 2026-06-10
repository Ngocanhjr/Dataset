---
title: "Dashboard - Tracking Attachments, OCR và Processing"
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
  - attachment
  - intake
  - ocr
  - processing
  - rag
---

# Dashboard - Tracking Attachments, OCR và Processing

Dashboard này dùng để team biết:

- File nào **mới chỉ được thêm vào `02_Attachments`**.
- File nào đã có **tracking note trong `06_Processing/00_Attachment_Intake`**.
- File nào đang OCR, OCR lỗi, đang cleaning hoặc cần review.
- File nào đã vào `01_Dataset`.
- Ai đang phụ trách và việc tiếp theo là gì.

> Lưu ý quan trọng: Dataview không quản lý trạng thái OCR/RAG trực tiếp từ file PDF. Vì vậy mỗi attachment cần có một file tracking `.md` trong `06_Processing/00_Attachment_Intake`.

---

## 0. Quy trình tracking chuẩn

```text
02_Attachments/PDFs/.../*.pdf
  ↓
06_Processing/00_Attachment_Intake/*_tracking.md
  ↓
06_Processing/01_OCR_Output/*.md
  ↓
06_Processing/03_Markdown_Cleaning/*.md
  ↓
06_Processing/04_Need_Review/*.md
  ↓
01_Dataset/<folder>/*.md
  ↓
04_RAG/Published hoặc rag_status = published
```

---

# 1. Tổng quan theo processing stage

```dataview
TABLE WITHOUT ID processing_stage AS "Giai đoạn", length(rows) AS "Số lượng"
FROM "06_Processing"
WHERE processing_stage
GROUP BY processing_stage
SORT processing_stage ASC
```

---

# 2. File mới chỉ thêm attachment, chưa OCR

Các file này đã có PDF gốc và tracking note, nhưng chưa bắt đầu OCR.

```dataview
TABLE
  title AS "Tài liệu",
  department AS "Đơn vị",
  domain AS "Lĩnh vực",
  source_file AS "File gốc",
  ocr_status AS "OCR",
  processing_stage AS "Giai đoạn",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm",
  due_date AS "Deadline",
  blocker AS "Vướng mắc"
FROM "06_Processing/00_Attachment_Intake"
WHERE processing_stage = "attachment_only"
   OR ocr_status = "not_started"
SORT due_date ASC, updated_at DESC
```

---

# 3. File intake chưa có người phụ trách

```dataview
TABLE
  title AS "Tài liệu",
  department AS "Đơn vị",
  source_file AS "File gốc",
  next_action AS "Việc cần làm",
  due_date AS "Deadline"
FROM "06_Processing/00_Attachment_Intake"
WHERE !assignee
SORT updated_at DESC
```

---

# 4. File đang OCR hoặc OCR lỗi

```dataview
TABLE
  title AS "Tài liệu",
  department AS "Đơn vị",
  source_file AS "File gốc",
  ocr_status AS "OCR",
  processing_stage AS "Giai đoạn",
  assignee AS "Người phụ trách",
  blocker AS "Vướng mắc",
  updated_at AS "Cập nhật"
FROM "06_Processing"
WHERE ocr_status = "processing"
   OR ocr_status = "failed"
   OR ocr_status = "need_review"
SORT ocr_status ASC, updated_at DESC
```

---

# 5. File đã OCR xong nhưng chưa vào `01_Dataset`

```dataview
TABLE
  title AS "Tài liệu",
  department AS "Đơn vị",
  source_file AS "File gốc",
  ocr_status AS "OCR",
  review_status AS "Review",
  processing_stage AS "Giai đoạn",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm"
FROM "06_Processing"
WHERE ocr_status = "done"
  AND processing_stage != "dataset_ready"
SORT updated_at DESC
```

---

# 6. File đang cleaning hoặc cần review

```dataview
TABLE
  title AS "Tài liệu",
  department AS "Đơn vị",
  source_file AS "File gốc",
  ocr_status AS "OCR",
  review_status AS "Review",
  processing_stage AS "Giai đoạn",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm",
  blocker AS "Vướng mắc"
FROM "06_Processing"
WHERE processing_stage = "markdown_cleaning"
   OR processing_stage = "need_review"
   OR review_status = "reviewing"
   OR review_status = "need_fix"
SORT updated_at DESC
```

---

# 7. File đã vào `01_Dataset`

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tài liệu",
  department AS "Đơn vị",
  source_file AS "File gốc",
  ocr_status AS "OCR",
  review_status AS "Review",
  validity_status AS "Hiệu lực",
  rag_status AS "RAG",
  assignee AS "Người phụ trách"
FROM "01_Dataset"
SORT updated_at DESC
```

---

# 8. File đủ điều kiện publish nhưng chưa published

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tài liệu",
  source_file AS "File gốc",
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

---

# 9. File không hợp lệ nhưng đang published

Nếu view này có dữ liệu thì cần xử lý ngay.

```dataview
TABLE
  document_id AS "Document ID",
  version_id AS "Version ID",
  title AS "Tài liệu",
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

---

# 10. Workboard theo người phụ trách

```dataview
TABLE
  title AS "Tài liệu",
  source_file AS "File gốc",
  processing_stage AS "Giai đoạn",
  ocr_status AS "OCR",
  review_status AS "Review",
  validity_status AS "Hiệu lực",
  rag_status AS "RAG",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm",
  due_date AS "Deadline",
  blocker AS "Vướng mắc"
FROM "06_Processing" OR "01_Dataset"
WHERE assignee
SORT assignee ASC, due_date ASC
```

---

# 11. Việc quá hạn

```dataview
TABLE
  title AS "Tài liệu",
  source_file AS "File gốc",
  processing_stage AS "Giai đoạn",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm",
  due_date AS "Deadline",
  blocker AS "Vướng mắc"
FROM "NLCS/06_Processing" OR "01_Dataset"
WHERE due_date < date(today)
  AND rag_status != "published"
SORT due_date ASC
```

---

# 12. Cách dùng với attachment mới

Khi team thêm file PDF vào `02_Attachments`, làm ngay:

1. Tạo một tracking note trong:

```text
NLCS/06_Processing/00_Attachment_Intake/
```

2. Điền tối thiểu:

```yaml
source_file: "[[ten_file.pdf]]"
source_path: "02_Attachments/PDFs/.../ten_file.pdf"
processing_stage: "attachment_only"
ocr_status: "not_started"
review_status: "not_reviewed"
validity_status: "unchecked"
rag_status: "not_indexed"
assignee:
next_action: "OCR file gốc sang Markdown và lưu vào 06_Processing/01_OCR_Output"
```

3. Gán `assignee` để team biết ai làm.
4. Khi OCR xong, cập nhật:

```yaml
ocr_status: "done"
processing_stage: "ocr_output"
next_action: "Làm sạch Markdown và chuyển sang 06_Processing/03_Markdown_Cleaning"
```

5. Khi đưa vào `01_Dataset`, cập nhật tracking note hoặc ghi:

```yaml
processing_stage: "dataset_ready"
next_action: "Theo dõi file chính trong 01_Dataset"
```

---

# 13. Quy ước `processing_stage`

```text
attachment_only     # mới có file gốc, chưa OCR
ocr_processing      # đang OCR
ocr_output          # đã có output OCR
ocr_failed          # OCR lỗi
markdown_cleaning   # đang làm sạch Markdown
need_review         # cần người review
dataset_ready       # đã chuyển sang 01_Dataset
rag_published       # đã publish vào RAG
blocked             # đang bị chặn
```

---

# 14. Công thức nhớ nhanh

```text
PDF mới thêm thì tạo tracking note.
Dashboard không theo dõi PDF trực tiếp, dashboard theo dõi tracking .md.
Attachment-only = processing_stage: attachment_only.
Đã vào xử lý = nằm trong 06_Processing và có processing_stage.
Đã thành tri thức chính thức = nằm trong 01_Dataset.
```
