# Dataset List

## Tất cả tài liệu trong `01_Dataset`

```dataview
TABLE document_id, version_id, title, document_type, department, domain, review_status, rag_status
FROM "NLCS/01_Dataset"
SORT department ASC, title ASC
```

## Theo loại tài liệu

```dataview
TABLE document_id, version_id, title, department, validity_status, rag_status
FROM "NLCS/01_Dataset"
GROUP BY document_type
SORT document_type ASC
```

## Theo đơn vị phụ trách

```dataview
TABLE document_id, version_id, title, document_type, validity_status, rag_status
FROM "NLCS/01_Dataset"
GROUP BY department
SORT department ASC
```

## Theo version mới nhất

```dataview
TABLE document_id, version_id, title, version, is_latest, validity_status, rag_status
FROM "NLCS/01_Dataset"
WHERE is_latest = true
SORT updated_at DESC
```
