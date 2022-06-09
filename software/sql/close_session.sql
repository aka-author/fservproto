update auth.sessions 
    set 
        closed_at = '{1}' 
    where 
        uuid = '{0}'
            and
        closed_at is null;