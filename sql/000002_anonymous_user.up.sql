INSERT INTO users (provider_type,
                   provider_user_id,
                   provider_user_email,
                   provider_user_name,
                   provider_avatar_url,
                   created_at,
                   updated_at,
                   deleted)
VALUES (1,
        'anonymous_provider_id',
        'anonymous@example.com',
        'Anonymous',
        '',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        FALSE);
