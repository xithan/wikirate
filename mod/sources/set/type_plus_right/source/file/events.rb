
event :add_source_link, :prepare_to_validate, on: :save, when: :remote_file_url do
  left.add_subfield :wikirate_link, content: remote_file_url
end

event :validate_source_file, :validate, on: :create do
  # note: better to integrate carrierwave error handling.
  #
  # The following go
  # CarrierWave.configure do |config|
  #   config.ignore_download_errors = false
  # end
  if file.blank?
    errors.add :download, "Could not download file"
  elsif !accepted_mime_type?
    errors.add :mime, "unaccepted MIME type: #{file.content_type}"
  end
end

event :block_file_changing, after: :write_identifier, on: :update, changed: :content,
                            when: :file_changed? do
  errors.add :file, "is not allowed to be changed."
end

event :normalize_html_file, :prepare_to_store, on: :save, when: :html_file? do
  if remote_file_url
    convert_to_pdf
  else
    errors.add :file, "HTML Sources must be downloaded from URLS"
  end
end

def unfilled?
  !remote_file_url && super
end

def accepted_mime_type?
  file.content_type.in? ACCEPTED_MIME_TYPES
end

def convert_to_pdf
  puts "generating pdf"
  pdf_from_url remote_file_url do |pdf_file|
    self.file = pdf_file
  end
rescue StandardError => e
  errors.add :conversion, "failed to convert HTML source to pdf #{e.message}"
end

def pdf_from_url url
  kit = PDFKit.new url, "load-error-handling" => "ignore"
  Dir::Tmpname.create(["source", ".pdf"]) do |path|
    kit.to_file path
    yield ::File.open path
  end
end

# this is cached so that it continues to return true even after the file
# is converted to a pdf.
def html_file?
  @html_file.nil? ? (@html_file = file&.content_type == "text/html") : @html_file
end
