update auth.sessions 
    set closed_at = '{0}' 
    where 
        closed_at is null 
            and 
        expire_at < '{0}';