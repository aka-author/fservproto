select uuid  
    from auth.sessions
    where 
        token = '{0}' 
            and 
        terminated_at is null 
            and 
        expires_at >= '{1}';