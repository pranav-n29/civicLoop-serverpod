BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "civic_user_role" ADD COLUMN "employeeId" text;
ALTER TABLE "civic_user_role" ADD COLUMN "approvalStatus" text;

--
-- MIGRATION VERSION FOR civicloop
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('civicloop', '20261017132834431-add-employee-approval-status', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261017132834431-add-employee-approval-status', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
