select uuid  
    from auth.sessions
    where 
        uuid = '{0}' 
            and 
        closed_at is null 
            and 
        expire_at >= '{1}';