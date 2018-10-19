require_relative './adhan/job/schedule.rb'
require 'httparty'
require 'tzinfo'
require 'yaml'
require 'pry'

class Adhan
  def initialize
    @timezone_location = CNF['TIMEZONE_LOCATION'] || 'Asia/Jakarta'
    @latitude = CNF['LATITUDE'] || -6.2248896
    @longitude = CNF['LONGITUDE'] || 106.8279695
    @url = "http://api.aladhan.com/timings/"
  end

  def run
    response = get_schedule
    if response['status'].downcase == 'ok' && response['code'] == 200
      data = response['data']
      data['timings'].slice("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha").each do |prayer_time, timestamp|
        get_attribute = get_message_and_time(prayer_time, data, timestamp)
        time = get_attribute[:time]
        message = get_attribute[:message]
        next if !time.nil? && !message.empty?
        next if time < Time.now
        StartSchedule.perform_at(time, message)
        puts get_attribute
      end
    end
  end

  def get_schedule
    full_url = "#{@url}#{local_timestamp}?latitude=#{@latitude}&longitude=#{@longitude}&timezonestring=#{@timezone_location}&method=2"
    HTTParty.get(full_url)
  end

  def local_timestamp
    timezone = TZInfo::Timezone.get(@timezone_location)
    Time.now.getlocal(timezone.current_period.offset.utc_total_offset).to_i
  end

  def get_message_and_time(prayer_time, data, timestamp)
    result = {message: '', time: ''}
    case prayer_time
    when "Fajr"
      result[:message] = "<@channel> Yuk sholat subuh"
      result[:time] = Time.parse("#{data['date']['readable']} #{timestamp}")
    when "Dhuhr"
      result[:message] = '<@channel> Yuk sholat dzuhur'
      result[:time] = Time.parse("#{data['date']['readable']} #{timestamp}")
    when "Asr"
      result[:message] = '<@channel> Yuk sholat ashar'
      result[:time] = Time.parse("#{data['date']['readable']} #{timestamp}")
    when "Maghrib"
      result[:message] = "<@channel> Yuk sholat magrib"
      result[:time] = Time.parse("#{data['date']['readable']} #{timestamp}")
    when "Isha"
      result[:message] = "<@channel> Yuk sholat isha"
      result[:time] = Time.parse("#{data['date']['readable']} #{timestamp}")
    end
    result
  end

end
