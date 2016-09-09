require 'minitest/autorun'
require 'minitest/pride'
require 'i18n-globals'

class TestI18nGlobals < Minitest::Test
  def setup
    I18n.backend.load_translations 'test/fixtures/translations.yml'
    I18n.config = I18n::Config.new
    I18n.config.globals = {} # glear globals between runs
    I18n.locale = :en
  end

  def test_that_simple_translations_work
    assert_equal I18n.translate('test'), 'Hello World!'
  end

  def test_that_interpolated_variables_work
    assert_equal I18n.translate('greeting', name: 'Joe'), 'Hi there, Joe!'
  end

  def test_that_global_variables_work
    I18n.config.globals[:name] = 'Bill'

    assert_equal I18n.translate('greeting'), 'Hi there, Bill!'
  end

  def test_that_global_variables_can_be_overwritten
    I18n.config.globals[:name] = 'Nick'

    assert_equal I18n.translate('greeting', name: 'Jill'), 'Hi there, Jill!'
  end

  def test_that_multiple_global_variables_work
    I18n.config.globals[:name] = 'Chell'
    I18n.config.globals[:company] = 'Aperture Science'

    assert_equal I18n.translate('welcome'), 'Hello Chell, welcome to Aperture Science!'
  end

  def test_that_one_of_the_global_variables_can_be_overwritten
    I18n.config.globals[:name] = 'Barney'
    I18n.config.globals[:company] = 'Black Mesa'

    assert_equal I18n.translate('welcome', name: 'Gordon'), 'Hello Gordon, welcome to Black Mesa!'
  end

  def test_that_the_other_global_variable_can_be_overwritten
    I18n.config.globals[:name] = 'Barney'
    I18n.config.globals[:company] = 'Black Mesa'

    assert_equal I18n.translate('welcome', company: 'Aperture Science'), 'Hello Barney, welcome to Aperture Science!'
  end

  def test_that_all_of_the_global_variables_can_be_overwritten
    I18n.config.globals[:name] = 'Barney'
    I18n.config.globals[:company] = 'Black Mesa'

    assert_equal I18n.translate('welcome', name: 'Gordon', company: 'Aperture Science'), 'Hello Gordon, welcome to Aperture Science!'
  end

  def test_that_the_t_alias_work
    I18n.config.globals[:name] = 'Chell'
    I18n.config.globals[:company] = 'Aperture Science'

    assert_equal I18n.t('welcome'), 'Hello Chell, welcome to Aperture Science!'
  end

  def test_that_global_variables_are_shared_between_config_instances
    I18n.config.globals[:name] = 'Greg'

    I18n.config = I18n::Config.new

    assert_equal I18n.translate('greeting'), 'Hi there, Greg!'
  end

  def test_that_locale_dependent_variable_overrides_default_one
    I18n.config.globals = {
      name: 'Greg',
      en: { name: 'Debby' }
    }

    assert_equal 'Hi there, Debby!', I18n.translate('greeting')
  end

  def test_that_default_variable_is_used_if_no_special_locale_version_is_present
    I18n.config.globals = {
      name: 'Greg',
      fr: { name: 'Debora' }
    }

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_setting_a_new_locale_global
    I18n.config.globals = {
      name: 'Greg',
      en: { name: 'Debby' }
    }

    assert_equal 'Hi there, Debby!', I18n.translate('greeting')

    I18n.config.globals[:en][:name] = 'Elisa'

    assert_equal 'Hi there, Elisa!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_setting_a_new_locale_hash
    I18n.config.globals = {
      name: 'Greg',
      en: { name: 'Debby' }
    }

    assert_equal 'Hi there, Debby!', I18n.translate('greeting')

    I18n.config.globals[:en] = {
      name: 'Elisa'
    }

    assert_equal 'Hi there, Elisa!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_merging_a_new_locale_hash
    I18n.config.globals = {
      name: 'Greg',
      en: { name: 'Debby' }
    }

    assert_equal 'Hi there, Debby!', I18n.translate('greeting')

    I18n.config.globals[:en].merge!(name: 'Elisa')

    assert_equal 'Hi there, Elisa!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_clearing_locale_hash
    I18n.config.globals = {
      name: 'Greg',
      en: { name: 'Debby' }
    }

    assert_equal 'Hi there, Debby!', I18n.translate('greeting')

    I18n.config.globals[:en].clear

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_setting_a_new_global
    I18n.config.globals = {
      name: 'Greg'
    }

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')

    I18n.config.globals[:name] = 'Dobby'

    assert_equal 'Hi there, Dobby!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_merging_a_new_global
    I18n.config.globals = {
      name: 'Greg'
    }

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')

    I18n.config.globals.merge!(name: 'Dobby')

    assert_equal 'Hi there, Dobby!', I18n.translate('greeting')
  end
end
