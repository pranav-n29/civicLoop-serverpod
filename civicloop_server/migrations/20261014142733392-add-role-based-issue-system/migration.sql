BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "civic_issue" ADD COLUMN "priority" text;
ALTER TABLE "civic_issue" ADD COLUMN "department" text;
ALTER TABLE "civic_issue" ADD COLUMN "assignedEmployeeId" text;
ALTER TABLE "civic_issue" ADD COLUMN "assignedEmployeeName" text;
ALTER TABLE "civic_issue" ADD COLUMN "assignedAt" timestamp without time zone;
ALTER TABLE "civic_issue" ADD COLUMN "dueDate" timestamp without time zone;
ALTER TABLE "civic_issue" ADD COLUMN "progressNotes" text;
ALTER TABLE "civic_issue" ADD COLUMN "completionNotes" text;
ALTER TABLE "civic_issue" ADD COLUMN "completionPhotoPath" text;
ALTER TABLE "civic_issue" ADD COLUMN "resolvedAt" timestamp without time zone;
ALTER TABLE "civic_issue" ADD COLUMN "closedAt" timestamp without time zone;
ALTER TABLE "civic_issue" ADD COLUMN "reopenedAt" timestamp without time zone;
ALTER TABLE "civic_issue" ADD COLUMN "reopenReason" text;
ALTER TABLE "civic_issue" ADD COLUMN "rejectionReason" text;
ALTER TABLE "civic_issue" ADD COLUMN "rejectedAt" timestamp without time zone;
ALTER TABLE "civic_issue" ADD COLUMN "claimHash" text;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "civic_issue_audit" (
    "id" bigserial PRIMARY KEY,
    "issueId" bigint NOT NULL,
    "actorId" text NOT NULL,
    "actorRole" text NOT NULL,
    "actorName" text,
    "action" text NOT NULL,
    "previousStatus" text,
    "newStatus" text,
    "notes" text,
    "timestamp" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "civic_issue_audit_issue_id_idx" ON "civic_issue_audit" USING btree ("issueId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "civic_notification" (
    "id" bigserial PRIMARY KEY,
    "recipientId" text NOT NULL,
    "issueId" bigint NOT NULL,
    "type" text NOT NULL,
    "title" text NOT NULL,
    "message" text NOT NULL,
    "isRead" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "readAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "civic_notification_recipient_id_idx" ON "civic_notification" USING btree ("recipientId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "civic_user_role" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "email" text,
    "fullName" text,
    "role" text NOT NULL,
    "department" text,
    "isActive" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "civic_user_role_user_id_unique_idx" ON "civic_user_role" USING btree ("userId");


--
-- MIGRATION VERSION FOR civicloop
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('civicloop', '20261014142733392-add-role-based-issue-system', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261014142733392-add-role-based-issue-system', "timestamp" = now();

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
