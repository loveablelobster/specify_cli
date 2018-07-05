# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe User do
      let(:collection) { Collection.first CollectionName: 'Test Collection' }
      let(:user) { described_class.first Name: 'specuser' }

      describe '#log_in' do
        context 'when not logged in' do
          before { user.log_out }

          it do
            just_before = Time.now
            expect(user.log_in(collection))
              .to include collection => a_value >= just_before
          end

          it do
            just_before = Time.now
            expect { user.log_in(collection) }
              .to change { user.values }
              .from(including(IsLoggedIn: false,
                              LoginCollectionName: nil,
                              LoginDisciplineName: nil,
                              LoginOutTime: a_value <= just_before))
              .to(including(IsLoggedIn: true,
                            LoginCollectionName: collection[:CollectionName],
                            LoginDisciplineName: collection.discipline[:Name],
                            LoginOutTime: a_value >= just_before))
          end
        end

        context 'when already logged in' do
          before { user.log_in(collection) }

          it do
            just_before = Time.now
            expect(user.log_in(collection))
              .to include collection => a_value <= just_before
          end

          it do
            just_before = Time.now
            expect { user.log_in(collection) }
              .not_to change { user.values }
          end
        end

        context 'when already logged in to a different collection' do
        	before { user.log_in(Collection.first(Code: 'NECE')) }

        	it do
        	  expect { user.log_in collection }
              .to raise_error LoginError::INCONSISTENT_LOGIN
          end
        end
      end

      describe '#log_out' do
        before { user.log_in collection }

        it do
          just_before = Time.now
        	expect(user.log_out)
            .to be >= just_before
        end

        it do
          just_before = Time.now
          expect { user.log_out }
            .to change { user.values }
            .from(including(IsLoggedIn: true,
                            LoginCollectionName: collection[:CollectionName],
                            LoginDisciplineName: collection.discipline[:Name],
                            LoginOutTime: a_value <= just_before))
            .to(including(IsLoggedIn: false,
                          LoginCollectionName: nil,
                          LoginDisciplineName: nil,
                          LoginOutTime: a_value >= just_before))
        end
      end

      describe '#logged_in_agent' do
        before { user.log_in collection }

        subject { user.logged_in_agent }

        it do
          is_expected
            .to have_attributes FirstName: 'John', LastName: 'Doe'
        end
      end

      describe '#new_login' do
        before { user.log_out }

        it do
          just_before = Time.now
          expect(user.new_login(collection))
            .to include collection => a_value >= just_before
        end

        it do
          just_before = Time.now
          expect { user.new_login(collection) }
            .to change { user.values }
            .from(including(IsLoggedIn: false,
                            LoginCollectionName: nil,
                            LoginDisciplineName: nil,
                            LoginOutTime: a_value <= just_before))
            .to(including(IsLoggedIn: true,
                          LoginCollectionName: collection[:CollectionName],
                          LoginDisciplineName: collection.discipline[:Name],
                          LoginOutTime: a_value >= just_before))
        end
      end

      describe '#view_set_dir' do
        subject { user.view_set_dir(collection) }

        it do
          is_expected
            .to have_attributes DisciplineType: 'Invertebrate Paleontology',
                                IsPersonal: true,
                                UserType: 'manager',
                                collection: collection,
                                user: user,
                                discipline: collection.discipline
        end
      end

      describe '#view_set' do
        subject { user.view_set(collection) }

        it do
          is_expected.to have_attributes Name: 'paleo.views'
        end
      end
    end
  end
end
