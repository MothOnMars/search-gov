class AgencyUrl < ActiveRecord::Base
  validates_presence_of :url, :locale
  validates_uniqueness_of :url, :scope => :locale, :case_sensitive => false
  belongs_to :agency

  def to_label
    url
  end
end
