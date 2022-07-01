
select
    uuid, 
	online_doc_code, online_doc_lang_code, online_doc_ver_no,
	topic_code, topic_ver_no,
	reader_country_code, reader_lang_code, reader_os_code, reader_browser_code,
	accepted_at, 
	message_type_code, message_text
    from 
		feedback.reader_activities
	where
		topic_code = '{0}' and activity_type_code='MESSAGE'
	order by 
		accepted_at desc;