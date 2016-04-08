IMPORT_FIELDS = [:file_company, :value].freeze

# @param [Hash] args
# @option args [String] :metric
# @option args [String] :company
# @option args [String] :year
# @option args [String] :value
# @option args [String] :source source url
# @return [Hash] subcards hash
def metric_value_subcards args
  {
    '+metric' => { 'content' => args[:metric] },
    '+company' => { 'content' => args[:company] },
    '+value' => { 'content' => args[:value], :type_id => PhraseID },
    '+year' => { 'content' => "[[#{args[:year]}]]", :type_id => PointerID },
    '+source' => {
      'subcards' => {
        'new source' => {
          '+Link' => {
            'content' => args[:source], 'type_id' => PhraseID
          }
        }
      }
    }
  }
end

event :import_csv, :prepare_to_store,
      on: :update,
      when: proc { Env.params['is_metric_import_update'] == 'true' } do
  return unless (metric_values = Env.params[:metric_values])
  return unless valid_import_format?(metric_values)
  metric_values.each do |metric_value_data|
    metric_value_card = import_metric_value metric_value_data
    @import_errors.each do |msg|
      errors.add *msg
    end
    next unless metric_value_card
    metric_value_card.errors.each do |key, error_value|
      errors.add "#{metric_value_card.name}+#{key}", error_value
    end
  end
  handle_redirect redirect_target_after_import
end

def valid_import_format? data
  data.is_a? Array
end

def redirect_target_after_import
  nil
end

def company_corrections
  @company_corrections ||=
    begin
      hash = Env.params[:corrected_company_name]
      return {} unless hash.is_a?(Hash)
      hash.delete_if { |_k, v| v.blank? }
    end
end

def handle_redirect target=nil
  if errors.empty?
    if target
      abort success:  { name: target, redirect: true, view: :open }
    else
      abort :success
    end
  else
    abort :failure
  end
end


def get_corrected_company_name params
  corrected = company_corrections[params[:row]]
  return params[:company] unless corrected.present?

  unless Card.exists?(corrected)
    Card.create! name: corrected, type_id: WikirateCompanyID
  end
  if corrected != params[:company]
    Card[corrected].add_alias params[:company]
  end
  corrected
end

def add_import_error msg, row=nil
  return unless msg
  title = "import error"
  title += " (row #{row})" if row
  @import_errors << [title, msg]
end

def valid_value_data? args
  @import_errors = []
  add_import_error "metric name missing", args[:row] if args[:metric].blank?
  %w(company year value).each do |field|
    add_import_error "#{field} missing", args[:row] if args[field.to_sym].blank?
  end
  { metric: MetricID,
    year: YearID,
    company: WikirateCompanyID }.each_pair do |type, type_id|
    msg = check_existence_and_type(args[type], type_id, type)
    add_import_error msg, args[:row]
  end
  @import_errors.empty?
end

def check_existence_and_type name, type_id, type_name=nil
  return  "#{name} doesn't exist" unless Card[name]
  if Card[name].type_id != type_id
    return "#{name} is not a #{type_name}"
  end
end

def ensure_company_exists company
  return if Card[company]
  Card.create name: company, type_id: WikirateCompanyID
end

# @return updated or created metric value card object
def import_metric_value import_data
  args = process_metric_value_data import_data
  ensure_company_exists args[:company]
  return unless valid_value_data? args
  metric_value_name = [args[:metric], args[:company], args[:year]].join '+'
  subcards = metric_value_subcards args
  if (metric_value_card = Card[metric_value_name])
    metric_value_card.update_attributes subcards: subcards
    metric_value_card
  else
    Card.create name: metric_value_name,
                type_id: Card::MetricValueID,
                subcards: subcards
  end
end

def csv_rows
  # transcode to utf8 before CSV reads it.
  # some users upload files in non utf8 encoding.
  # The microsoft excel may not save a CSV file in utf8 encoding
  CSV.read(file.path, encoding: 'windows-1251:utf-8')
end

def clean_html? # return always true ;)
  false
end

format :html do
  def aliases_hash
    @aliases_hash ||= begin
      aliases_cards = Card.search right: 'aliases',
                  left: { type_id: WikirateCompanyID }
      aliases_cards.each_with_object({}) do |aliases_card, aliases_hash|
        aliases_card.item_names.each do |name|
          aliases_hash[name.downcase] = aliases_card.cardname.left
        end
      end
    end
  end

  def get_potential_company name
    result = Card.search type: 'company', name: ['match', name]
    return nil if result.empty?
    result
  end

  # @return name of company in db that matches the given name and
  # the what kind of match
  def matched_company name
    if (company = Card.fetch(name)) && company.type_id == WikirateCompanyID
      [name, :exact]
    # elsif (result = Card.search :right=>"aliases",
    # :left=>{:type_id=>Card::WikirateCompanyID},
    # :content=>["match","\\[\\[#{name}\\]\\]"]) && !result.empty?
    #   [result.first.cardname.left, :alias]
    elsif (company_name = aliases_hash[name.downcase])
      [company_name, :alias]
    elsif (result = get_potential_company(name))
      [result.first.name, :partial]
    elsif (company_name = part_of_company(name))
      [company_name, :partial]
    else
      ['', :none]
    end
  end

  def part_of_company name
    Card.search(type: 'company', return: 'name').each do |comp|
      return comp if name.match comp
    end
    nil
  end

  def default_import_args args
    args[:buttons] = %(
      #{button_tag 'Import', class: 'submit-button',
                             data: { disable_with: 'Importing' }}
      #{button_tag 'Cancel', class: 'cancel-button slotter', href: path,
                             type: 'button'}
    )
  end

  view :import do |args|
    frame_and_form :update, args, 'notify-success' => 'import successful' do
      [
        _optional_render(:metric_select, args),
        _optional_render(:year_select, args),
        _optional_render(:metric_import_flag, args),
        _optional_render(:selection_checkbox, args),
        _optional_render(:import_table, args),
        _optional_render(:button_formgroup, args)
      ]
    end
  end

  view :year_select do |_args|
    nest card.left.year_card, view: :edit_in_form
  end

  view :metric_select do |_args|
    nest card.left.metric_card, view: :edit_in_form
  end

  view :metric_import_flag do |_args|
    hidden_field_tag :is_metric_import_update, 'true'
  end

  view :selection_checkbox do |_args|
    content = %(
      #{check_box_tag 'uncheck_all', '', false, class: 'checkbox-button'}
      #{label_tag 'Uncheck All'}
      #{check_box_tag 'partial', '', false, class: 'checkbox-button'}
      #{label_tag 'Select Partial'}
      #{check_box_tag 'exact', '', false, class: 'checkbox-button'}
      #{label_tag 'Select Exact'}
    )
    content_tag(:div, content, { class: 'selection_checkboxs' }, false)
  end

  def default_import_table_args args
    args[:table_header] = ['Import', '#', 'Company in File',
                           'Company in Wikirate', 'Match', 'Correction']
    args[:table_fields] = [:checkbox, :row, :file_company, :wikirate_company,
                            :status, :correction]
  end

  view :import_table do |args|
    data = card.csv_rows.map.with_index do |elem, i|
             import_row(elem, args[:table_fields], i+1)
           end
    table data, class: 'import_table table-bordered table-hover',
                header: args[:table_header]
  end


  def company_correction_field row_hash
    text_field_tag("corrected_company_name[#{row_hash[:row]}]", '',
                   class: 'company_autocomplete')
  end

  def import_checkbox row_hash
    checked = [:partial, :exact, :alias].include? row_hash[:status]
    key_hash = row_hash.deep_dup
    key_hash[:company] = row_hash[:status] == :none ?
      row_hash[:file_company] : row_hash[:wikirate_company]
    check_box_tag "metric_values[]", key_hash.to_json, checked
  end

  def import_row row, fields, index
    data = row_to_hash row
    data[:row] = index
    data[:wikirate_company], data[:status] = matched_company data[:file_company]
    data[:status] = data[:status].to_s
    data[:company] =
      if data[:wikirate_company].empty?
        data[:file_company]
      else
        data[:wikirate_company]
      end
    data[:checkbox] = import_check_box data
    data[:correction] =
      status == :exact ? '' : company_correction_field data

    fields.map { |key| data[key] }
  end

  def row_to_hash row
    IMPORT_FIELDS.each_with_object.with_index({}) do |(key, hash), i|
      hash[key] = row[i]
    end
  end
end
