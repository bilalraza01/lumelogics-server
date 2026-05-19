# frozen_string_literal: true

# Public, anonymized SAMPLE audit for the marketing site (/audit/demo). It is
# the Scaleforte deliverable with every identifying string scrubbed (company
# + people), so prospects can explore a complete, realistic audit with zero
# real-client data exposed. Numbers/refs are untouched, so all derived totals
# and cross-references stay consistent.
require_relative "scaleforte"

module Seeds
  module Audits
    module Demo
      module_function

      # Full names first (so "Sam Ortiz" is handled before the bare "Sam"
      # first-name pass), then bare first names in prose, then the company.
      FULL_NAMES = [
        ["Daniel Cho",   "Alex Mercer"],
        ["Priya Nair",   "Riya Donovan"],
        ["Sam Ortiz",    "Theo Park"],
        ["Marcus Webb",  "Quinn Hale"],
        ["Ava Thompson", "Noor Hassan"],
      ].freeze
      FIRST_NAMES = {
        "Daniel" => "Alex", "Priya" => "Riya", "Sam" => "Theo",
        "Marcus" => "Quinn", "Ava" => "Noor"
      }.freeze

      def scrub(str)
        out = str.dup
        FULL_NAMES.each { |from, to| out = out.gsub(from, to) }
        FIRST_NAMES.each { |from, to| out = out.gsub(/\b#{from}\b/, to) }
        out.gsub("Scaleforte", "Northpeak Commerce")
      end

      def walk(node)
        case node
        when String then scrub(node)
        when Array  then node.map { |e| walk(e) }
        when Hash   then node.transform_values { |e| walk(e) }
        else node
        end
      end

      def content
        doc = walk(Marshal.load(Marshal.dump(Seeds::Audits::Scaleforte.content)))
        # Make it unmistakably a sample (honest, still impressive).
        doc[:hero][:eyebrow] = "Sample Business Operations Audit"
        doc
      end
    end
  end
end
