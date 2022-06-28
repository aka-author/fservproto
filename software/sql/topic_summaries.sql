/* 
    0 - a target column name
    1 - a list argument columns
    2 - the conditions for readers' activities
    3 - a list of columns for a group by 
    4 - the conditions for joining totals
*/
with
    totals
        as
    (select
        {1}, count(a.uuid) as topic_total
        from
            feedback.reader_activities a
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
    (reader_attrvalue_total::real)/(topic_total::real) as share
    from
         totals a, totals_by_reader_attr trl
    where
       /* {4} */

        a.topic_code = trl.topic_code
            and
        a.online_doc_lang_code = trl.online_doc_lang_code;