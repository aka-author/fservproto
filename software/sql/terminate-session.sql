update auth.sessions 
    set terminated_at = '{0}' 
    where 
        terminated_at is null 
            and 
        expires_at < '{0}';