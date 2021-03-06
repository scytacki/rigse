#
# This is a denormalized class. Its used to store summary data for
# learners as would be used in a report.

class Report::Learner < ActiveRecord::Base
  set_table_name "report_learners"

  belongs_to   :learner, :class_name => "Portal::Learner", :foreign_key => "learner_id"
  serialize    :answers

  named_scope :after,  lambda         { |date|         {:conditions => ["last_run > ?", date]} }
  named_scope :before, lambda         { |date|         {:conditions => ["last_run < ?", date]} }
  named_scope :in_schools, lambda     { |school_ids|   {:conditions => {:school_id   => school_ids   }}}
  named_scope :in_classes, lambda     { |class_ids|    {:conditions => {:class_id    => class_ids    }}}
  named_scope :with_runnables, lambda { |runnable_ids| {:conditions => {:runnable_id => runnable_ids }}}

  validates_presence_of   :learner
  validates_uniqueness_of :learner_id

  after_create :update_fields

  def self.for_learner(learner)
    found = Report::Learner.find_by_learner_id(learner.id) 
    unless found
      found = Report::Learner.create(:learner => learner)
      learner.reload
    end
    found
  end

  def calculate_last_run
    begin
      self.last_run = self.learner.bundle_logger.last_non_empty_bundle_content.updated_at
    rescue
      Rails.logger.warn("could not load last bundle content. #{$!}!")
    end
  end

  def update_answers
    report_util = Report::Util.new(self.learner, false, true)

    # We need to populate these field
    self.num_answerables = report_util.embeddables.size
    self.num_answered = report_util.answered_number(self.learner)
    self.num_correct = report_util.correct_number(self.learner)

    # We might also want to gather 'saveables' in An associated model?
    # AU: We'll use a serialized column to store a hash, for now
    answers_hash = {}
    report_util.saveables(:learner => self.learner).each do |s|
      hash = {:answer => s.answer, :answered => s.answered? }
      hash[:is_correct] = s.answered_correctly? if s.respond_to?("answered_correctly?")
      if hash[:answer].kind_of?(Dataservice::Blob)
        blob = hash[:answer]
        hash[:answer] = {
          :type => "Dataservice::Blob",
          :id => blob.id,
          :token => blob.token,
          :file_extension => blob.file_extension
        }
      end
      answers_hash["#{s.embeddable.class.to_s}|#{s.embeddable.id}"] = hash
    end
    self.answers = answers_hash
  end

  def update_field(methods_string, field=nil)
    value = nil
    unless field
      field =methods_string.split(".")[-2..2].join("_")
    end
    begin
      symbols = methods_string.split(".").map{ |s| s.to_sym}
      value = symbols.inject(self.learner) do |o,symbol|
        o.send(symbol)
      end
      if block_given?
        value = yield(value)
      end
      self.send("#{field}=".to_sym,value)
    rescue
      Rails.logger.error("could not set self.#{field} using self.learner.#{methods_string} #{$!}!")
    end
  end

  def update_fields
    update_field "student.id"
    update_field "offering.id"
    update_field "offering.name"

    update_field "offering.runnable.name"
    update_field "offering.runnable.id"
    update_field "offering.runnable.class.to_s", "runnable_type"

    update_field "student.user.id"
    update_field "student.user.name", "student_name"
    update_field "student.user.login", "username"

    update_field "offering.clazz.id", "class_id"
    update_field "offering.clazz.name", "class_name"
    update_field "offering.clazz.school.name", "school_name"
    update_field "offering.clazz.school.id",    "school_id"
    update_field("offering.clazz.teachers", "teachers_name") do |ts|
      ts.map { |t| t.user.name}.join(", ")
    end
    calculate_last_run
    update_answers
    Rails.logger.debug("Updated Report Learner: #{self.student_name}")
    self.save
  end
end
