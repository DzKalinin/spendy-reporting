class UserStatsAggregator
  ROUND_DIGITS = 2

  def initialize(user_name)
    @user_name = user_name
    @spend_total_rows = {}
  end

  def agg_spend_by(field)
    spend_per_agg_field = _agg_send_by(field)
    with_total_spend_rows(spend_per_agg_field)
  end

  private

  def _agg_send_by(field)
    agg_field_value = ->(fields_hash, field) do
      field == 'created_at' ? Time.at(fields_hash.dig(field, :integer_value)).to_date : fields_hash.dig(field, :string_value)
    end

    spend_per_agg_field = user_data.each_with_object({}) do |doc, h|
      fields_hash = doc.fields
      field_value = agg_field_value.call(fields_hash, field)
      currency = fields_hash.dig('currency', :string_value)
      key = "#{field_value}-#{currency}"
      h[key] ||= { agg_field_value: field_value, currency: currency, amount: 0 }
      amount = fields_hash.dig('amount', :double_value)
      h[key][:amount] += amount

      @spend_total_rows[currency] ||= 0
      @spend_total_rows[currency] += amount
    end.map { |_, v| v.merge({ amount: v[:amount].round(ROUND_DIGITS) }) }&.sort_by { |h| [h[:agg_field_value], h[:currency]] } || []

    spend_per_agg_field.map! { |h| h.merge({ agg_field_value: h[:agg_field_value].strftime("%d %b %Y")  }) } if field == 'created_at'
    spend_per_agg_field
  end

  def with_total_spend_rows(spend_per_agg_field)
    @spend_total_rows.sort_by{|(k,v)| k }.to_h.each do |currency, amount|
      spend_per_agg_field.unshift({ agg_field_value: "total #{currency}", currency: currency, amount: amount.round(ROUND_DIGITS)})
    end
    spend_per_agg_field
  end

  def user_data
    @user_data ||= Firestore.col(Settings.app[:firestore_table_name]).where("user_name", "=", @user_name).get
  end
end
