-- NLCS RAG - Asset/Form/Version schema
-- Created: 2026-05-24
-- Purpose: Manage downloadable files, forms, attachments, and document relationships.

CREATE TABLE IF NOT EXISTS document_assets (
    id UUID PRIMARY KEY,
    asset_id TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    asset_type TEXT NOT NULL,
    domain TEXT,
    department TEXT,

    file_name TEXT,
    file_path TEXT,
    file_type TEXT,
    mime_type TEXT,
    file_size BIGINT,
    checksum TEXT,

    is_downloadable BOOLEAN DEFAULT false,
    download_url TEXT,
    source_url TEXT,
    accessed_date DATE,

    version TEXT,
    is_latest BOOLEAN DEFAULT false,
    validity_status TEXT NOT NULL DEFAULT 'unchecked',

    collection_status TEXT DEFAULT 'collected',
    review_status TEXT DEFAULT 'not_reviewed',
    rag_status TEXT DEFAULT 'not_indexed',

    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS document_asset_links (
    id UUID PRIMARY KEY,
    asset_id TEXT NOT NULL,
    document_id TEXT,
    version_id TEXT,
    procedure_code TEXT,
    relation_type TEXT NOT NULL,
    required BOOLEAN DEFAULT false,
    required_when TEXT,
    display_order INT DEFAULT 0,
    note TEXT,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS document_relationships (
    id UUID PRIMARY KEY,
    source_document_id TEXT,
    source_version_id TEXT,
    target_document_id TEXT,
    target_version_id TEXT,
    target_asset_id TEXT,
    relation_type TEXT NOT NULL,
    note TEXT,
    created_at TIMESTAMP DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_document_assets_asset_type
ON document_assets(asset_type);

CREATE INDEX IF NOT EXISTS idx_document_assets_validity_rag
ON document_assets(validity_status, rag_status, is_latest);

CREATE INDEX IF NOT EXISTS idx_document_assets_downloadable
ON document_assets(is_downloadable);

CREATE INDEX IF NOT EXISTS idx_document_asset_links_asset_id
ON document_asset_links(asset_id);

CREATE INDEX IF NOT EXISTS idx_document_asset_links_version_id
ON document_asset_links(version_id);

CREATE INDEX IF NOT EXISTS idx_document_asset_links_document_id
ON document_asset_links(document_id);

CREATE INDEX IF NOT EXISTS idx_document_asset_links_relation
ON document_asset_links(relation_type);

CREATE INDEX IF NOT EXISTS idx_document_relationships_source_version
ON document_relationships(source_version_id);

CREATE INDEX IF NOT EXISTS idx_document_relationships_target_version
ON document_relationships(target_version_id);

CREATE INDEX IF NOT EXISTS idx_document_relationships_relation
ON document_relationships(relation_type);

CREATE OR REPLACE VIEW active_downloadable_assets AS
SELECT *
FROM document_assets
WHERE is_downloadable = true
  AND validity_status = 'valid'
  AND rag_status IN ('published', 'indexed');

-- Query example: forms/files linked to a document version
-- SELECT
--     da.asset_id,
--     da.title,
--     da.file_path,
--     da.download_url,
--     da.file_type,
--     dal.required,
--     dal.required_when,
--     dal.note
-- FROM document_asset_links dal
-- JOIN document_assets da ON da.asset_id = dal.asset_id
-- WHERE dal.version_id = :version_id
--   AND dal.relation_type IN ('required_form', 'optional_form', 'downloadable_file')
--   AND da.validity_status = 'valid'
-- ORDER BY dal.required DESC, dal.display_order ASC;
