# frozen_string_literal: true

module SpResource
  module Specify
    module Model
      RSpec.describe User do
        let(:collection) { Collection.first CollectionName: 'Test Collection' }
        let(:user) { described_class.first Name: 'specuser' }

        context 'when logging in' do
          it 'raises an error if already logged in to a different collection' do
            user[:LoginCollectionName] = 'Test Collection'
            user[:LoginDisciplineName] = 'Wrong Discipline'
            user[:IsLoggedIn] = true
            expect { user.login collection }
              .to raise_error LoginError::INCONSISTENT_LOGIN
          end

          it 'returns a hash with the collection as key' do
            expect(user.login(collection)).to include collection
          end

          it 'returns a hash with the login time as value' do
            just_before = Time.now
            expect(user.login(collection)[collection]).to be >= just_before
          end

          it 'sets the flag that the user is logged in' do
            user.login collection
            expect(user[:IsLoggedIn]).to be_truthy
          end

          it 'sets the login/out timestamp upon login' do
            just_before = Time.now
            user.login collection
            expect(user[:LoginOutTime]).to be >= just_before
          end

          it 'sets the name of the collection logged in to' do
            user.login collection
            expect(user[:LoginCollectionName]).to eq 'Test Collection'
          end

          it 'sets the name of the discipline logged in to' do
            user.login collection
            expect(user[:LoginDisciplineName]).to eq 'Test Discipline'
          end
        end

        context 'when logging out' do
          it 'sets the flag that the user is logged out' do
            user.logout
            expect(user[:IsLoggedIn]).to be_falsey
          end

          it 'returns a hash with the logout time as value' do
            user.login collection
            just_before = Time.now
            expect(user.logout).to be >= just_before
          end

          it 'resets the name of the collection logged in to' do
            user.login collection
            user.logout
            expect(user[:LoginCollectionName]).to be_nil
          end

          it 'resets the name of the discipline logged in to' do
            user.login collection
            user.logout
            expect(user[:LoginDisciplineName]).to be_nil
          end
        end

        it 'returns the Agent for the collection the user is logged in to' do
          user.login collection
          expect(user.logged_in_agent.values)
            .to include FirstName: 'John', LastName: 'Doe'
        end

        it 'returns all AppResourceDir instances' do
          expect(user.app_resource_dirs(collection).all)
            .to include an_instance_of AppResourceDir
        end

        it 'returns the ViewSetObject for the given collection' do
          expect(user.view_set(collection).values)
            .to include :Name => 'Paleo Views'
        end
      end
    end
  end
end
