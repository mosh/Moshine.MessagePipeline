CREATE TABLE IF NOT EXISTS outbox
(
    id uuid NOT NULL,
    dispatched boolean NOT NULL DEFAULT false,
    dispatched_at timestamp with time zone,
    CONSTRAINT outbox_pkey PRIMARY KEY (id)
);
