class UI::TextButton < UI::TextLabel

  def draw_params
    if active?
      [text, {color: [255,127,255,223]}]
    elsif hover?
      [text, {color: [255,255,223,127]}]
    else
      [text, {}]
    end
  end

end
