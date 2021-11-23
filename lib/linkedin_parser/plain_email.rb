require 'processable'

module LinkedinParser
  class PlainEmail
    extend LinkedinParser::Processable

    SECTION_TITLES = [
      'Current experience',
      'Past experience',
      'Education',
      'Skills matching your job',
      'Highlight' ,
      'Contact Information',
      'You are receiving Job Applicant emails.'
    ]
  
    def self.parse plain_email
      return {} unless plain_email.present?
      sections = {}
      urls = extract_urls(plain_text: plain_email)
      plain_email = clean_up plain_email
      linkedin_ids_hash = extract_project_id(urls) || {} # {contract_id: '', project_id: ''}
      ap "clean mail plain_email: #{plain_email}"
      idxs = find_section_headers plain_email
      sections = extract_sections plain_email, idxs
      ap sections
      sections.merge(linkedin_ids_hash)
    end

    def self.extract_email_from_str str
      (str||'').scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)[0]
    end
  
    private
  
    def self.clean_up text
      #.gsub(/(?<!\n)\n(?!\n)/," ") #remove single new lines
      r_val = text
        .gsub(/#{URI::regexp}/, '') #rm urls
        .gsub("\r", "") #rm carriage returns
        .gsub(/<.*>/, "") #rm links
        .squeeze("\n")
        .squeeze(".").gsub("\n.\n","\n") #rm delimiter lines made of dots
        .squeeze("-").gsub("\n-\n","\n") #rm delimiter lines made of dashes
        .gsub("\u0000", '') #get rid of null chars
      r_val
    end
  
    def self.find_section_headers text
      header_idxs = []
      SECTION_TITLES.each do |title|
        idx = text.index title
        header_idxs << [title, idx] if idx.present?
      end
      header_idxs.sort!{ |a,b| a[1] <=> b[1] }
      missing_headers_error = header_idxs.empty? ||  header_idxs.last[0] != SECTION_TITLES.last
      Rails.logger.warn "Did not find all the headers reqauired for parsing" if missing_headers_error
      header_idxs
    end
  
    def self.extract_sections text, idxs
      sections = {}
      (0..idxs.length-2).each do |idx|
        s_idx = idxs[idx][1]
        e_idx = (idxs[idx+1][1]) - 1
        header = idxs[idx][0]
        content = text
          .slice(s_idx, e_idx - s_idx)
          .gsub(header, '')
          .strip
        sections[header] = content
      end
      sections
    end
  end
end