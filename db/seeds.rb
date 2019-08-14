# frozen_string_literal: true

require 'bundler/setup'
Bundler.require

require './app/onaka_bot/slack_bot'

{
  64 => [
    { name: 'yowaso' },
    { name: 'tsurami' },
    { name: 'turai' },
    { name: 'kayui' },
    { name: 'wbt50' },
    { name: 'murisezu' },
    { name: 'gabi-n' },
    { name: 'rimu' },
    { name: 'doko' },
  ],
  32 => [
    { name: 'suisui' },
    { name: 'ippai' },
    { name: 'wbt0' },
    { name: 'wbt100' },
    { name: 'yoshi' },
    { name: 'konwaku' },
    { name: 'hokkori' },
    { name: 'nayamu' },
    { name: 'muzai' },
    { name: 'konnichiha' },
    { name: 'kirei' },
    { name: 'u7a7a' },
  ],
  16 => [
    { name: 'tsuyosou' },
    { name: 'urusai' },
    { name: 'erait' },
    { name: 'deta' },
    { name: 'rikaishita' },
    { name: 'emoi' },
    { name: 'naosu' },
    { name: 'warukunai' },
    { name: 'waruyono' },
    { name: 'kyomoasakara', custom_display_name: ':onaka: :kyomoasakara: :onaka: :suisui:' },
    { name: 'u6e80' },
  ],
  8 => [
    { name: 'detadeta' },
    { name: 'odaijini' },
    { name: 'totemotsurai' },
    { name: 'yabatanien' },
    { name: 'dekasita' },
    { name: 'ochitsuke' },
    { name: 'hakkyou' },
    { name: 'anshin' },
    { name: 'kakkoii' },
    { name: 'ver_up' },
    { name: 'yaseta' },
    { name: 'akan' },
    { name: 'aa' },
    { name: 'sos' },
    { name: 'yasashii', custom_display_name: ':onaka: :joshi_ni: :yasashii:' },
    { name: 'kyomokyotote', custom_display_name: ':kyomokyotote: :onaka: :suisui:' },
    { name: 'u55b6' },
  ],
  4 => [
    { name: 'mezame', custom_display_name: ':onaka: :suisui: :no: :mezame:' },
    { name: 'mebae', custom_display_name: ':onaka: :suisui: :no: :mebae:' },
    { name: 'homare', custom_display_name: ':onaka: :suisui: :no: :homare:' },
    { name: 'yume', custom_display_name: ':onaka: :suisui: :no: :yume:' },
    { name: 'hi', custom_display_name: ':onaka: :suisui: :no: :hi:' },
    { name: 'hell', custom_display_name: ':onaka: :suisui: :no: :hell:' },
    { name: 'mukui', custom_display_name: ':onaka: :suisui: :no: :mukui:' },
    { name: 'imaginary', custom_display_name: ':onaka: :suisui: :no: :imaginary:' },
    { name: 'ayamachi', custom_display_name: ':onaka: :suisui: :no: :ayamachi:' },
    { name: 'kan', custom_display_name: ':onaka: :suisui: :no: :kan:' },
    { name: 'congratulations', custom_display_name: ':onaka: :suisui: :no: :congratulations:' },
  ],
  2 => [
    { name: 'kaname', custom_display_name: ':onaka: :suisui: :no: :kaname:' },
    { name: 'satori', custom_display_name: ':onaka: :suisui: :no: :satori:' },
    { name: 'nazo', custom_display_name: ':onaka: :suisui: :no: :nazo:' },
    { name: 'secret', custom_display_name: ':onaka: :suisui: :no: :secret:' },
    { name: 'uso', custom_display_name: ':onaka: :suisui: :no: :uso:' },
    { name: 'ame', custom_display_name: ':onaka: :suisui: :no: :ame:' },
    { name: 'arare', custom_display_name: ':onaka: :suisui: :no: :arare:' },
    { name: 'oni', custom_display_name: ':onaka: :suisui: :no: :oni:' },
    { name: 'natsu', custom_display_name: ':onaka: :suisui: :no: :natsu:' },
    { name: 'ai', custom_display_name: ':onaka: :suisui: :no: :ai:' },
    { name: 'kanashimi', custom_display_name: ':onaka: :suisui: :no: :kanashimi:' },
    { name: 'u7981', custom_display_name: ':onaka: :suisui: :no: :u7981:' },
  ],
  1 => [
    { name: 'happakaitai', custom_display_name: ':onaka: :happakaitai:' },
    { name: 'kiwami', custom_display_name: ':onaka: :suisui: :no: :kiwami:' },
    { name: 'owari', custom_display_name: ':onaka: :suisui: :no: :owari:' },
    { name: 'ri', custom_display_name: ':onaka: :suisui: :no: :ri:' },
  ],
}.each do |freq, emojis|
  emojis.each do |emoji|
    name, custom_display_name = emoji.values_at(:name, :custom_display_name)
    onaka = Onaka.find_or_initialize_by(name: name)
    onaka.update!(custom_display_name: custom_display_name, frequency: freq)
    Emoji.find_or_initialize_by(name: name).update!(onaka_id: onaka.id)
  end
end
