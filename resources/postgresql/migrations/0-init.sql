

CREATE TABLE requests(
identifier UUID NOT NULL,
client_identifier UUID NOT NULL REFERENCES clients(identifier),
slot_start TIMESTAMPTZ NOT NULL,
slot_end TIMESTAMPTZ NOT NULL,
activity_identifier UUID NOT NULL REFERENCES activities(identifier),
created_at TIMESTAMPTZ NOT NULL,
UNIQUE(identifier),
PRIMARY KEY (identifier)
);

CREATE TABLE activities(
identifier UUID NOT NULL,
display_name VARCHAR(1024) NOT NULL,
description VARCHAR NOT NULL,
created_at TIMESTAMPTZ NOT NULL,
timeslot_gen_mode VARCHAR NOT NULL,
timeslot_gen_expr VARCHAR NOT NULL
);

CREATE TABLE clients(
identifier UUID NOT NULL,
display_name VARCHAR(1024) NOT NULL,
phone_number VARCHAR(512) NOT NULL,
email_address VARCHAR(1024) NOT NULL,
UNIQUE(identifier),
PRIMARY KEY (identifier)
);

CREATE TABLE reservations(
identifier UUID NOT NULL,
client_identifier UUID NOT NULL REFERENCES clients(identifier),
slot_start TIMESTAMPTZ NOT NULL,
slot_end TIMESTAMPTZ NOT NULL,
payment_identifier UUID NULL REFERENCES payments(identifier),
activity_identifier UUID NOT NULL REFERENCES activities(identifier),
created_at TIMESTAMPTZ NOT NULL,
UNIQUE(identifier),
PRIMARY KEY (identifier)
);

CREATE TABLE payments(
identifier UUID NOT NULL,
created_at TIMESTAMPTZ NOT NULL,
payment_amount DECIMAL(12,4) NOT NULL,
currency VARCHAR(100) NOT NULL,
payment_status VARCHAR NOT NULL,
UNIQUE(identifier),
PRIMARY KEY (identifier)
);

CREATE TABLE managers(
identifier UUID NOT NULL,
display_name VARCHAR(1024) NOT NULL,
email_address VARCHAR NOT NULL,
password_hash VARCHAR NOT NULL,
password_reset_token VARCHAR NULL,
created_at TIMESTAMPTZ NOT NULL,
UNIQUE(identifier),
PRIMARY KEY (identifier)
);


CREATE TABLE offline_ranges (
identifier UUID NOT NULL,
slot_start TIMESTAMPTZ NOT NULL,
slot_end TIMESTAMPTZ NOT NULL,
created_at TIMESTAMPTZ NOT NULL,
activity_identifier UUID NOT NULL REFERENCES activities(identifier),
UNIQUE(identifier),
PRIMARY KEY (identifier)
);

CREATE TABLE activities_managers (
identifier UUID NOT NULL,
created_at TIMESTAMPTZ NOT NULL,
activity_identifier UUID NOT NULL REFERENCES activities(identifier),
manager_identifier UUID NOT NULL REFERENCES managers(identifier),
UNIQUE(activity_identifier, manager_identifier),
UNIQUE(identifier),
PRIMARY KEY (identifier)
);
