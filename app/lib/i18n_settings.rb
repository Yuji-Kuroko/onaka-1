# frozen_string_literal: true

I18n.load_path = Dir.glob('locales/**/*.yml')
I18n.backend.load_translations
I18n.default_locale = :ja
I18n.available_locales = %i[ja]
