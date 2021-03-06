module DDS
  module V1
    class StorageProvidersAPI < Grape::API
      desc 'List storage providers' do
        detail 'Returns a list of all storage providers'
        named 'list storage providers'
        failure [
          [200, 'Success'],
          [401, 'Unauthorized']
        ]
      end
      get '/storage_providers', root: :results do
        authenticate!
        StorageProvider.all
      end

      desc 'View storage provider' do
        detail 'Returns the storage providers for a given user'
        named 'show storage providers'
        failure [
          [200, 'Success'],
          [401, 'Unauthorized'],
          [404, 'StorageProvider Does not Exist']
        ]
      end
      params do
        requires :id, type: String, desc: 'StorageProvider UUID'
      end
      get '/storage_providers/:id', root: false do
        authenticate!
        storage_provider = StorageProvider.find(params[:id])
        storage_provider
       end
    end
  end
end
