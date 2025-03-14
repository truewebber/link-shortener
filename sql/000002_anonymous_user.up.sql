INSERT INTO users (provider_type,
                   provider_user_id,
                   provider_user_email,
                   provider_user_name,
                   created_at,
                   updated_at,
                   deleted)
VALUES ('-1',
        -1,
        '',
        'default_anonymous',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        FALSE);