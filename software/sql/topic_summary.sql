with
    totals
        as
    (select
        topic_code, online_doc_lang_code, count(uuid) as topic_total
        from
            feedback.reader_activities
        where
            topic_code='{0}'
        group by
            topic_code,
            online_doc_lang_code),
    totals_by_reader_langs
        as
    (select
        topic_code, online_doc_lang_code, reader_lang_code, count(uuid) as reader_lang_total
        from feedback.reader_activities
        where
            topic_code='{0}'
        group by
            topic_code,
            online_doc_lang_code,
            reader_lang_code)
select
    t.topic_code,
    t.online_doc_lang_code,
    trl.reader_lang_code,
    reader_lang_total,
    topic_total,
    (reader_lang_total::real)/(topic_total::real) as lang_share
    from
         totals t, totals_by_reader_langs trl
    where
        t.topic_code = trl.topic_code
            and
        t.online_doc_lang_code = trl.online_doc_lang_code;