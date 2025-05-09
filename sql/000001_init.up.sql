CREATE TABLE IF NOT EXISTS users
(
    id                  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    provider_type       SMALLINT  NOT NULL,
    provider_user_id    VARCHAR   NOT NULL,
    provider_user_email VARCHAR   NOT NULL,
    provider_user_name  VARCHAR   NOT NULL,
    provider_avatar_url VARCHAR   NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted             BOOLEAN   NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS users__provider_type__provider_user_id__udx
    ON users (provider_type, provider_user_id);

--
CREATE TABLE IF NOT EXISTS tokens
(
    id                       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id                  BIGINT    NOT NULL REFERENCES users (id),
    access_token             VARCHAR   NOT NULL,
    refresh_token            VARCHAR   NOT NULL,
    access_token_expires_at  TIMESTAMP NOT NULL,
    refresh_token_expires_at TIMESTAMP NOT NULL,
    created_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted                  BOOLEAN   NOT NULL
);

CREATE INDEX IF NOT EXISTS tokens__user_id__idx
    ON tokens (user_id)
    WHERE NOT deleted;

CREATE INDEX IF NOT EXISTS tokens__access_token__idx
    ON tokens (access_token)
    WHERE NOT deleted;

CREATE INDEX IF NOT EXISTS tokens__refresh_token__idx
    ON tokens (refresh_token)
    WHERE NOT deleted;

CREATE INDEX IF NOT EXISTS tokens__access_token_expires_at__idx
    ON tokens (access_token_expires_at)
    WHERE NOT deleted;

CREATE INDEX IF NOT EXISTS tokens__refresh_token_expires_at__idx
    ON tokens (refresh_token_expires_at)
    WHERE NOT deleted;

--
CREATE TABLE IF NOT EXISTS urls
(
    id           BIGSERIAL PRIMARY KEY,
    user_id      BIGINT    NOT NULL REFERENCES users (id),
    redirect_url TEXT      NOT NULL,
    expires_type VARCHAR   NOT NULL,
    expires_at   TIMESTAMP,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted      BOOLEAN   NOT NULL
);

CREATE INDEX IF NOT EXISTS urls__user_id__expires_at__idx
    ON urls (user_id, expires_at)
    WHERE NOT deleted;
CREATE UNIQUE INDEX IF NOT EXISTS urls_user_redirect_md5_uniq_not_deleted
    ON urls (user_id, md5(redirect_url))
    WHERE NOT deleted;

--
CREATE TABLE IF NOT EXISTS url_stats
(
    url_id     BIGINT    NOT NULL REFERENCES urls (id),
    user_agent TEXT      NOT NULL,
    visited_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted    BOOLEAN   NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_url_stats_url_id
    ON url_stats (url_id, visited_at)
    WHERE NOT deleted;
