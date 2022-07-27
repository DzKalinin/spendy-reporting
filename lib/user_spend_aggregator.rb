class UserSpendAggregator
  ROUND_DIGITS = 2

  def initialize(user_name)
    @user_name = user_name
    @spend_total_rows = {}
  end

  def agg_spend_by(field, start_timestamp, end_timestamp)
    spend_per_agg_field = _agg_send_by(field, start_timestamp, end_timestamp)
    with_total_spend_rows(spend_per_agg_field)
  end

  private

  def _agg_send_by(field, start_timestamp, end_timestamp)
    agg_field_value = ->(fields_hash, field) do
      field == 'created_at' ? Time.at(fields_hash.dig(field, :integer_value)).to_date : fields_hash.dig(field, :string_value)
    end

    spend_per_agg_field = user_data(start_timestamp, end_timestamp).each_with_object({}) do |doc, h|
      fields_hash = doc.fields
      field_value = agg_field_value.call(fields_hash, field)
      currency = fields_hash.dig('currency', :string_value)
      key = "#{field_value}-#{currency}"
      h[key] ||= { agg_field_value: field_value, currency: currency, amount: 0, expenses_count: 0 }
      amount = fields_hash.dig('amount', :double_value)
      h[key][:amount] += amount
      h[key][:expenses_count] += 1

      @spend_total_rows[currency] ||= { amount: 0, expenses_count: 0 }
      @spend_total_rows[currency][:amount] += amount
      @spend_total_rows[currency][:expenses_count] += 1
    end.map { |_, v| v.merge({ amount: v[:amount].round(ROUND_DIGITS) }) }&.sort_by { |h| [h[:agg_field_value], h[:currency]] } || []

    spend_per_agg_field.map! { |h| h.merge({ agg_field_value: h[:agg_field_value].strftime("%d %b %Y")  }) } if field == 'created_at'
    spend_per_agg_field
  end

  def with_total_spend_rows(spend_per_agg_field)
    @spend_total_rows.sort_by{|(k,v)| k }.to_h.each do |currency, report_data_hash|
      spend_per_agg_field.unshift({ agg_field_value: "total #{currency}",
                                    currency: currency,
                                    amount: report_data_hash[:amount].round(ROUND_DIGITS),
                                    expenses_count: report_data_hash[:expenses_count] })
    end
    spend_per_agg_field
  end

  def user_data(start_timestamp, end_timestamp)
    puts "FIRESTORE QUERY PARAMS: user_name: '#{@user_name}', start_timestamp: #{start_timestamp}, end_timestamp: #{end_timestamp}"
    Firestore.col(Settings.app[:firestore_table_name]).
      where("user_name", "=", @user_name).
      where("created_at", ">=", start_timestamp).
      where("created_at", "<=", end_timestamp).
      get
  end
end
