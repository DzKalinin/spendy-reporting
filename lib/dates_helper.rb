class DatesHelper
  def self.start_timestamp(start_time_str)
    Time.zone.parse(start_time_str).beginning_of_day.to_i
  end

  def self.end_timestamp(end_time_str)
    end_time = Time.zone.parse(end_time_str).end_of_day
    today_time = Time.zone.now.end_of_day
    (end_time > today_time ? today_time : end_time).to_i
  end
end
