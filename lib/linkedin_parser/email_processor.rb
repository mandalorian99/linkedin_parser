# A class intented to process incoming POST request 
# from cloudmain on webhook /webhook/incoming_mails
require "linkedin_parser/processable"

module LinkedinParser
  class EmailProcessor
    include LinkedinParser::Processable
    attr_accessor :attachment, :resume_text, :email_plain_text, :candidate_email,
                  :parsed_email_json, :linkedin_job_id, :contract_id, :candidate_name, :source, 
                  :format_parsed_email_hash

    def initialize(args)
        @attachment = args[:attachment] || nil
        @email_plain_text = args[:email_plain_text] || ''
        @resume_text = ''
        @candidate_email = nil
        @parsed_email_json = nil
        @linkedin_job_id = nil
        @contract_id = nil
        @errors = {}
        @source = 'linkedin'
        @candidate_name = extract_name(email_subject: args[:subject])
        @format_parsed_email_hash = {}
    end

    def process?
      return false unless processable?
      begin
        @resume_text = file_converter.file_2_text
        @candidate_email = set_candidate_email
        @parsed_email_json = plain_email_parser
        @format_parsed_email_hash = format_parsed_email_json(@parsed_email_json)
        @linkedin_job_id = @parsed_email_json[:project_id]
        @contract_id = @parsed_email_json[:contract_id]
        Rails.logger.info "Done  parse_plain_into_parsed_mail."
        return true 
      rescue => e
        Rails.logger.debug  "Unable to convert file to text #{e}"
        return false
      end
    end

    private

    def file_converter
      FileConverter.new(attached_resume: attachment)
    end

    def plain_email_parser
      Parser::PlainEmail::parse(email_plain_text)
    end

    def processable?
      attachment.present?
    end

    # fetch out candidate email from resume text
    # TODO: move to resume parser later
    def set_candidate_email
      email = resume_text.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)[0]
      unless email.present?
        Rails.logger.warn "Failed to extract email, trying with different regex method"
        email = extract_email(resume_text)
      end
      Rails.logger.info "candidate email >#{email}< obtained from resume_text."
      email
    end

  end
end
  
  # driver code
  # emailparser = IncomingMail::EmailProcessor.new(foo: 'dd', bar: '')
  # emailparse.parse_request(params)