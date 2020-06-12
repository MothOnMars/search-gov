# frozen_string_literal: true

class Click
  include ActiveModel::Validations

  attr_reader :url, :query, :position, :module_code, :client_ip, :user_agent

  validates :url, :query, :position, :module_code, :client_ip, :user_agent, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :module_code, inclusion: { in: SearchModule.pluck(:tag), allow_blank: true, message: '%{value} is not a valid module' }
  #validates :module_code, inclusion: { in: ["BBG", "BOOS", "BWEB", "CREL", "QRTD", "VIDEO"], allow_blank: true, message: '%{value} is not a valid module' }
  validate :client_ip_validation

  def initialize(params)
    puts "MODULES: #{SearchModule.pluck(:tag)}"
    @url = unescape_url(params[:url])
    @query = params[:query]
    @client_ip = params[:client_ip]
    @affiliate = params[:affiliate]
    @position = params[:position]
    @module_code = params[:module_code]
    puts "module code: #{module_code}"
    puts "included? #{SearchModule.pluck(:tag).include? @module_code}"
    @vertical = params[:vertical]
    @user_agent = params[:user_agent]
  end

  def log
    Rails.logger.info('[Click] ' + instance_values.to_json)
  end

  private

  def client_ip_validation
    return if client_ip.blank?
    return if valid_ip?

    errors.add(:client_ip, 'is invalid')
  end

  def valid_ip?
    matched = (client_ip =~ Resolv::AddressRegex)
    matched.present?
  end

  def unescape_url(url)
    CGI.unescape(url).tr(' ', '+') rescue nil
  end
end
