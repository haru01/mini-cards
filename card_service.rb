class CardService
  def save(card)
    tag_keys = tag_keys(card.text)
    tag_keys.size == 0 ? save_without_tag(card) : save_with_tag(card, tag_keys)
  end

  def save_without_tag(card)
    card.save
  end
  
  def save_with_tag(card, tag_keys)
    tag_keys.each do |key|
      tag = Card.find_by_key(key) || Tag.new(:key => key)
      lk = TagCardLk.new
      lk.tag = tag
      lk.card = card
      lk.save
    end
  end
  
  # 文字列からタグのkey要素を抽出する
  def tag_keys(text)
    str = text
    result = []
    while m = str.match(/(#[^\s]+)/)
      result << m[0][1..-1]
      str = str[(str.index(m[0]) + m[0].size)..-1]
    end
    result
  end
end