module LinkedinParser
  module Processable
    def extract_email str
      (str||'').scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)[0]
    end
  
    def extract_urls(plain_text: '')
      urls = (plain_text || '').scan(/(http|https|ftp|ftps)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/)
      if urls.class == Array && urls.length > 0
        return urls.flatten.uniq!
      end
      return []
    end
  
    def extract_project_id(urls =[])
      contract_id = nil 
      project_id = nil
      urls.each do |url|
        if url.match?('contractId') || url.match('projectId')
          arr = url.split("&amp")
          arr.each do |str|
            if str.match?('contractId')
              contract_id = str.split('=')[1]
            end
  
            if str.match?('project')
              project_id = str.split('=')[1]
            end
  
          end # EOL
          break
        end
      end # EOL
      return {contract_id: contract_id, project_id: project_id}
    end
  
    def extract_name(email_subject: '')
      if email_subject.include?('New application')
        arr = email_subject.split('from')
        return arr.pop
      end
      return ''
    end
  
    # Extract title, job experiences, skills , education experiences from email plain text
    def format_parsed_email_json(h)
      {
        title: format_title(h['Current experience']) || 'N/A', 
        skills:  format_skills(h['Skills matching your job']) || 'N/A',
        job_experience: parse_job_exp(h) || [],
        education_experience: []
      }
    end
  
    def format_title(current_exp)
      return '' unless current_exp.present?
      current_exp_arr = sanitize_str(current_exp)
      title = current_exp_arr.first.split(" from ").shift || 'N/A'
    end
  
    def format_skills(skills)
      return 'N/A' unless skills.present?
      skills = sanitize_str(skills).join(' ')
      skills.split(" ").join(',')
    end
  
    def parse_job_exp(h)
      exp = [] << sanitize_str(h['Current experience']) << sanitize_str(h['Past experience'])
      exp_arr = exp.flatten
      data = []
  
      ## input
      #  ["Senior Software Engineer at Tata Consultancy Services from 2016 to Presen", ..]
      ## output
      # {company: 'xxx', position: 'xxxx', from: 'xxx', to: 'xxxx'}
      for exp in exp_arr
        next if exp.blank? or exp == " "
        next if exp.nil?
        exp_hash = {}
  
        arr = exp.split(" at ")
        exp_hash[:position] = arr.shift
        arr = arr.shift.split(" from ")
        exp_hash[:company] = arr.shift
        arr = arr.shift.split(" to ")
        exp_hash[:from] = arr.shift
        exp_hash[:to] = arr.first.include?("Presen") ? Time.now.year.to_s : arr.shift.to_s.scan(/\d{4}/).to_s.gsub("\"", "").gsub("[",'').gsub("]", '')
  
        data << exp_hash
      end
      return data
    end
  
    def sanitize_str(str)
      str.split("\n").map {|str| str.gsub(/\"/, " ").gsub(/=>/, "").gsub(",", "").gsub("(", "").gsub(")", "").lstrip.chop}
    end
  
  end
end


## For reference
# A linkedin job url sample
# we need to extract contract_id or project_id 
# these are two tell us which job a candidate is applying on .
# https://www.linkedin.com/comm/talent/redirect/batchReview?status=applicants&amp;profile=AEMAABQXuXMBXOimX3maP_1JmjgiN3zwEjEGzd0&amp;rightRail=jobApplication&amp;contractId=247899636&amp;project=417038466&amp;trk=eml-email_jobs_new_applicant_01-email_jobs_new_applicant-12-profile_application&amp;trkEmail=eml-email_jobs_new_applicant_01-email_jobs_new_applicant-12-profile_application-null-%7E8yblxz%7Ekgrzlgfc%7Ei7-null-talent%7Eredirect%7Ebatch%7Ereview&amp;lipi=urn%3Ali%3Apage%3Aemail_email_jobs_new_applicant_01%3BXsFcRsA%2FT0GImlbUrOc8Sg%3D%3D

# sample regex
# scan(/(https)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/)
