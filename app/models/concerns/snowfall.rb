module Snowfall
  extend ActiveSupport::Concern

  included do
    has_many :daily_snowfall_readings, as: :daily_snowfall_trackable
    has_many :hourly_snowfall_readings, as: :hourly_snowfall_trackable
  end

  def update_snowfall(days = 1, options = {})
    update_daily_snowfall(days) unless options[:skip_daily]
    update_hourly_snowfall(days * 24) unless options[:skip_hourly]

    self.last_7_days_snowfall_in = DailySnowfallReading.where(daily_snowfall_trackable: self)
                                     .limit(7).order('date DESC').map(&:snow_depth_in).reduce(:+)
    self.last_24_hours_snowfall_in = HourlySnowfallReading.where(hourly_snowfall_trackable: self)
                                       .limit(1).order('date DESC').map(&:snow_depth_in).reduce(:+)
    save!

    puts "SNOWFALL: updated the last #{ days } for #{ id }:#{ name }"
  end

  def update_daily_snowfall(days)
    data = Snotel.daily(token.to_sym, days)
    return unless data and data.any?

    ActiveRecord::Base.transaction do
      data.each do |d|
        d[:date] = DateTime.strptime(d[:date], "%Y-%m-%d")
        reading = daily_snowfall_readings.find_or_initialize_by(date: d[:date])
        reading.daily_snowfall_trackable = self
        reading.update(d)
      end

      touch
    end
  end

  def update_hourly_snowfall(hours)
    data = Snotel.hourly(token.to_sym, hours)
    return unless data and data.any?

    ActiveRecord::Base.transaction do
      data.each do |d|
        d[:date] = DateTime.strptime(d[:date], "%Y-%m-%d %H")
        reading = hourly_snowfall_readings.find_or_initialize_by(date: d[:date])
        reading.hourly_snowfall_trackable = self
        reading.update(d)
      end

      touch
    end
  end
end
