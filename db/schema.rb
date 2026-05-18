# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_05_18_100001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.bigint "prospect_id", null: false
    t.string "event_type", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.index ["event_type"], name: "index_activities_on_event_type"
    t.index ["prospect_id", "occurred_at"], name: "index_activities_on_prospect_id_and_occurred_at", order: { occurred_at: :desc }
    t.index ["prospect_id"], name: "index_activities_on_prospect_id"
  end

  create_table "admin_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "assessments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "result_token", null: false
    t.string "email", null: false
    t.jsonb "answers", default: {}, null: false
    t.jsonb "dimension_scores", default: {}, null: false
    t.integer "total_score", null: false
    t.string "archetype", null: false
    t.string "referral_source"
    t.string "ip_address"
    t.string "user_agent"
    t.boolean "email_sent", default: false, null: false
    t.datetime "email_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archetype"], name: "index_assessments_on_archetype"
    t.index ["created_at"], name: "index_assessments_on_created_at"
    t.index ["email"], name: "index_assessments_on_email"
    t.index ["result_token"], name: "index_assessments_on_result_token", unique: true
  end

  create_table "audits", force: :cascade do |t|
    t.string "slug", null: false
    t.string "client_name", null: false
    t.string "industry"
    t.string "status", default: "in_progress", null: false
    t.date "started_on"
    t.date "completed_on"
    t.jsonb "content", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_audits_on_slug", unique: true
    t.index ["status"], name: "index_audits_on_status"
  end

  create_table "campaign_pushes", force: :cascade do |t|
    t.bigint "prospect_id", null: false
    t.bigint "video_id"
    t.bigint "smartlead_campaign_id", null: false
    t.string "smartlead_campaign_name"
    t.string "status", null: false
    t.string "skip_reason"
    t.jsonb "response_payload"
    t.datetime "pushed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prospect_id", "smartlead_campaign_id"], name: "index_campaign_pushes_unique_successful_push", unique: true, where: "((status)::text = 'success'::text)"
    t.index ["prospect_id"], name: "index_campaign_pushes_on_prospect_id"
    t.index ["smartlead_campaign_id"], name: "index_campaign_pushes_on_smartlead_campaign_id"
    t.index ["video_id"], name: "index_campaign_pushes_on_video_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.integer "lock_type", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["created_at"], name: "index_good_jobs_on_created_at"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at_only", where: "(finished_at IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_on_discarded", order: :desc, where: "((finished_at IS NOT NULL) AND (error IS NOT NULL))"
    t.index ["id"], name: "index_good_jobs_on_unfinished_or_errored", where: "((finished_at IS NULL) OR (error IS NOT NULL))"
    t.index ["job_class"], name: "index_good_jobs_on_job_class"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at", "id"], name: "index_good_jobs_for_candidate_dequeue_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["priority", "scheduled_at", "id"], name: "index_good_jobs_on_priority_scheduled_at_unfinished", where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at", "id"], name: "index_good_jobs_on_queue_name_priority_scheduled_at_unfinished", where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["queue_name"], name: "index_good_jobs_on_queue_name"
    t.index ["scheduled_at", "queue_name"], name: "index_good_jobs_on_scheduled_at_and_queue_name"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "lead_magnet_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "lead_magnet_id", null: false
    t.string "email", null: false
    t.string "verification_token", null: false
    t.datetime "verified_at"
    t.string "ip_address"
    t.string "user_agent"
    t.string "referral_source"
    t.boolean "email_sent", default: false, null: false
    t.datetime "email_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_lead_magnet_requests_on_created_at"
    t.index ["email"], name: "index_lead_magnet_requests_on_email"
    t.index ["lead_magnet_id"], name: "index_lead_magnet_requests_on_lead_magnet_id"
    t.index ["verification_token"], name: "index_lead_magnet_requests_on_verification_token", unique: true
  end

  create_table "lead_magnets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "slug", null: false
    t.string "title", null: false
    t.text "description"
    t.string "resource_type", null: false
    t.string "resource_url"
    t.string "email_subject", null: false
    t.text "email_intro"
    t.string "vsl_video_url"
    t.string "vsl_headline"
    t.text "vsl_body"
    t.string "calendly_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "resource_file"
    t.index ["slug"], name: "index_lead_magnets_on_slug", unique: true
  end

  create_table "prospects", force: :cascade do |t|
    t.citext "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "company_name"
    t.string "linkedin_url"
    t.string "website"
    t.text "notes"
    t.string "status", default: "not_contacted", null: false
    t.integer "batch_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_prospects_on_batch_id"
    t.index ["email"], name: "index_prospects_on_email", unique: true
    t.index ["status"], name: "index_prospects_on_status"
  end

  create_table "smartlead_campaigns", force: :cascade do |t|
    t.bigint "smartlead_id", null: false
    t.string "name"
    t.string "status"
    t.datetime "last_synced_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["smartlead_id"], name: "index_smartlead_campaigns_on_smartlead_id", unique: true
  end

  create_table "videos", force: :cascade do |t|
    t.bigint "prospect_id", null: false
    t.string "slug", null: false
    t.string "loom_url", null: false
    t.string "r2_mp4_key"
    t.string "r2_gif_key"
    t.string "mp4_url"
    t.string "gif_url"
    t.string "player_url"
    t.integer "duration_seconds"
    t.string "status", default: "pending", null: false
    t.text "error_message"
    t.integer "batch_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_videos_on_batch_id"
    t.index ["prospect_id"], name: "index_videos_on_prospect_id"
    t.index ["slug"], name: "index_videos_on_slug", unique: true
    t.index ["status"], name: "index_videos_on_status"
  end

  add_foreign_key "activities", "prospects"
  add_foreign_key "campaign_pushes", "prospects"
  add_foreign_key "campaign_pushes", "videos"
  add_foreign_key "lead_magnet_requests", "lead_magnets"
  add_foreign_key "videos", "prospects"
end
