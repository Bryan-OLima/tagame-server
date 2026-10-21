CREATE TABLE "users" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "email" TEXT NOT NULL,
  "password_hash" TEXT NOT NULL,
  "role" TEXT NOT NULL CHECK ("role" IN ('admin', 'guest')),
  "profile_photo_url" TEXT,
  "is_active" BOOLEAN NOT NULL DEFAULT true CHECK ("is_active" IN (0, 1)),
  "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_login_at" DATETIME,
  "revoked_at" DATETIME
);

CREATE TABLE "devices" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "user_id" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "platform" TEXT NOT NULL CHECK ("platform" IN ('android', 'ios', 'web')),
  "model" TEXT,
  "token_hash" TEXT NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true CHECK ("is_active" IN (0, 1)),
  "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_seen_at" DATETIME,
  "revoked_at" DATETIME,
  CONSTRAINT "devices_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE "pcs" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "hostname" TEXT NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true CHECK ("is_active" IN (0, 1)),
  "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "agents" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "pc_id" TEXT NOT NULL,
  "agent_token_hash" TEXT NOT NULL,
  "version" TEXT,
  "status" TEXT NOT NULL CHECK ("status" IN ('online', 'degraded', 'offline', 'revoked')),
  "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "paired_at" DATETIME,
  "last_heartbeat_at" DATETIME,
  "revoked_at" DATETIME,
  "last_error" TEXT,
  CONSTRAINT "agents_pc_id_fkey" FOREIGN KEY ("pc_id") REFERENCES "pcs" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE "tags" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "token" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true CHECK ("is_active" IN (0, 1)),
  "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "last_used_at" DATETIME
);

CREATE TABLE "games" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "steam_appid" INTEGER NOT NULL,
  "cover_url" TEXT,
  "cover_source" TEXT CHECK ("cover_source" IS NULL OR "cover_source" IN ('manual', 'steam', 'external')),
  "cover_updated_at" DATETIME,
  "executable_name" TEXT,
  "is_active" BOOLEAN NOT NULL DEFAULT true CHECK ("is_active" IN (0, 1)),
  "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "tag_assignments" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tag_id" TEXT NOT NULL,
  "game_id" TEXT NOT NULL,
  "pc_id" TEXT NOT NULL,
  "is_active" BOOLEAN NOT NULL DEFAULT true CHECK ("is_active" IN (0, 1)),
  "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "ended_at" DATETIME,
  CONSTRAINT "tag_assignments_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "tag_assignments_game_id_fkey" FOREIGN KEY ("game_id") REFERENCES "games" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "tag_assignments_pc_id_fkey" FOREIGN KEY ("pc_id") REFERENCES "pcs" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE "game_sessions" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tag_id" TEXT NOT NULL,
  "game_id" TEXT NOT NULL,
  "pc_id" TEXT NOT NULL,
  "device_id" TEXT NOT NULL,
  "steam_appid" INTEGER NOT NULL,
  "status" TEXT NOT NULL CHECK ("status" IN ('starting', 'running', 'stopping', 'stopped', 'error')),
  "started_at" DATETIME,
  "ended_at" DATETIME,
  "last_heartbeat_at" DATETIME,
  "error_message" TEXT,
  CONSTRAINT "game_sessions_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "game_sessions_game_id_fkey" FOREIGN KEY ("game_id") REFERENCES "games" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "game_sessions_pc_id_fkey" FOREIGN KEY ("pc_id") REFERENCES "pcs" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "game_sessions_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "devices" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE "launch_events" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "session_id" TEXT,
  "tag_id" TEXT,
  "game_id" TEXT,
  "pc_id" TEXT,
  "agent_id" TEXT,
  "device_id" TEXT,
  "presented_tag_fingerprint" TEXT,
  "presented_device_fingerprint" TEXT,
  "action" TEXT CHECK ("action" IS NULL OR "action" IN ('start', 'stop')),
  "status" TEXT NOT NULL CHECK ("status" IN ('received', 'validated', 'dispatched', 'agent_acknowledged', 'launch_requested', 'stop_requested', 'completed', 'rejected', 'error', 'timeout')),
  "result" TEXT CHECK ("result" IS NULL OR "result" IN ('success', 'rejected', 'error', 'timeout')),
  "error_message" TEXT,
  "source_ip" TEXT,
  "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "validated_at" DATETIME,
  "dispatched_at" DATETIME,
  "agent_acknowledged_at" DATETIME,
  "action_requested_at" DATETIME,
  "completed_at" DATETIME,
  CONSTRAINT "launch_events_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "game_sessions" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "launch_events_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "tags" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "launch_events_game_id_fkey" FOREIGN KEY ("game_id") REFERENCES "games" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "launch_events_pc_id_fkey" FOREIGN KEY ("pc_id") REFERENCES "pcs" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "launch_events_agent_id_fkey" FOREIGN KEY ("agent_id") REFERENCES "agents" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT "launch_events_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "devices" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE "audit_logs" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "user_id" TEXT NOT NULL,
  "action" TEXT NOT NULL,
  "entity_type" TEXT NOT NULL,
  "entity_id" TEXT NOT NULL,
  "details" TEXT NOT NULL,
  "created_at" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE UNIQUE INDEX "users_email_key" ON "users" ("email");
CREATE UNIQUE INDEX "devices_token_hash_key" ON "devices" ("token_hash");
CREATE UNIQUE INDEX "agents_agent_token_hash_key" ON "agents" ("agent_token_hash");
CREATE UNIQUE INDEX "tags_token_key" ON "tags" ("token");
CREATE UNIQUE INDEX "games_steam_appid_key" ON "games" ("steam_appid");
CREATE UNIQUE INDEX "tag_assignments_one_active_tag" ON "tag_assignments" ("tag_id") WHERE "is_active" = true;
CREATE UNIQUE INDEX "agents_one_active_pc" ON "agents" ("pc_id") WHERE "revoked_at" IS NULL;
CREATE INDEX "devices_user_id_idx" ON "devices" ("user_id");
CREATE INDEX "agents_pc_id_idx" ON "agents" ("pc_id");
CREATE INDEX "tag_assignments_tag_id_idx" ON "tag_assignments" ("tag_id");
CREATE INDEX "tag_assignments_game_id_idx" ON "tag_assignments" ("game_id");
CREATE INDEX "tag_assignments_pc_id_idx" ON "tag_assignments" ("pc_id");
CREATE INDEX "game_sessions_tag_id_idx" ON "game_sessions" ("tag_id");
CREATE INDEX "game_sessions_game_id_idx" ON "game_sessions" ("game_id");
CREATE INDEX "game_sessions_pc_id_idx" ON "game_sessions" ("pc_id");
CREATE INDEX "game_sessions_device_id_idx" ON "game_sessions" ("device_id");
CREATE INDEX "launch_events_session_id_idx" ON "launch_events" ("session_id");
CREATE INDEX "launch_events_tag_id_idx" ON "launch_events" ("tag_id");
CREATE INDEX "launch_events_game_id_idx" ON "launch_events" ("game_id");
CREATE INDEX "launch_events_pc_id_idx" ON "launch_events" ("pc_id");
CREATE INDEX "launch_events_agent_id_idx" ON "launch_events" ("agent_id");
CREATE INDEX "launch_events_device_id_idx" ON "launch_events" ("device_id");
CREATE INDEX "launch_events_status_idx" ON "launch_events" ("status");
CREATE INDEX "audit_logs_user_id_idx" ON "audit_logs" ("user_id");
CREATE INDEX "audit_logs_entity_type_entity_id_idx" ON "audit_logs" ("entity_type", "entity_id");
