Rails.application.routes.draw do
  devise_for :customers

  devise_scope :customer do
    authenticated :customer do
      root to: "welcome#index"
    end

    unauthenticated :customer do
      root to: "devise/registrations#new", as: :unauthenticated_root
    end
  end
end
