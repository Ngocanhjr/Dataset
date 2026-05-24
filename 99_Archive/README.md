# README - 99_Archive

Cập nhật: `2026-05-24`

`99_Archive` dùng để lưu tài liệu, biểu mẫu hoặc file liên quan đã cũ, hết hiệu lực, bị thay thế hoặc không còn dùng trong Active RAG.

---

## 1. Không xóa version cũ

Version cũ cần được giữ để:

- Audit câu trả lời cũ của chatbot.
- Truy vết văn bản nào đã từng được dùng.
- So sánh thay đổi giữa các version.
- Phục vụ chế độ tra cứu lịch sử cho admin.

---

## 2. Metadata cho bản cũ

```yaml
is_latest: false
validity_status: "replaced"
rag_status: "deactivated"
replaced_by:
  - "<version_id_moi>"
```

Nếu hết hiệu lực nhưng không bị thay thế rõ ràng:

```yaml
is_latest: false
validity_status: "expired"
rag_status: "deactivated"
```

---

## 3. Backend/RAG rule

Tài liệu trong archive không được retriever mặc định sử dụng.

Retriever mặc định chỉ lấy:

```text
rag_status = published
validity_status = valid
confidentiality = public
```

Admin có thể xây chế độ riêng để tra cứu lịch sử, nhưng phải hiển thị cảnh báo:

```text
Đây là tài liệu cũ/hết hiệu lực/bị thay thế, không dùng làm căn cứ hiện hành.
```

---

## 4. Khi chuyển file vào archive

- [ ] Cập nhật `validity_status`.
- [ ] Cập nhật `rag_status`.
- [ ] Cập nhật `is_latest`.
- [ ] Cập nhật `replaced_by` hoặc lý do hết hiệu lực.
- [ ] Deactivate vector cũ trong Qdrant.
- [ ] Giữ lại `source_file`, `source_path`, `checksum`.
