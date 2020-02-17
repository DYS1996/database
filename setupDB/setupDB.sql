CREATE DATABASE blog TEMPLATE template0;
\c blog;

BEGIN;
CREATE SCHEMA IF NOT EXISTS pgTAP;
CREATE EXTENSION IF NOT EXISTS pgtap SCHEMA pgTAP;
CREATE USER blogdba WITH PASSWORD 'SCRAM-SHA-256$4096:ajdlkasnclnlk13lo4jo12j40j';
CREATE USER blogdbu WITH PASSWORD 'SCRAM-SHA-256$4096:lk1nl11321546';

REVOKE CONNECT,CREATE,TEMPORARY ON DATABASE blog FROM public;
GRANT CONNECT,CREATE,TEMPORARY ON DATABASE blog TO blogdba;
GRANT CONNECT,TEMPORARY ON DATABASE blog TO blogdbu;

REVOKE CREATE,USAGE ON SCHEMA public FROM public;
GRANT CREATE,USAGE ON SCHEMA public TO blogdba;
GRANT USAGE ON SCHEMA public to blogdbu;

COMMIT;