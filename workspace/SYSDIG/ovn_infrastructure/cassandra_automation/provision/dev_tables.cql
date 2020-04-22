USE ovn_dev1;
CREATE TABLE IF NOT EXISTS advice_exception (
    event_type text,
    exception_id text,
    exception_datetime timestamp,
    exception_message text,
    payload text,
    PRIMARY KEY (event_type, exception_id)
);

CREATE TABLE IF NOT EXISTS advice_by_pcr (
	pcr text,
	routing_rule text,
	net_id int,
	priority int,
	queued_datetime timestamp,
	advice_name text,
	transaction_lifecycle_key text,
	message_lifecycle_key text,
	advice_key text,
	source_workspace_id text,
	advice_source text,
	advice_status text,
	advice_type text,
	execution_group text,
	retry_count int,
	source_datetime timestamp,
	status_updated_datetime timestamp,
	PRIMARY KEY ((pcr), routing_rule, net_id, priority, queued_datetime, advice_name, advice_key)
);

CREATE INDEX IF NOT EXISTS status on advice_by_pcr(advice_status);
CREATE INDEX IF NOT EXISTS execgroup on advice_by_pcr(execution_group);

CREATE TABLE IF NOT EXISTS suspended_advice_by_pcr (
	pcr text,
	routing_rule text,
	net_id int,
	priority int,
	queued_datetime timestamp,
	advice_name text,
	transaction_lifecycle_key text,
	message_lifecycle_key text,
	advice_key text,
	source_workspace_id text,
	advice_source text,
	advice_status text,
	advice_type text,
	execution_group text,
	retry_count int,
	source_datetime timestamp,
	status_reason_code text,
	suspended_datetime timestamp,
	PRIMARY KEY ((pcr), advice_name, advice_key)
) ;

CREATE TABLE IF NOT EXISTS message_lifecycle (
    lc_group_key text,
    business_key text,
    workspace_key text,
    workspace blob,
    PRIMARY KEY (lc_group_key, business_key, workspace_key)
) WITH default_time_to_live = '300';

CREATE TABLE IF NOT EXISTS transaction_lifecycle (
    lc_group_key text,
    business_key text,
    workspace_key text,
    workspace blob,
    PRIMARY KEY (lc_group_key, business_key, workspace_key)
) WITH default_time_to_live = '15552000';

CREATE TABLE IF NOT EXISTS key_consistency (
    rrn text,
    acq_id int,
    hashed_pan blob,
    PRIMARY KEY (rrn, acq_id)
) WITH default_time_to_live = '15552000';

CREATE TABLE IF NOT EXISTS timer (
    timer_partition_id int,
    expiry_date text,
    timer_id text,
    creation_date_time timestamp,
    source text,
    destination_name text,
    destination_partition_id int,
    destination_partition_key text,
    expiry_time timestamp,
    metadata text,
    status int,
    PRIMARY KEY (timer_partition_id, expiry_date, timer_id, creation_date_time, source)
) WITH default_time_to_live = '604800';

CREATE INDEX IF NOT EXISTS timer_status ON  timer (status);

CREATE TABLE IF NOT EXISTS station (
    pcr int,
    station_id int,
    type int,
    seq_no int,
    status boolean,
    time timestamp,
    username text,
    PRIMARY KEY (pcr, station_id, type)
);

CREATE INDEX IF NOT EXISTS station_status ON station(status);

CREATE TABLE IF NOT EXISTS exception_data (
	hashed_pan text,
	exception_file_name text,
	action_code text,
	action_update_method text,
	security_code text,
	crb_region_list blob,
	cardholder_spending_count_limit int,
	cardholder_spending_amount_limit int,
    action_date date,
	purge_date date,
	update_date date,
	update_time timestamp,
	PRIMARY KEY (hashed_pan)
);

CREATE TABLE IF NOT EXISTS exception_history (
	hashed_pan text,
	exception_file_name text,
	action_code text,
	action_update_method text,
	security_code text,
	crb_region_list blob,
	cardholder_spending_count_limit int,
	cardholder_spending_amount_limit int,
    action_date date,
	purge_date date,
	update_date date,
	update_time timestamp,
	sno timeuuid,
	PRIMARY KEY (hashed_pan, update_date, sno)
);

CREATE TABLE IF NOT EXISTS activity (
	hashed_primary_account_number text,
    create_date date,
    pos_txn_cnt counter,
    pos_txn_amt counter,
    atm_txn_cnt counter,
    atm_txn_amt counter,
    PRIMARY KEY (hashed_primary_account_number, create_date)
);

CREATE TABLE IF NOT EXISTS unknown_bytes (
	correlation_id text,
	data blob,
	PRIMARY KEY (correlation_id)
);

CREATE TABLE IF NOT EXISTS tran_id_state (
	pod_name text,
	tran_id_snapshot bigint,
	PRIMARY KEY (pod_name)
) WITH default_time_to_live = '172800';

CREATE TABLE IF NOT EXISTS clearing_cib_destn_by_stlmt_window (
	stlmt_window_id int,
    cpd date,
    cib int,
	PRIMARY KEY((cpd,stlmt_window_id),cib)
);

CREATE TABLE If Not Exists request (
    profile_type int,
    extract_date text,
    major int,
    minor int,
    request_type int,
    insert_time timestamp,
    request_status int,
    PRIMARY KEY (profile_type, extract_date, major, minor, request_type, insert_time)
    ) WITH CLUSTERING ORDER BY (extract_date ASC, major ASC, minor ASC, request_type ASC, insert_time DESC);

CREATE TABLE If Not Exists version (
    profile_type int,
    extract_date text,
    major int,
    minor int,
    activation_time timestamp,
    extract_time timestamp,
    master_path text,
    version_status int,
    working_path text,
    PRIMARY KEY (profile_type, extract_date, major, minor)
);
CREATE INDEX IF NOT EXISTS version_status ON version (version_status);

CREATE TABLE If Not Exists keep_track (
    bucket_name text,
    bucket_id text,
    key text,
    time_to_live timestamp,
    value boolean,
    PRIMARY KEY (bucket_name, bucket_id, key)
);

CREATE TABLE IF NOT EXISTS clearing_subscriber_destn_by_stlmt_window (
	stlmt_window_id int,
    cpd date,
    subscriber_id int,
    PRIMARY KEY((cpd, stlmt_window_id), subscriber_id)
);

CREATE TABLE IF NOT EXISTS sms_rpt_order_by_acqbin(
    subscriber_id text,
    affiliate_bin text,
    vss_processor text,
    window_id text,
    cpd text,
    acquiring_bin text,
    card_number text,
    issuing_bin text,
    retrieval_reference_number text,
    transmission_date_and_time text,
    transaction_key text,
    fund_transfer_sre text,
    lowest_level_sre text,
    version text,
    data_subset blob,
    PRIMARY KEY ((subscriber_id, affiliate_bin, vss_processor,  window_id, cpd), fund_transfer_sre, lowest_level_sre, acquiring_bin, transaction_key)
);

CREATE TABLE IF NOT EXISTS sms_rpt_order_by_issbin(
    subscriber_id text,
    affiliate_bin text,
    vss_processor text,
    window_id text,
    cpd text,
    acquiring_bin text,
    card_number text,
    issuing_bin text,
    retrieval_reference_number text,
    transmission_date_and_time text,
    transaction_key text,
    fund_transfer_sre text,
    lowest_level_sre text,
    version text,
    data_subset blob,
    PRIMARY KEY ((subscriber_id, affiliate_bin, vss_processor,  window_id, cpd), fund_transfer_sre, lowest_level_sre, issuing_bin, transaction_key)
);

CREATE TABLE IF NOT EXISTS sms_rpt_order_by_rrn(
    subscriber_id text,
    affiliate_bin text,
    vss_processor text,
    window_id text,
    cpd text,
    acquiring_bin text,
    card_number text,
    issuing_bin text,
    retrieval_reference_number text,
    transmission_date_and_time text,
    transaction_key text,
    fund_transfer_sre text,
    lowest_level_sre text,
    version text,
    data_subset blob,
    PRIMARY KEY ((subscriber_id, affiliate_bin, vss_processor,  window_id, cpd), fund_transfer_sre, lowest_level_sre, retrieval_reference_number, transaction_key)
);

CREATE TABLE IF NOT EXISTS sms_rpt_order_by_card(
    subscriber_id text,
    affiliate_bin text,
    vss_processor text,
    window_id text,
    cpd text,
    acquiring_bin text,
    card_number text,
    issuing_bin text,
    retrieval_reference_number text,
    transmission_date_and_time text,
    transaction_key text,
    fund_transfer_sre text,
    lowest_level_sre text,
    version text,
    data_subset blob,
    PRIMARY KEY ((subscriber_id, affiliate_bin, vss_processor,  window_id, cpd), fund_transfer_sre, lowest_level_sre, card_number, transaction_key)
);

CREATE TABLE IF NOT EXISTS sms_rpt_order_by_trantm(
    subscriber_id text,
    affiliate_bin text,
    vss_processor text,
    window_id text,
    cpd text,
    acquiring_bin text,
    card_number text,
    issuing_bin text,
    retrieval_reference_number text,
    transmission_date_and_time text,
    transaction_key text,
    fund_transfer_sre text,
    lowest_level_sre text,
    version text,
    data_subset blob,
    PRIMARY KEY ((subscriber_id, affiliate_bin, vss_processor,  window_id, cpd), fund_transfer_sre, lowest_level_sre, transmission_date_and_time, transaction_key)
);

DESCRIBE TABLES;
