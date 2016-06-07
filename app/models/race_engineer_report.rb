class RaceEngineerReport < ActiveRecord::Base
  # attr_accessible :engineer_name, :race_engineer_id, :client_id

  belongs_to :race_engineer
  belongs_to :client

  validates :name, :presence => {:message => I18n.t('presence') }

  validates :report_date, :presence => {:message => I18n.t('presence') }
  validates :driver_id, :presence => {:message => I18n.t('presence') }
  validates :engineer_name, :presence => {:message => I18n.t('presence') }
  validates :championship, :presence => {:message => I18n.t('presence') }
  validates :circuit, :presence => {:message => I18n.t('presence') }
  validates :event, :presence => {:message => I18n.t('presence') }

  validates :name, :uniqueness => {:scope => :client_id, :message => I18n.t('uniqueness') }
end
