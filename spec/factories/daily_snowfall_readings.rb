# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :daily_snowfall_reading do
    date "2014-09-28 19:46:50"
    snow_water_equivalent 1.5
    change_in_snow_water_equivalent 1.5
    snow_depth_in 1
    change_in_snow_depth_in 1
    snotel_station_id 1
  end
end
