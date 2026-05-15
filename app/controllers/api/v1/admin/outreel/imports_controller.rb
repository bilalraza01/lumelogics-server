require "csv"

module Api
  module V1
    module Admin
      module Outreel
        class ImportsController < BaseController
          ALLOWED_COLUMNS = %w[email first_name last_name company_name linkedin_url website notes].freeze

          def prospects
            file = params[:file]
            unless file.respond_to?(:read)
              return render(json: { error: "file is required (multipart upload)" }, status: :bad_request)
            end

            content = file.read.force_encoding("UTF-8")
            content.sub!(/\A\xEF\xBB\xBF/, "")

            rows = CSV.parse(content, headers: true)
            unless rows.headers
              return render(json: { error: "CSV is empty or missing a header row" }, status: :unprocessable_entity)
            end

            header_map = build_header_map(rows.headers)
            unless header_map["email"]
              return render(json: { error: "CSV must contain an 'email' column" }, status: :unprocessable_entity)
            end

            created = 0
            skipped = 0
            errors  = []

            rows.each.with_index(2) do |row, lineno|
              attrs = ALLOWED_COLUMNS.each_with_object({}) do |col, acc|
                src_header = header_map[col]
                acc[col] = row[src_header].to_s.strip if src_header
              end
              attrs["email"] = attrs["email"].to_s.downcase

              if attrs["email"].blank?
                errors << { row: lineno, email: nil, error: "missing email" }
                next
              end

              if Prospect.exists?(email: attrs["email"])
                skipped += 1
                next
              end

              prospect = Prospect.new(attrs)
              if prospect.save
                Activity.log!(prospect, "csv_imported", { row: lineno })
                created += 1
              else
                errors << { row: lineno, email: attrs["email"], error: prospect.errors.full_messages.join(", ") }
              end
            end

            render json: { created: created, skipped: skipped, errors: errors }
          end

          private

          def build_header_map(headers)
            normalized = headers.compact.map { |h| [normalize(h), h] }.to_h
            ALLOWED_COLUMNS.each_with_object({}) do |col, acc|
              acc[col] = normalized[normalize(col)]
            end
          end

          def normalize(s)
            s.to_s.downcase.gsub(/[^a-z0-9]/, "")
          end
        end
      end
    end
  end
end
