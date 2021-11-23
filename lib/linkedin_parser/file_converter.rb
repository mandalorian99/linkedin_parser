module LinkedinParser
  class FileConverter
    attr_accessor :attachement, :temp_path, :resume_text
    
    def initialize(attached_resume: attachement)
      @attachement = attached_resume
      @temp_path = @attachement.tempfile.path #attachment_temp_path
      @resume_text = ''
      @errors = {}
    end
    
    def file_2_text
      Rails.logger.debug ">>>> parsing start...."
      case file_extension!
        when '.pdf'
          resume_text = pdf_2_text
        when 'docx'
          resume_text = docx_2_text
        when '.doc'
          resume_text = doc_2_text
        else
          Rails.logger.debug "Unknown format, aborting process"
      end
    end
    
    private
    
    def pdf_2_text
      PDF::Reader.open(temp_path) do |reader|
        Rails.logger.info "Converting : #{temp_path}"
        pageno = 0
        txt = reader.pages.map do |page|
          pageno += 1
          begin
            Rails.logger.info  "Converting Page #{pageno}/#{reader.page_count}\r"
            page.text
          rescue
            Rails.logger.error  "Page #{pageno}/#{reader.page_count} Failed to convert"
            ''
          end
        end # pages map
        txt = txt.join("\n")
      end # reader
    end
    
    def doc_2_text
      require 'doc_ripper'
      DocRipper::rip(temp_path)
    end
    
    def docx_2_text
      require 'docx'
      doc = Docx::Document.open(temp_path)
  
      r_val = []
      doc.paragraphs.each do |p|
        r_val <<  p
      end
      r_val.join("\n")
    end
    
    def file_extension!
      temp_path.last(4)
    end
  end
end
  
# driver logic
# path = "/temp/foobar.pdf"
# file_converter = FileConverter.new(attachment_temp_path: path)
# file_converter.file_2_text