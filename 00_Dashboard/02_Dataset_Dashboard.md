# Dataset Dashboard

Dashboard này dùng plugin Dataview để theo dõi trạng thái tài liệu trong `01_Dataset`.

## Tổng quan trạng thái OCR

```dataview
TABLE document_id, title, department, domain, ocr_status, review_status, rag_status, validity_status
FROM "NLCS/01_Dataset"
SORT updated_at DESC
```

## Tài liệu chưa OCR

```dataview
TABLE document_id, title, department, ocr_status, review_status, rag_status
FROM "NLCS/01_Dataset"
WHERE ocr_status = "not_started"
SORT updated_at DESC
```

## Tài liệu cần review

```dataview
TABLE document_id, title, department, ocr_status, review_status, validity_status
FROM "NLCS/01_Dataset"
WHERE review_status = "reviewing" OR review_status = "need_fix" OR review_status = "not_reviewed"
SORT updated_at DESC
```

## Tài liệu đã sẵn sàng đưa vào RAG

```dataview
TABLE document_id, version_id, title, department, domain, rag_status, validity_status, is_latest
FROM "NLCS/01_Dataset"
WHERE review_status = "approved"
AND ocr_status = "done"
AND validity_status = "valid"
SORT updated_at DESC
```

## Tài liệu đã publish

```dataview
TABLE document_id, version_id, title, department, domain, rag_status, source_file
FROM "NLCS/01_Dataset"
WHERE rag_status = "published"
SORT updated_at DESC
```

## Tài liệu cũ / bị thay thế

```dataview
TABLE document_id, version_id, title, version, validity_status, replaced_by, rag_status
FROM "NLCS/01_Dataset"
WHERE validity_status = "replaced" OR rag_status = "deactivated"
SORT updated_at DESC
```
