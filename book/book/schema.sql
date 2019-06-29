-- migrate:up

CREATE TYPE entity AS ENUM ('VEHICLE', 'PERSON');
CREATE TYPE document_entity AS ENUM ('VEHICLE', 'DRIVER', 'OWNER', 'OPERATOR', 'HELPER', 'ESCORT');
CREATE TYPE b2b_document_entity AS ENUM ('DRIVER', 'OPERATOR', 'ESCORT', 'CAB', 'BUS');
CREATE TYPE b2b_document_status AS ENUM ('REJECTED', 'VERIFIED', 'ACCEPTED', 'PENDING', 'EXPIRING', 'UNVERIFIED');
CREATE TYPE payment_cycle AS ENUM ('WEEK', 'FORTNIGHT', 'MONTH');
CREATE TYPE account_type AS ENUM ('CURRENT', 'SAVING');
CREATE TYPE document_status AS ENUM ('READY_FOR_REVIEW', 'REVIEWED_UNVERIFIED', 'VERIFIED');
CREATE TYPE validation_type AS ENUM ('ANY', 'ALL', 'ONE');
CREATE TYPE business_model AS ENUM ('B2B', 'B2C');
CREATE TYPE commercial_type AS ENUM ('REVENUE_SHARE', 'MINIMUM_GUARANTEE', 'PAY_PER_RIDE');
CREATE TYPE file_status AS ENUM ('IMPROPER_DOCUMENT_SCAN', 'INCORRECT_DOCUMENT', 'VERIFIED', 'UNVERIFIED');
CREATE TYPE person_role AS ENUM ('OPERATOR', 'HELPER', 'DRIVER', 'OWNER', 'ESCORT');
CREATE TYPE vehicle_onboarding_status AS ENUM ('ACTIVE', 'SERVING_NOTICE', 'TEMPORARY_ACTIVE', 'BLACKLISTED', 'DORMANT', 'LEAD', 'ACTIVE_OUTSIDE', 'DEBOARDED', 'REVIEW_PASSED', 'REVIEW_FAILED', 'REVIEW_REQUESTED');
CREATE TYPE person_onboarding_status AS ENUM ('ACTIVE', 'FAILED_IN_TRAINING', 'TEMPORARY_ACTIVE', 'BLACKLISTED', 'DORMANT', 'LEAD', 'ACTIVE_OUTSIDE', 'DEBOARDED', 'REVIEW_PASSED', 'REVIEW_FAILED', 'REVIEW_REQUESTED');
CREATE TYPE document_category AS ENUM ('BANK_DETAILS_DOCUMENT', 'PAN_CARD', 'COMPANY_PAN_CARD', 'ADDRESS_PROOF_DOCUMENT', 'FINANCIAL_DOCUMENT', 'OPERATIONAL_DOCUMENT', 'POLLUTION_CERTIFICATE', 'SHUTTL_DOCUMENT', 'OPERATOR_AGREEMENT', 'PERMIT_DOCUMENT', 'COMMERCIAL_DOCUMENT');
CREATE TYPE operator_agreement AS ENUM ('SIGNED_BY_BOTH_PARTIES', 'UNSIGNED_BY_SHUTTL', 'UNSIGNED_BY_BOTH_PARTIES', 'UNSIGNED_BY_OPERATOR');
CREATE TYPE inventory_type AS ENUM ('SPARE_OPEN', 'REGULAR', 'BUFFER_INVENTORY', 'SPARE_SAME_VENDOR');
CREATE TYPE seating_configuration AS ENUM ('S2X2', 'S2X3', 'S1X2', 'S1X1');
CREATE TYPE vehicle_class_type AS ENUM ('STANDARD', 'MAHARAJA', 'HIGHBACK', 'PUSHBACK');
CREATE TYPE vehicle_business_model_type AS ENUM ('B2B', 'B2BC', 'RENTALS', 'B2C');
CREATE TYPE deboarding_reason AS ENUM ('VEHICLE_SOLD', 'OTHERS_DEBOARDING_REASON', 'DRIVER_BEHAVIOUR', 'CHANGE_IN_SEATING_CAPACITY', 'SERVICE_FAILURE', 'OTHER_STATE_VEHICLE_EXCEPT_HR', 'ROUTE_CHANGE', 'FOUND_SOME_OTHER_WORK', 'DRIVER_NOT_AVAILABLE', 'PAYMENT_ISSUE', 'MECHANICAL_FAULT', 'VEHICLE_STOLEN', 'BUS_INFRA', 'TIMING_CHANGE', 'ROUTE_CLOSURE', 'LONG_ABSENTEEISM', 'LESS_BOOKING_NOT_PROFITABLE', 'OPERATOR_BEHAVIOUR');
CREATE TYPE deboarding_initiated_by AS ENUM ('BY_SHUTTL', 'BY_OPERATOR');
CREATE TYPE gps_device AS ENUM ('LOCONAV', 'INTELLICAR', 'DYNAKODE', 'RILAPP');

--
-- Description
-- This sequence holds next cid value for drivers
--
CREATE SEQUENCE public.cid_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Description
-- This sequence holds next oid value for drivers
--
CREATE SEQUENCE public.oid_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Description
-- This table holds address for any entity in Supply system
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: addresses_audit
--
CREATE TABLE public.addresses (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    state_id uuid,
    district_id uuid,
    pincode character varying(10),
    formatted_address character varying(255)
);



CREATE TABLE public.addresses_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    state_id uuid,
    district_id uuid,
    pincode character varying(10),
    formatted_address character varying(255),
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);

--
-- Description
-- Maintains the track of the reminders sent to the Operators with the relevant details
--
-- Is the source of truth: Yes
-- Is mutable: No
-- Has audit table: No
--
CREATE TABLE public.compliance_reminder_job_tracker (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    operator_id uuid,
    vehicle_id uuid,
    driver_id uuid,
    escort_id uuid,
    last_reminder_sent_at timestamp without time zone,
    document_status b2b_document_status NOT NULL,
    partner_site_id character varying(255) NOT NULL,
    document_type_id uuid NOT NULL,
    is_success boolean NOT NULL default FALSE
);

--
-- Description
-- This is a meta data table where we have stored the complete list of Districts that can be used as a drop-down in addresses
-- so that the data sanctity can be maintained.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: districts_audit
--
CREATE TABLE public.districts (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    district_name character varying(255) NOT NULL,
    state_id uuid NOT NULL
);


CREATE TABLE public.districts_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    district_name character varying(255),
    state_id uuid,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- List of all the documents that are mandatory in order to activate a Entity in B2C. This is a potential Merging candidate
-- with partner mandatory documents table for B2B.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: entity_mandatory_documents_audit
--
CREATE TABLE public.entity_mandatory_documents (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    entity document_entity NOT NULL,
    validation_type validation_type not null,
    document_category document_category not null
);




CREATE TABLE public.entity_mandatory_documents_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    entity document_entity,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL,
    validation_type validation_type,
    document_category document_category
);


--
-- Description
--- Maintains the verification status of a document for a partner with comments from B2B Admin.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: partners_document_verification_audit
--
CREATE TABLE public.partners_document_verification (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    document_id uuid NOT NULL,
    partner_site_id character varying(255) NOT NULL,
    status b2b_document_status,
    entity_type entity NOT NULL,
    issue_type character varying(255),
    issue_comment character varying(255)
);


CREATE TABLE public.partners_document_verification_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    document_id uuid,
    partner_site_id character varying(255),
    status b2b_document_status,
    entity_type entity,
    issue_type character varying(255),
    issue_comment character varying(255),
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);

--
-- Description
-- This is a static List Types of Document like a PAN or DL that is shown as a drop-down in the UI.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: document_types_audit
--
CREATE TABLE public.document_types (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    document_type_name character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    document_fields json,
    document_category document_category not null,
    entity entity
);


CREATE TABLE public.document_types_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    document_type_name character varying(255),
    code character varying(255),
    document_fields json,
    entity entity,
    document_category document_category,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Driver to Partner Mapping where Partner is a B2B Partner.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: driver_partners_audit
--
CREATE TABLE public.driver_partners (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    driver_person_role_id uuid NOT NULL,
    partner_site_id character varying(255) NOT NULL
);


CREATE TABLE public.driver_partners_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    driver_person_role_id uuid,
    partner_site_id character varying(255),
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Stores Driver Details specifically characterising a Person Instance whose role is Driver.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: drivers_audit
--
CREATE TABLE public.drivers (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    person_role_id uuid NOT NULL,
    operator_person_role_id uuid NOT NULL,
    cid character varying(255),
    is_trained boolean DEFAULT false
);


CREATE TABLE public.drivers_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    person_role_id uuid,
    operator_person_role_id uuid,
    cid character varying(255),
    is_trained boolean,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);

--
-- Description
-- Stores Escort Details specifically characterising a Person Instance whose role is Escort.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: escorts_audit
--
CREATE TABLE public.escorts (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    person_role_id uuid NOT NULL,
    operator_person_role_id uuid NOT NULL,
    languages json
);


CREATE TABLE public.escorts_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    person_role_id uuid,
    operator_person_role_id uuid,
    languages json,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Escort B2B Partner Mapping
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: escorts_partners_audit
--
CREATE TABLE public.escorts_partners (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    escort_person_role_id uuid NOT NULL,
    partner_site_id character varying(255) NOT NULL
);


CREATE TABLE public.escorts_partners_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    escort_person_role_id uuid,
    partner_site_id character varying(255),
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Stores Operator Details specifying characterising a Person Instance whose role is Operator.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: driver_partners_audit
--
CREATE TABLE public.operators (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    person_role_id uuid NOT NULL,
    agreement_status operator_agreement,
    oid character varying(255) not null
);


CREATE TABLE public.operators_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    person_role_id uuid,
    agreement_status operator_agreement,
    oid character varying(255),
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- List of Documents that are mandatory for a Partner in B2B
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: partner_mandatory_documents_audit
--
CREATE TABLE public.partner_mandatory_documents (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    entity_type b2b_document_entity NOT NULL,
    document_type_id uuid NOT NULL,
    partner_site_id character varying(255) NOT NULL
);


CREATE TABLE public.partner_mandatory_documents_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    entity_type b2b_document_entity,
    document_type_id uuid,
    partner_site_id character varying(255),
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- This is a mapping table between documents uploaded for a person
-- with details of the document like URL, expiry and numbers.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: person_documents_audit
--
CREATE TABLE public.person_documents (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    person_id uuid NOT NULL,
    document_subtype_id uuid,
    document_type_id uuid not null,
    document_value json,
    document_url json,
    document_status document_status,
    file_status file_status
);


CREATE TABLE public.person_documents_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    person_id uuid NOT NULL,
    document_subtype_id uuid,
    document_type_id uuid not null,
    document_value json,
    document_url json,
    document_status document_status,
    file_status file_status,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- This stores the role of a particular person. For example a Person in
-- our system can be a Operator or a Driver or both.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: person_roles_audit
--
CREATE TABLE public.person_roles (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    person_id uuid NOT NULL,
    status person_onboarding_status NOT NULL,
    role person_role NOT NULL
);


CREATE TABLE public.person_roles_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    person_id uuid,
    status person_onboarding_status,
    role person_role,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Base table where a person can be created without any role.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: persons_audit
--
CREATE TABLE public.persons (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    person_name character varying(255) NOT NULL,
    mobile_number character varying(15) NOT NULL
);


CREATE TABLE public.persons_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    person_name character varying(255),
    mobile_number character varying(15),
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Driver to Partner Mapping where Partner is a B2B Partner.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: persons_details_audit
--
CREATE TABLE public.persons_details (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    email character varying(255),
    alternate_mobile_number character varying(15),
    current_address_id uuid,
    permanent_address_id uuid,
    description character varying(255),
    shirt_size character varying(255),
    trouser_size character varying(255),
    person_id uuid NOT NULL
);


CREATE TABLE public.persons_details_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    email character varying(255),
    alternate_mobile_number character varying(15),
    current_address_id uuid,
    permanent_address_id uuid,
    description character varying(255),
    shirt_size character varying(255),
    trouser_size character varying(255),
    person_id uuid,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);

--
-- Description
-- Meta Data table for storing the allowed States so that while it can be a selection list in address.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: states_audit
--
CREATE TABLE public.states (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    state_name character varying(255) NOT NULL,
    gst_code character varying(255) NOT NULL,
    state_code character varying(255) NOT NULL
);


CREATE TABLE public.states_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    state_name character varying(255),
    gst_code character varying(255),
    state_code character varying(255),
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Stores the allowed Status Transition flows for Vehicles
-- and Persons which can be extended to become role specific.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: status_flow_audit
--
CREATE TABLE public.status_flow (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    status character varying(25),
    next_status character varying(25) NOT NULL,
    entity entity NOT NULL
);


CREATE TABLE public.status_flow_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    status character varying(25),
    next_status character varying(25),
    entity entity,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- List of allowed type of a document. For Example a DL can be of type LMV or HMV etc.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: document_subtypes_audit
--
CREATE TABLE public.document_subtypes (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    document_subtype_name character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    document_type_id uuid NOT NULL
);


CREATE TABLE public.document_subtypes_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    document_subtype_name character varying(255),
    code character varying(255),
    document_type_id uuid,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Internal table used by Audit Lib.
--
-- Is the source of truth: Yes
-- Is mutable: No
-- Has audit table: No
--
CREATE TABLE public.transaction (
    issued_at timestamp without time zone,
    id bigint NOT NULL,
    remote_addr character varying(50)
);


CREATE SEQUENCE public.transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE public.transaction_id_seq OWNED BY public.transaction.id;

--
-- Description
-- This is the list of details of all the vehicle Manufacturer that we allow.
-- This table had lot of duplicates and needs cleaning which will be done post
-- version 1 deployment and then the Unique Constraint for Model and Manufacturer will be enabled.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: vehicle_company_details_audit
--
CREATE TABLE public.vehicle_company_details (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    model character varying(255) NOT NULL,
    manufacturer character varying(255) NOT NULL
);


CREATE TABLE public.vehicle_company_details_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    model character varying(255),
    manufacturer character varying(255),
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Details of the vehicle
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: vehicle_details_audit
--
CREATE TABLE public.vehicle_details (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    vehicle_id uuid NOT NULL,
    display_name character varying(255),
    registration_year integer,
    engine_number character varying(255),
    ncr_number character varying(255),
    seating_configuration seating_configuration,
    onboarding_date timestamp without time zone,
    deboarding_date timestamp without time zone,
    is_ac boolean,
    is_available_for_slot_failure boolean,
    preferred_plying_region character varying(255),
    letter_of_intent_number character varying(255),
    description text,
    inventory_type inventory_type,
    business_model vehicle_business_model_type,
    vehicle_class_type vehicle_class_type,
    state_id uuid,
    district_id uuid,
    location geometry(Point),
    day_session integer not null
);


CREATE TABLE public.vehicle_details_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    vehicle_id uuid,
    display_name character varying(255),
    registration_year integer,
    engine_number character varying(255),
    ncr_number character varying(255),
    seating_configuration seating_configuration,
    onboarding_date timestamp without time zone,
    deboarding_date timestamp without time zone,
    is_ac boolean,
    is_available_for_slot_failure boolean,
    preferred_plying_region character varying(255),
    letter_of_intent_number character varying(255),
    description text,
    inventory_type inventory_type,
    business_model vehicle_business_model_type,
    vehicle_class_type vehicle_class_type,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL,
    state_id uuid,
    district_id uuid,
    location geometry(Point),
    day_session integer not null
);


--
-- Description
-- Contains the details of the documents per vehicle
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: driver_partners_audit
--
CREATE TABLE public.vehicle_documents (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    vehicle_id uuid NOT NULL,
    document_subtype_id uuid,
    document_type_id uuid not null,
    document_value json,
    document_url json,
    document_status document_status,
    file_status file_status
);


CREATE TABLE public.vehicle_documents_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    vehicle_id uuid NOT NULL,
    document_subtype_id uuid,
    document_type_id uuid not null,
    document_value json,
    document_url json,
    document_status document_status,
    file_status file_status,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Details of GPS devices that are fitted on the vehicle.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: vehicle_gps_devices_audit
--
CREATE TABLE public.vehicle_gps_devices (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    vehicle_id uuid NOT NULL,
    gps_device_imei character varying(255) NOT NULL,
    gps_device gps_device NOT NULL
);

CREATE TABLE public.vehicle_gps_devices_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    vehicle_id uuid,
    gps_device_imei character varying(255),
    gps_device gps_device,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Vehicle to B2B Partner Mapping.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: vehicle_partner_audit
--
CREATE TABLE public.vehicle_partner (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    vehicle_id uuid NOT NULL,
    partner_site_id character varying(255) NOT NULL
);


CREATE TABLE public.vehicle_partner_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    vehicle_id uuid,
    partner_site_id character varying(255),
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Vehicle to Person mapping one vehicle could be mapped to many persons.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: vehicle_persons_audit
--
CREATE TABLE public.vehicle_persons (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    vehicle_id uuid NOT NULL,
    person_role_id uuid NOT NULL
);


CREATE TABLE public.vehicle_persons_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    vehicle_id uuid,
    person_role_id uuid,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Information of the Vehicle
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: vehicles_audit
--
CREATE TABLE public.vehicles (
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_by character varying NOT NULL,
    modified_by character varying,
    registration_number character varying(255) NOT NULL,
    passenger_seating_capacity integer NOT NULL,
    status vehicle_onboarding_status,
    deboarding_initiated_by deboarding_initiated_by,
    deboarding_reason deboarding_reason
);


CREATE TABLE public.vehicles_audit (
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    registration_number character varying(255),
    passenger_seating_capacity integer,
    status vehicle_onboarding_status,
    deboarding_initiated_by deboarding_initiated_by,
    deboarding_reason deboarding_reason,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);

--
-- Description
-- Vehicle commercial details for Example vehicle can be a MG or RevShare or PayPerRide.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: vehicle_commercials
--
CREATE TABLE public.vehicle_commercials_audit(
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    vehicle_id uuid NOT NULL,
    business_model_type business_model NOT NULL,
    commercial_type commercial_type NOT NULL,
    commercial_params json,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    payment_cycle payment_cycle NOT NULL,
    is_dead_payable boolean,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


CREATE TABLE public.vehicle_commercials(
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying NOT NULL,
    modified_by character varying,
    vehicle_id uuid NOT NULL,
    business_model_type business_model NOT NULL,
    commercial_type commercial_type NOT NULL,
    commercial_params json,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    payment_cycle payment_cycle NOT NULL,
    is_dead_payable boolean
);


--
-- Description
-- Meta Data table for storing the allowed banks so that while it can be a selection list in bank documents.
--
-- Is the source of truth: Yes
-- Is mutable: Yes
-- Has audit table: banks_audit
--
CREATE TABLE public.banks(
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying NOT NULL,
    modified_by character varying,
    bank_name character varying UNIQUE
);

CREATE TABLE public.banks_audit(
    audit_id SERIAL PRIMARY KEY,
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    bank_name character varying UNIQUE,
    transaction_id bigint NOT NULL,
    end_transaction_id bigint,
    operation_type smallint NOT NULL
);


--
-- Description
-- Table to store the Entity wise verification comments.
--
-- Is the source of truth: Yes
-- Is mutable: No
-- Has audit table: No
--
CREATE TABLE public.verification_comments(
    id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying,
    modified_by character varying,
    person_id uuid,
    vehicle_id uuid,
    comment text
);


ALTER TABLE ONLY public.verification_comments
    ADD CONSTRAINT verification_comments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.transaction ALTER COLUMN id SET DEFAULT nextval('public.transaction_id_seq'::regclass);


ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.compliance_reminder_job_tracker
    ADD CONSTRAINT compliance_reminder_job_tracker_driver_id_key UNIQUE (driver_id);


ALTER TABLE ONLY public.compliance_reminder_job_tracker
    ADD CONSTRAINT compliance_reminder_job_tracker_escort_id_key UNIQUE (escort_id);


ALTER TABLE ONLY public.compliance_reminder_job_tracker
    ADD CONSTRAINT compliance_reminder_job_tracker_operator_id_key UNIQUE (operator_id);


ALTER TABLE ONLY public.compliance_reminder_job_tracker
    ADD CONSTRAINT compliance_reminder_job_tracker_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.entity_mandatory_documents
    ADD CONSTRAINT entity_mandatory_documents_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.partners_document_verification
    ADD CONSTRAINT partners_document_verification_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.document_types
    ADD CONSTRAINT document_types_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.driver_partners
    ADD CONSTRAINT driver_partner_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_person_role_id_key UNIQUE (person_role_id);


ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.escorts_partners
    ADD CONSTRAINT escorts_partner_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.escorts
    ADD CONSTRAINT escorts_person_role_id_key UNIQUE (person_role_id);


ALTER TABLE ONLY public.escorts
    ADD CONSTRAINT escorts_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.operators
    ADD CONSTRAINT operators_person_role_id_key UNIQUE (person_role_id);


ALTER TABLE ONLY public.operators
    ADD CONSTRAINT operators_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.partner_mandatory_documents
    ADD CONSTRAINT partner_mandatory_documents_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.person_documents
    ADD CONSTRAINT person_documents_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.person_roles
    ADD CONSTRAINT person_roles_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.persons_details
    ADD CONSTRAINT persons_details_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.persons
    ADD CONSTRAINT persons_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.status_flow
    ADD CONSTRAINT status_flow_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.document_subtypes
    ADD CONSTRAINT document_subtypes_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.vehicle_company_details
    ADD CONSTRAINT vehicle_company_details_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.vehicle_details
    ADD CONSTRAINT vehicle_details_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.vehicle_documents
    ADD CONSTRAINT vehicle_documents_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.vehicle_gps_devices
    ADD CONSTRAINT vehicle_gps_device_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.vehicle_partner
    ADD CONSTRAINT vehicle_partner_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.vehicle_persons
    ADD CONSTRAINT vehicle_person_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


CREATE INDEX ix_addresses_audit_end_transaction_id ON public.addresses_audit USING btree (end_transaction_id);


CREATE INDEX ix_addresses_audit_operation_type ON public.addresses_audit USING btree (operation_type);


CREATE INDEX ix_addresses_audit_transaction_id ON public.addresses_audit USING btree (transaction_id);


CREATE INDEX ix_districts_audit_end_transaction_id ON public.districts_audit USING btree (end_transaction_id);


CREATE INDEX ix_districts_audit_operation_type ON public.districts_audit USING btree (operation_type);


CREATE INDEX ix_districts_audit_transaction_id ON public.districts_audit USING btree (transaction_id);


CREATE INDEX ix_entity_mandatory_documents_audit_end_transaction_id ON public.entity_mandatory_documents_audit USING btree (end_transaction_id);


CREATE INDEX ix_entity_mandatory_documents_audit_operation_type ON public.entity_mandatory_documents_audit USING btree (operation_type);


CREATE INDEX ix_entity_mandatory_documents_audit_transaction_id ON public.entity_mandatory_documents_audit USING btree (transaction_id);


CREATE INDEX ix_partners_document_verification_audit_end_transaction_id ON public.partners_document_verification_audit USING btree (end_transaction_id);


CREATE INDEX ix_partners_document_verification_audit_operation_type ON public.partners_document_verification_audit USING btree (operation_type);


CREATE INDEX ix_partners_document_verification_audit_transaction_id ON public.partners_document_verification_audit USING btree (transaction_id);


CREATE INDEX ix_document_types_audit_end_transaction_id ON public.document_types_audit USING btree (end_transaction_id);


CREATE INDEX ix_document_types_audit_operation_type ON public.document_types_audit USING btree (operation_type);


CREATE INDEX ix_document_types_audit_transaction_id ON public.document_types_audit USING btree (transaction_id);


CREATE INDEX ix_driver_partner_audit_end_transaction_id ON public.driver_partners_audit USING btree (end_transaction_id);


CREATE INDEX ix_driver_partner_audit_operation_type ON public.driver_partners_audit USING btree (operation_type);


CREATE INDEX ix_driver_partner_audit_transaction_id ON public.driver_partners_audit USING btree (transaction_id);


CREATE INDEX ix_drivers_audit_end_transaction_id ON public.drivers_audit USING btree (end_transaction_id);


CREATE INDEX ix_drivers_audit_operation_type ON public.drivers_audit USING btree (operation_type);


CREATE INDEX ix_drivers_audit_transaction_id ON public.drivers_audit USING btree (transaction_id);


CREATE INDEX ix_escorts_partner_audit_end_transaction_id ON public.escorts_partners_audit USING btree (end_transaction_id);


CREATE INDEX ix_escorts_partner_audit_operation_type ON public.escorts_partners_audit USING btree (operation_type);


CREATE INDEX ix_escorts_partner_audit_transaction_id ON public.escorts_partners_audit USING btree (transaction_id);


CREATE INDEX ix_escorts_audit_end_transaction_id ON public.escorts_audit USING btree (end_transaction_id);


CREATE INDEX ix_escorts_audit_operation_type ON public.escorts_audit USING btree (operation_type);


CREATE INDEX ix_escorts_audit_transaction_id ON public.escorts_audit USING btree (transaction_id);


CREATE INDEX ix_operators_audit_end_transaction_id ON public.operators_audit USING btree (end_transaction_id);


CREATE INDEX ix_operators_audit_operation_type ON public.operators_audit USING btree (operation_type);


CREATE INDEX ix_operators_audit_transaction_id ON public.operators_audit USING btree (transaction_id);


CREATE INDEX ix_partner_mandatory_documents_audit_end_transaction_id ON public.partner_mandatory_documents_audit USING btree (end_transaction_id);


CREATE INDEX ix_partner_mandatory_documents_audit_operation_type ON public.partner_mandatory_documents_audit USING btree (operation_type);


CREATE INDEX ix_partner_mandatory_documents_audit_transaction_id ON public.partner_mandatory_documents_audit USING btree (transaction_id);


CREATE INDEX ix_person_documents_audit_end_transaction_id ON public.person_documents_audit USING btree (end_transaction_id);


CREATE INDEX ix_person_documents_audit_operation_type ON public.person_documents_audit USING btree (operation_type);


CREATE INDEX ix_person_documents_audit_transaction_id ON public.person_documents_audit USING btree (transaction_id);


CREATE INDEX ix_person_roles_audit_end_transaction_id ON public.person_roles_audit USING btree (end_transaction_id);


CREATE INDEX ix_person_roles_audit_operation_type ON public.person_roles_audit USING btree (operation_type);


CREATE INDEX ix_person_roles_audit_transaction_id ON public.person_roles_audit USING btree (transaction_id);


CREATE INDEX ix_persons_details_audit_end_transaction_id ON public.persons_details_audit USING btree (end_transaction_id);


CREATE INDEX ix_persons_details_audit_operation_type ON public.persons_details_audit USING btree (operation_type);


CREATE INDEX ix_persons_details_audit_transaction_id ON public.persons_details_audit USING btree (transaction_id);


CREATE INDEX ix_persons_audit_end_transaction_id ON public.persons_audit USING btree (end_transaction_id);


CREATE INDEX ix_persons_audit_operation_type ON public.persons_audit USING btree (operation_type);


CREATE INDEX ix_persons_audit_transaction_id ON public.persons_audit USING btree (transaction_id);


CREATE INDEX ix_states_audit_end_transaction_id ON public.states_audit USING btree (end_transaction_id);


CREATE INDEX ix_states_audit_operation_type ON public.states_audit USING btree (operation_type);


CREATE INDEX ix_states_audit_transaction_id ON public.states_audit USING btree (transaction_id);


CREATE INDEX ix_status_flow_audit_end_transaction_id ON public.status_flow_audit USING btree (end_transaction_id);


CREATE INDEX ix_status_flow_audit_operation_type ON public.status_flow_audit USING btree (operation_type);


CREATE INDEX ix_status_flow_audit_transaction_id ON public.status_flow_audit USING btree (transaction_id);


CREATE INDEX ix_document_subtypes_audit_end_transaction_id ON public.document_subtypes_audit USING btree (end_transaction_id);


CREATE INDEX ix_document_subtypes_audit_operation_type ON public.document_subtypes_audit USING btree (operation_type);


CREATE INDEX ix_document_subtypes_audit_transaction_id ON public.document_subtypes_audit USING btree (transaction_id);


CREATE INDEX ix_vehicle_company_details_audit_end_transaction_id ON public.vehicle_company_details_audit USING btree (end_transaction_id);


CREATE INDEX ix_vehicle_company_details_audit_operation_type ON public.vehicle_company_details_audit USING btree (operation_type);


CREATE INDEX ix_vehicle_company_details_audit_transaction_id ON public.vehicle_company_details_audit USING btree (transaction_id);


CREATE INDEX ix_vehicle_details_audit_end_transaction_id ON public.vehicle_details_audit USING btree (end_transaction_id);


CREATE INDEX ix_vehicle_details_audit_operation_type ON public.vehicle_details_audit USING btree (operation_type);


CREATE INDEX ix_vehicle_details_audit_transaction_id ON public.vehicle_details_audit USING btree (transaction_id);


CREATE INDEX ix_vehicle_documents_audit_end_transaction_id ON public.vehicle_documents_audit USING btree (end_transaction_id);


CREATE INDEX ix_vehicle_documents_audit_operation_type ON public.vehicle_documents_audit USING btree (operation_type);


CREATE INDEX ix_vehicle_documents_audit_transaction_id ON public.vehicle_documents_audit USING btree (transaction_id);


CREATE INDEX ix_vehicle_gps_device_audit_end_transaction_id ON public.vehicle_gps_devices_audit USING btree (end_transaction_id);


CREATE INDEX ix_vehicle_gps_device_audit_operation_type ON public.vehicle_gps_devices_audit USING btree (operation_type);


CREATE INDEX ix_vehicle_gps_device_audit_transaction_id ON public.vehicle_gps_devices_audit USING btree (transaction_id);


CREATE INDEX ix_vehicle_partner_audit_end_transaction_id ON public.vehicle_partner_audit USING btree (end_transaction_id);


CREATE INDEX ix_vehicle_partner_audit_operation_type ON public.vehicle_partner_audit USING btree (operation_type);


CREATE INDEX ix_vehicle_partner_audit_transaction_id ON public.vehicle_partner_audit USING btree (transaction_id);


CREATE INDEX ix_vehicle_person_audit_end_transaction_id ON public.vehicle_persons_audit USING btree (end_transaction_id);


CREATE INDEX ix_vehicle_person_audit_operation_type ON public.vehicle_persons_audit USING btree (operation_type);


CREATE INDEX ix_vehicle_person_audit_transaction_id ON public.vehicle_persons_audit USING btree (transaction_id);


CREATE INDEX ix_vehicles_audit_end_transaction_id ON public.vehicles_audit USING btree (end_transaction_id);


CREATE INDEX ix_vehicles_audit_operation_type ON public.vehicles_audit USING btree (operation_type);


CREATE INDEX ix_vehicles_audit_transaction_id ON public.vehicles_audit USING btree (transaction_id);


ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_district_id_fkey FOREIGN KEY (district_id) REFERENCES public.districts(id);


ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.states(id);


ALTER TABLE ONLY public.compliance_reminder_job_tracker
    ADD CONSTRAINT compliance_reminder_job_tracker_document_type_id_fkey FOREIGN KEY (document_type_id) REFERENCES public.document_types(id);


ALTER TABLE ONLY public.compliance_reminder_job_tracker
    ADD CONSTRAINT compliance_reminder_job_tracker_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.person_roles(id);


ALTER TABLE ONLY public.compliance_reminder_job_tracker
    ADD CONSTRAINT compliance_reminder_job_tracker_escort_id_fkey FOREIGN KEY (escort_id) REFERENCES public.person_roles(id);


ALTER TABLE ONLY public.compliance_reminder_job_tracker
    ADD CONSTRAINT compliance_reminder_job_tracker_operator_id_fkey FOREIGN KEY (operator_id) REFERENCES public.person_roles(id);


ALTER TABLE ONLY public.compliance_reminder_job_tracker
    ADD CONSTRAINT compliance_reminder_job_tracker_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.states(id);


ALTER TABLE ONLY public.driver_partners
    ADD CONSTRAINT driver_partner_driver_person_role_id_fkey FOREIGN KEY (driver_person_role_id) REFERENCES public.person_roles(id);


ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_operator_person_role_id_fkey FOREIGN KEY (operator_person_role_id) REFERENCES public.person_roles(id);


ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_person_role_id_fkey FOREIGN KEY (person_role_id) REFERENCES public.person_roles(id);


ALTER TABLE ONLY public.escorts
    ADD CONSTRAINT escorts_operator_person_role_id_fkey FOREIGN KEY (operator_person_role_id) REFERENCES public.person_roles(id);


ALTER TABLE ONLY public.escorts_partners
    ADD CONSTRAINT escorts_partner_escort_person_role_id_fkey FOREIGN KEY (escort_person_role_id) REFERENCES public.person_roles(id);


ALTER TABLE ONLY public.escorts
    ADD CONSTRAINT escorts_person_role_id_fkey FOREIGN KEY (person_role_id) REFERENCES public.person_roles(id);


ALTER TABLE ONLY public.operators
    ADD CONSTRAINT operators_person_role_id_fkey FOREIGN KEY (person_role_id) REFERENCES public.person_roles(id);


ALTER TABLE ONLY public.partner_mandatory_documents
    ADD CONSTRAINT partner_mandatory_documents_document_type_id_fkey FOREIGN KEY (document_type_id) REFERENCES public.document_types(id);


ALTER TABLE ONLY public.person_documents
    ADD CONSTRAINT person_documents_document_type_id_fkey FOREIGN KEY (document_type_id) REFERENCES public.document_types(id);


ALTER TABLE ONLY public.person_documents
    ADD CONSTRAINT person_documents_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.persons(id);


ALTER TABLE ONLY public.person_documents
    ADD CONSTRAINT person_documents_document_subtype_id_fkey FOREIGN KEY (document_subtype_id) REFERENCES public.document_subtypes(id);


ALTER TABLE ONLY public.person_roles
    ADD CONSTRAINT person_roles_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.persons(id);


ALTER TABLE ONLY public.persons_details
    ADD CONSTRAINT persons_details_current_address_id_fkey FOREIGN KEY (current_address_id) REFERENCES public.addresses(id);


ALTER TABLE ONLY public.persons_details
    ADD CONSTRAINT persons_details_permanent_address_id_fkey FOREIGN KEY (permanent_address_id) REFERENCES public.addresses(id);


ALTER TABLE ONLY public.persons_details
    ADD CONSTRAINT persons_details_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.persons(id);


ALTER TABLE ONLY public.document_subtypes
    ADD CONSTRAINT document_subtypes_document_type_id_fkey FOREIGN KEY (document_type_id) REFERENCES public.document_types(id);

ALTER TABLE ONLY public.vehicle_details
    ADD CONSTRAINT vehicle_details_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);

ALTER TABLE ONLY public.vehicle_documents
    ADD CONSTRAINT vehicle_documents_document_type_id_fkey FOREIGN KEY (document_type_id) REFERENCES public.document_types(id);


ALTER TABLE ONLY public.vehicle_documents
    ADD CONSTRAINT vehicle_documents_document_subtype_id_fkey FOREIGN KEY (document_subtype_id) REFERENCES public.document_subtypes(id);


ALTER TABLE ONLY public.vehicle_documents
    ADD CONSTRAINT vehicle_documents_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


ALTER TABLE ONLY public.vehicle_gps_devices
    ADD CONSTRAINT vehicle_gps_device_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


ALTER TABLE ONLY public.vehicle_partner
    ADD CONSTRAINT vehicle_partner_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


ALTER TABLE ONLY public.vehicle_persons
    ADD CONSTRAINT vehicle_person_person_role_id_fkey FOREIGN KEY (person_role_id) REFERENCES public.person_roles(id);


ALTER TABLE ONLY public.vehicle_persons
    ADD CONSTRAINT vehicle_person_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


ALTER TABLE ONLY public.vehicle_details
    ADD CONSTRAINT fk_state_id FOREIGN KEY (state_id) REFERENCES public.states(id);

ALTER TABLE ONLY public.vehicle_details
   ADD CONSTRAINT fk_district_id FOREIGN KEY (district_id) REFERENCES public.districts(id);


ALTER TABLE ONLY public.vehicle_commercials
    ADD CONSTRAINT vehicle_commercials_pkey PRIMARY KEY (id);


ALTER TABLE ONLY public.vehicle_commercials
    ADD CONSTRAINT vehicle_commercials_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


ALTER TABLE ONLY public.banks
    ADD CONSTRAINT banks_id_pkey PRIMARY KEY (id);


CREATE INDEX ix_banks_audit_end_transaction_id ON public.banks_audit USING btree (end_transaction_id);


CREATE INDEX ix_banks_audit_operation_type ON public.banks_audit USING btree (operation_type);


CREATE INDEX ix_banks_audit_transaction_id ON public.banks_audit USING btree (transaction_id);


CREATE INDEX ix_verification_comments_person_id ON public.verification_comments USING btree (person_id);


CREATE INDEX ix_verification_comments_vehicle_id ON public.verification_comments USING btree (vehicle_id);


CREATE INDEX ix_vehicle_commercials_audit_end_transaction_id ON public.vehicle_commercials_audit USING btree (end_transaction_id);


CREATE INDEX ix_vehicle_commercials_audit_operation_type ON public.vehicle_commercials_audit USING btree (operation_type);


CREATE INDEX ix_vehicle_commercials_audit_transaction_id ON public.vehicle_commercials_audit USING btree (transaction_id);

-- migrate:down
