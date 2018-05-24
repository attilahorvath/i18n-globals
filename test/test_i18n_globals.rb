require 'minitest/autorun'
require 'minitest/pride'
require 'i18n-globals'

# rubocop:disable Metrics/ClassLength
class TestI18nGlobals < Minitest::Test
  def setup
    I18n.backend.load_translations 'test/fixtures/translations.yml'
    I18n.config.globals = {}
  end

  def test_that_simple_translations_work
    assert_equal 'Hello World!', I18n.translate('test')
  end

  def test_that_interpolated_variables_work
    assert_equal 'Hi there, Joe!', I18n.translate('greeting', name: 'Joe')
  end

  def test_that_global_variables_work
    I18n.config.globals[:name] = 'Bill'

    assert_equal 'Hi there, Bill!', I18n.translate('greeting')
  end

  def test_that_global_variables_can_be_overwritten
    I18n.config.globals[:name] = 'Nick'

    assert_equal 'Hi there, Jill!', I18n.translate('greeting', name: 'Jill')
  end

  def test_that_multiple_global_variables_work
    I18n.config.globals[:name] = 'Chell'
    I18n.config.globals[:company] = 'Aperture Science'

    assert_equal 'Hello Chell, welcome to Aperture Science!', I18n.translate('welcome')
  end

  def test_that_one_of_the_global_variables_can_be_overwritten
    I18n.config.globals[:name] = 'Barney'
    I18n.config.globals[:company] = 'Black Mesa'

    assert_equal 'Hello Gordon, welcome to Black Mesa!', I18n.translate('welcome', name: 'Gordon')
  end

  def test_that_the_other_global_variable_can_be_overwritten
    I18n.config.globals[:name] = 'Barney'
    I18n.config.globals[:company] = 'Black Mesa'

    assert_equal 'Hello Barney, welcome to Aperture Science!',
                 I18n.translate('welcome', company: 'Aperture Science')
  end

  def test_that_all_of_the_global_variables_can_be_overwritten
    I18n.config.globals[:name] = 'Barney'
    I18n.config.globals[:company] = 'Black Mesa'

    assert_equal 'Hello Gordon, welcome to Aperture Science!',
                 I18n.translate('welcome', name: 'Gordon', company: 'Aperture Science')
  end

  def test_that_the_t_alias_work
    I18n.config.globals[:name] = 'Chell'
    I18n.config.globals[:company] = 'Aperture Science'

    assert_equal 'Hello Chell, welcome to Aperture Science!', I18n.t('welcome')
  end

  def test_that_global_variables_are_shared_between_config_instances
    I18n.config.globals[:name] = 'Greg'

    I18n.config = I18n::Config.new

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')
  end

  def test_that_it_also_translates_when_empty_hash_is_pased_as_an_argument
    I18n.config.globals[:name] = 'Chell'
    I18n.config.globals[:company] = 'Aperture Science'

    assert_equal 'Hello Chell, welcome to Aperture Science!', I18n.t('welcome', {})
  end

  def test_that_it_also_translates_when_hash_is_passed_with_reserverd_keys_as_an_argument
    I18n.config.globals[:name] = 'Chell'
    I18n.config.globals[:company] = 'Aperture Science'

    assert_equal 'Hello Chell, welcome to Aperture Science!',
                 I18n.t('welcome', raise: true)
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

    I18n.config.globals[:en].merge!(name: 'Elisa') # rubocop:disable Performance/RedundantMerge

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
    I18n.config.globals[:name] = 'Greg'

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')

    I18n.config.globals[:name] = 'Dobby'

    assert_equal 'Hi there, Dobby!', I18n.translate('greeting')
  end

  def test_that_cache_is_cleared_after_merging_a_new_global
    I18n.config.globals[:name] = 'Greg'

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')

    I18n.config.globals.merge!(name: 'Dobby') # rubocop:disable Performance/RedundantMerge

    assert_equal 'Hi there, Dobby!', I18n.translate('greeting')
  end

  def test_that_it_still_fails_on_missing_interpolation
    assert_raises(I18n::MissingInterpolationArgument) { I18n.translate('greeting', some: 'interpolation') }
  end

  def test_that_it_does_not_fail_if_no_interpolation_is_provided
    assert_equal 'Hi there, %{name}!', I18n.translate('greeting')
  end

  def test_that_it_allows_to_set_a_custom_missing_interpolation_argument_handler
    I18n.config.missing_interpolation_argument_handler = -> { raise 'works!' }

    assert_raises('works!') { I18n.translate('greeting', some: 'interpolation') }

    I18n.config.missing_interpolation_argument_handler = nil
  end

  def test_that_it_translates_globals_with_custom_missing_interpolation_argument_handler
    I18n.config.missing_interpolation_argument_handler = -> { raise 'works!' }

    I18n.config.globals[:name] = 'Greg'

    assert_equal 'Hi there, Greg!', I18n.translate('greeting')

    I18n.config.missing_interpolation_argument_handler = nil
  end

  # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
  def test_that_it_does_not_pollute_the_object_space_with_hashes
    I18n.config.globals = {
      name: 'Greg'
    }

    values = { name: 'Dobby' }
    times = 10_000

    I18n.translate('greeting', values) # run it once to "warm up"

    GC.disable
    count_before = ObjectSpace.each_object(Hash).count
    times.times { I18n.translate('greeting', values) }
    count_after = ObjectSpace.each_object(Hash).count
    GC.enable

    # It looks like I18n.translate by default allocates 2 new hashes
    # per call. So substract it from the count.
    created_due_to_globals = count_after - count_before - times * 2

    assert_equal 0, created_due_to_globals
  end

  def test_that_globals_returns_a_frozen_hash_if_locale_is_present
    I18n.config.globals = {
      name: 'Greg',
      en: { name: 'Debby' }
    }

    assert_equal true, I18n.config.globals(:en).frozen?
  end

  def test_that_globals_returns_default_values_for_locale_too
    I18n.config.globals = {
      name: 'Greg',
      de: { hello: 'Hallo' }
    }

    assert_equal({ name: 'Greg', hello: 'Hallo' }, I18n.config.globals(:de))
  end

  def test_that_global_returns_locale_value
    I18n.config.globals = {
      name: 'Greg',
      en: { name: 'Debby' }
    }

    assert_equal 'Debby', I18n.config.global(:name, :en)
  end

  def test_that_global_returns_default_values_too
    I18n.config.globals = {
      name: 'Greg',
      de: { hello: 'Hallo' }
    }

    assert_equal 'Greg', I18n.config.global(:name, :de)
  end

  def test_that_global_works_with_symbols
    I18n.config.globals = { name: 'Greg' }

    assert_equal 'Greg', I18n.config.global(:name)
  end

  def test_that_global_works_with_strings
    I18n.config.globals = { name: 'Greg' }

    assert_equal 'Greg', I18n.config.global('name')
  end
end
