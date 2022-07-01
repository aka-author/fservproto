/* 
    0 - a target column name
    1 - a list argument columns
    2 - the conditions for readers' activities
    3 - a list of columns for a group by 
    4 - the conditions for joining totals
*/
with
    analyzed_reader_activities
        as
    (select 
        uuid, 
        online_doc_code, online_doc_lang_code, online_doc_ver_no, 
        topic_code, topic_ver_no, 
        reader_country_code, reader_lang_code, reader_os_code, reader_browser_code, 
        accepted_at,
        activity_type_code, 
        case when activity_type_code in ('BOUNCE', 'DISLIKE', 'MESSAGE') then 1 else 0 end as count_quality_issues
    from 
        feedback.reader_activities),
    totals
        as
    (select
        {1}, count(a.uuid) as topic_total, sum(a.count_quality_issues) as quality_issues_total
        from
            analyzed_reader_activities a
        where
            {2}
        group by
            {3}),
    totals_by_reader_attr
        as
    (select
        {1}, {0}, count(uuid) as reader_attrvalue_total
        from feedback.reader_activities a
        where
            {2}
        group by
            {1}, {0})
select
    {1}, trl.{0},
    reader_attrvalue_total, topic_total,
    (reader_attrvalue_total::real)/(topic_total::real) as share,
    (quality_issues_total::real)/(topic_total::real) as badness
    from
        totals a, totals_by_reader_attr trl
    where
        {4};

        