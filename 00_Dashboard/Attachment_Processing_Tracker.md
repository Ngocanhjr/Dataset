---
title: "Dashboard - OCR Intake Tracking"
document_type: "dashboard"
domain: "ocr_tracking"
department: "NLCS"
version: "1.0"
status: "active"
created_at: "2026-05-24"
updated_at: "2026-05-24"
tags:
  - dashboard
  - attachment-intake
  - ocr
---

# Dashboard - OCR Intake Tracking

Dashboard này chỉ theo dõi **file gốc đã có tracking note trong `06_Processing/00_Attachment_Intake`**.

Quy trình ngắn:

```text
02_Attachments
  ↓ tạo tracking note
06_Processing/00_Attachment_Intake
  ↓ OCR
06_Processing/01_OCR_Output
  ↓ formatter / cleaning / review
01_Dataset
```

> Dataview không theo dõi trực tiếp PDF. Mỗi attachment cần có 1 file tracking `.md` trong `06_Processing/00_Attachment_Intake`.

---

## 1. Tổng quan OCR status

```dataview
TABLE WITHOUT ID ocr_status AS "OCR Status", length(rows) AS "Số lượng"
FROM "06_Processing/00_Attachment_Intake"
GROUP BY ocr_status
SORT ocr_status ASC
```

---

## 2. Tất cả file intake

```dataview
TABLE
  title AS "Tên tài liệu",
  source_file AS "File gốc",
  ocr_status AS "OCR",
  processing_stage AS "Giai đoạn",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm",
  due_date AS "Deadline",
  blocker AS "Vướng mắc"
FROM "06_Processing/00_Attachment_Intake"
SORT updated_at DESC
```

---

## 3. Chưa OCR

```dataview
TABLE
  title AS "Tên tài liệu",
  source_file AS "File gốc",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm",
  due_date AS "Deadline"
FROM "06_Processing/00_Attachment_Intake"
WHERE ocr_status = "not_started"
SORT due_date ASC, updated_at DESC
```

---

## 4. Đang OCR hoặc bị lỗi

```dataview
TABLE
  title AS "Tên tài liệu",
  source_file AS "File gốc",
  ocr_status AS "OCR",
  processing_stage AS "Giai đoạn",
  assignee AS "Người phụ trách",
  blocker AS "Vướng mắc",
  updated_at AS "Cập nhật"
FROM "06_Processing/00_Attachment_Intake"
WHERE ocr_status = "processing"
   OR ocr_status = "failed"
   OR ocr_status = "need_review"
SORT ocr_status ASC, updated_at DESC
```

---

## 5. Đã OCR xong

```dataview
TABLE
  title AS "Tên tài liệu",
  source_file AS "File gốc",
  ocr_output_file AS "File OCR output",
  assignee AS "Người phụ trách",
  next_action AS "Việc tiếp theo",
  updated_at AS "Cập nhật"
FROM "06_Processing/00_Attachment_Intake"
WHERE ocr_status = "done"
SORT updated_at DESC
```

---

## 6. Theo người phụ trách

```dataview
TABLE
  title AS "Tên tài liệu",
  ocr_status AS "OCR",
  processing_stage AS "Giai đoạn",
  next_action AS "Việc cần làm",
  due_date AS "Deadline",
  blocker AS "Vướng mắc"
FROM "06_Processing/00_Attachment_Intake"
WHERE assignee
SORT assignee ASC, due_date ASC
```

---

## 7. Việc quá hạn

```dataview
TABLE
  title AS "Tên tài liệu",
  source_file AS "File gốc",
  assignee AS "Người phụ trách",
  next_action AS "Việc cần làm",
  due_date AS "Deadline",
  blocker AS "Vướng mắc"
FROM "06_Processing/00_Attachment_Intake"
WHERE due_date < date(today)
  AND ocr_status != "done"
SORT due_date ASC
```

---

## 8. Công thức dùng nhanh

```text
attachment_only + not_started = mới có file gốc, chưa OCR
ocr_processing + processing = đang OCR
ocr_output + done = đã OCR xong, chuyển sang formatter/cleaning
failed = OCR lỗi, cần xử lý lại
need_review = OCR cần kiểm tra lại
```
